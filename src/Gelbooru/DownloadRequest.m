#import "Gelbooru/DownloadRequest.h"

static constexpr auto GELBOORU_BASE_IRI = @"https://gelbooru.com/index.php";

static OFHTTPRequest *GBMakeRequest(int limit,
                                    OFArray<OFString *> *tags,
                                    OFString *apiKey,
                                    OFString *userID,
                                    int page)
{
    auto host = [OFMutableIRI IRIWithString:GELBOORU_BASE_IRI];
    const auto pair = ^(OFString *key, OFString *value) {
        return [OFPair pairWithFirstObject:key secondObject:value];
    };
    host.queryItems = @[
        pair(@"page", @"dapi"),
        pair(@"s", @"post"),
        pair(@"q", @"index"),
        pair(@"json", @"1"),
        pair(@"limit", @(limit).stringValue),
        pair(@"tags", [tags componentsJoinedByString:@"+"]),
        pair(@"api_key", apiKey),
        pair(@"user_id", userID),
        pair(@"pid", @(page).stringValue)
    ];
    return [OFHTTPRequest requestWithIRI:host];
}

@interface DownloadRequest ()
{
    FuturePromise<OFArray<ImageDownloadRequest *> *> *promise;
    RequestRateLimiter *nillable limiter;
    size_t maxImagesForPage;
    ProgressBar *nillable progress;
}

- (void)reject:(OFException *)exception;

@end

@implementation DownloadRequest

- (instancetype)initWithAPIKey:(OFString *)apiKey
                        userID:(OFString *)userID
                          tags:(OFArray<OFString *> *)tags
                         limit:(int)limit
                          page:(int)page
               outputDirectory:(OFIRI *)out
                   rateLimiter:(RequestRateLimiter *nillable)rateLimiter
                    maxImages:(size_t)maxImages
                  progressBar:(ProgressBar *nillable)progressBar
{
    self = [super init];

    promise = [FuturePromise promiseWithRunLoop:OFRunLoop.currentRunLoop mode:nil];
    _response = promise.future;
    limiter = rateLimiter;
    maxImagesForPage = maxImages;
    progress = progressBar;

    if (not [OFFileManager.defaultManager directoryExistsAtIRI:out]) {
        [OFFileManager.defaultManager createDirectoryAtIRI:out createParents:true];
    }
    _outputDirectory = out;

    _httpClient = [[OFHTTPClient alloc] init];
    _httpClient.delegate = self;
    _request = GBMakeRequest(limit, tags, apiKey, userID, page);

    void (^startRequest)(void) = ^{
        [_httpClient asyncPerformRequest:_request];
    };

    if (limiter) [limiter enqueue:startRequest];
    else         startRequest();
    return self;
}

+ (instancetype)requestWithAPIKey:(OFString *)apiKey
                           userID:(OFString *)userID
                             tags:(OFArray<OFString *> *)tags
                            limit:(int)limit
                             page:(int)page
                  outputDirectory:(OFIRI *)out
                      rateLimiter:(RequestRateLimiter *nillable)rateLimiter
                       maxImages:(size_t)maxImages
                     progressBar:(ProgressBar *nillable)progressBar
{
    return [[self alloc] initWithAPIKey:apiKey
                                 userID:userID
                                   tags:tags
                                  limit:limit
                                  page:page
                       outputDirectory:out
                           rateLimiter:rateLimiter
                             maxImages:maxImages
                           progressBar:progressBar];
}

- (void)client:(OFHTTPClient *nonnil)client
didPerformRequest:(OFHTTPRequest *nonnil)request
      response:(OFHTTPResponse *nillable)response
     exception:(id nillable)exception
{
    if (exception) {
        [self reject:$cast(OFException, exception)];
        return;
    }

    if (not response) {
        [self reject:[OFInvalidArgumentException exception]];
        return;
    }

    if (response.statusCode != 200) {
        [self reject:[OFHTTPRequestFailedException exceptionWithRequest:request
                                                               response:(OFHTTPResponse *)response]];
        return;
    }

    @try {
        auto responseString = $assert_nonnil([response readString]);
        auto posts = [[GBPostsResponse alloc] initWithJSONDictionary:responseString.objectByParsingJSON].posts;
        OFLog(@"Parsed %zu posts", posts.count);

        size_t downloadCount = (maxImagesForPage < posts.count) ? maxImagesForPage : posts.count;
        auto downloadRequests = [OFMutableArray<ImageDownloadRequest *> arrayWithCapacity:downloadCount];
        for (size_t i = 0; i < downloadCount; i++) {
            GBPost *post = posts[i];
            auto iri = [OFIRI IRIWithString:post.fileURL];
            auto destination = [_outputDirectory IRIByAppendingPathComponent:iri.lastPathComponent];
            [downloadRequests addObject:[ImageDownloadRequest requestWithIRI:iri
                                                                          to:destination
                                                                 rateLimiter:limiter
                                                                 progressBar:progress]];
        }
        [downloadRequests makeImmutable];
        [promise resolve:downloadRequests];
    } @catch (OFException *ex) {
        [self reject:ex];
    }
}

#pragma mark - Private helpers

- (void)reject:(OFException *)exception
{
    [promise reject:exception];
}

@end
