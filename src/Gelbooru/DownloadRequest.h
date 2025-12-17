#import "common.h"
#import "utilities/Future.h"

#import "Gelbooru/Gelbooru.h"
#import "Gelbooru/ImageDownloadRequest.h"
#import "Gelbooru/RequestRateLimiter.h"
#import "Gelbooru/ProgressBar.h"

$assume_nonnil_begin

@interface DownloadRequest : OFObject<OFHTTPClientDelegate>

@property(readonly, nonatomic) OFHTTPClient *httpClient;
@property(nonatomic) OFHTTPRequest *nonnil request;
@property(readonly, nonatomic) OFIRI *outputDirectory;
@property(nonatomic) Future<OFArray<ImageDownloadRequest *> *> *response;

- (instancetype)initWithAPIKey:(OFString *)apiKey
                        userID:(OFString *)userID
                          tags:(OFArray<OFString *> *)tags
                         limit:(int)limit
                          page:(int)page
               outputDirectory:(OFIRI *)out
                   rateLimiter:(RequestRateLimiter *nillable)rateLimiter
                    maxImages:(size_t)maxImages
                  progressBar:(ProgressBar *nillable)progressBar;

+ (instancetype)requestWithAPIKey:(OFString *)apiKey
                           userID:(OFString *)userID
                             tags:(OFArray<OFString *> *)tags
                            limit:(int)limit
                             page:(int)page
                  outputDirectory:(OFIRI *)out
                      rateLimiter:(RequestRateLimiter *nillable)rateLimiter
                       maxImages:(size_t)maxImages
                     progressBar:(ProgressBar *nillable)progressBar;

@end

$assume_nonnil_end
