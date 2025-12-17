#import "common.h"
#import "utilities/Future.h"
#import "Gelbooru/RequestRateLimiter.h"
#import "Gelbooru/ProgressBar.h"

$assume_nonnil_begin

@interface ImageInfo : OFObject

@property(readonly, nonatomic) OFIRI *iri;
@property(readonly, nonatomic) size_t width;
@property(readonly, nonatomic) size_t height;
@property(readonly, nonatomic) size_t fileSize;

- (instancetype)initWithIRI:(OFIRI *)url
                      width:(size_t)width
                     height:(size_t)height
                   fileSize:(size_t)fileSize;
+ (instancetype)infoWithIRI:(OFIRI *)url
                      width:(size_t)width
                     height:(size_t)height
                   fileSize:(size_t)fileSize;

@end

@interface ImageDownloadRequest : OFObject<OFHTTPClientDelegate>

@property(readonly, nonatomic) OFHTTPClient *httpClient;
@property(nonatomic) OFHTTPRequest *nonnil request;
@property(readonly, nonatomic) OFIRI *destination;
@property(nonatomic) Future<ImageInfo *> *response;

- (instancetype)initWithIRI:(OFIRI *)url
                         to:(OFIRI *)destination
                rateLimiter:(RequestRateLimiter *nillable)rateLimiter
                progressBar:(ProgressBar *nillable)progressBar;
+ (instancetype)requestWithIRI:(OFIRI *)url
                            to:(OFIRI *)destination
                   rateLimiter:(RequestRateLimiter *nillable)rateLimiter
                   progressBar:(ProgressBar *nillable)progressBar;

@end

$assume_nonnil_end
