#import "Gelbooru/ImageDownloadRequest.h"
#import "Gelbooru/RequestRateLimiter.h"

#import <errno.h>
#include <stdatomic.h>

@implementation ImageInfo

- (instancetype)initWithIRI:(OFIRI *)url
                      width:(size_t)width
                     height:(size_t)height
                   fileSize:(size_t)fileSize
{
    self = [super init];
    _iri = url;
    _width = width;
    _height = height;
    _fileSize = fileSize;
    return self;
}

+ (instancetype)infoWithIRI:(OFIRI *)url
                      width:(size_t)width
                     height:(size_t)height
                   fileSize:(size_t)fileSize
{
    return [[self alloc] initWithIRI:url width:width height:height fileSize:fileSize];
}

@end

@interface ImageDownloadRequest ()
{
    FuturePromise<ImageInfo *> *promise;
    FILE *fileHandle;
    uint8_t buffer[1 << 16];
    _Atomic(bool) settled;
    RequestRateLimiter *nillable limiter;
    ProgressBar *nillable progress;
    OFString *label;
    uint64_t expectedBytes;
}

- (bool)finishWithException:(OFException *)exception;
- (bool)finishWithInfo:(ImageInfo *)info;
- (void)closeFileIfOpen;

@end

@implementation ImageDownloadRequest

- (instancetype)initWithIRI:(OFIRI *)url
                         to:(OFIRI *)destination
                rateLimiter:(RequestRateLimiter *nillable)rateLimiter
                progressBar:(ProgressBar *nillable)progressBar
{
    self = [super init];

    settled = false;
    promise = [FuturePromise promiseWithRunLoop:OFRunLoop.currentRunLoop mode:nil];
    _response = promise.future;
    limiter = rateLimiter;
    progress = progressBar;
    label = destination.lastPathComponent;
    expectedBytes = 0;

    _httpClient = [OFHTTPClient client];
    _httpClient.delegate = self;
    _request = [OFHTTPRequest requestWithIRI:url];
    _destination = destination;

    fileHandle = fopen(destination.path.UTF8String, "wb");
    if (not fileHandle) {
        auto ex = [OFWriteFailedException exceptionWithObject:destination
                                             requestedLength:0
                                                bytesWritten:0
                                                      errNo:errno];
        [self finishWithException:ex];
        return self;
    }

    void (^startRequest)(void) = ^{
        [_httpClient asyncPerformRequest:_request];
    };

    if (limiter) [limiter enqueue:startRequest];
    else         startRequest();

    if (progress) [progress startTaskWithLabel:label];
    return self;
}

+ (instancetype)requestWithIRI:(OFIRI *)url to:(OFIRI *)destination rateLimiter:(RequestRateLimiter *nillable)rateLimiter progressBar:(ProgressBar *nillable)progressBar
{
    return [[self alloc] initWithIRI: url to: destination rateLimiter: rateLimiter progressBar: progressBar];
}

- (void)client:(OFHTTPClient *nonnil)client didPerformRequest:(OFHTTPRequest *nonnil)request response:(OFHTTPResponse *nillable)response exception:(id nillable)exception
{
    if (exception) {
        [self finishWithException: $cast(OFException, exception)];
        return;
    }

    if (not response) {
        [self finishWithException: [OFInvalidArgumentException exception]];
        return;
    }

    if (response.statusCode != 200) {
        [self finishWithException: [OFHTTPRequestFailedException exceptionWithRequest: request response: (OFHTTPResponse *)response]];
        return;
    }

    OFString *contentLength = response.headers[@"Content-Length"];
    if (contentLength) {
        expectedBytes = contentLength.unsignedLongLongValue;
        if (progress) [progress setExpectedBytes: expectedBytes forLabel: label];
    }

    [response asyncReadIntoBuffer: buffer length: sizeof(buffer) handler: ^(OFStream *stream, void *data, size_t len, id nillable readException) {
        if (readException) {
            return [self finishWithException: $cast(OFException, readException)];
        }

        if (len > 0) {
            size_t written = fwrite(data, 1, len, fileHandle);
            if (written != len) {
                auto ex = [OFWriteFailedException exceptionWithObject: _destination requestedLength: len bytesWritten: written errNo: errno];
                return [self finishWithException: ex];
            }

            if (progress) [progress addReceivedBytes: len forLabel: label];
        }

        if (stream.isAtEndOfStream) {
            [self closeFileIfOpen];
            auto attrs = [OFFileManager.defaultManager attributesOfItemAtIRI: _destination];
            auto info = [ImageInfo infoWithIRI: _request.IRI width: 0 height: 0 fileSize: attrs.fileSize];
            return [self finishWithInfo:info];
        }

        return true;
    }];
}

#pragma mark - Private helpers

- (void)closeFileIfOpen
{
    if (fileHandle) {
        fclose(fileHandle);
        fileHandle = NULL;
    }
}

- (bool)finishWithException:(OFException *)exception
{
    bool expected = false;
    if (!atomic_compare_exchange_strong(&settled, &expected, true))
        return false;

    [self closeFileIfOpen];
    if (progress) [progress finishTaskWithLabel:label];
    [promise reject:exception];
    return false;
}

- (bool)finishWithInfo:(ImageInfo *)info
{
    bool expected = false;
    if (!atomic_compare_exchange_strong(&settled, &expected, true))
        return false;

    [self closeFileIfOpen];
    if (progress) [progress finishTaskWithLabel:label];
    [promise resolve:info];
    return false;
}

@end
