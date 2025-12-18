#import "common.h"

#import "utilities/OFArray+Functional.h"
#import "utilities/Future.h"
#import "Gelbooru/DownloadRequest.h"
#import "Gelbooru/RequestRateLimiter.h"
#import "Gelbooru/ProgressBar.h"

$assume_nonnil_begin

static constexpr int PAGE_LIMIT = 100;

// Gelbooru downloader entrypoint
@interface Application : OFObject<OFApplicationDelegate> @end

@implementation Application {
    DownloadRequest *downloadRequest;
    RequestRateLimiter *rateLimiter;
    ProgressBar *progressBar;
    Future<OFArray<ImageInfo *> *> *downloadFuture;
}

- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
    typeof(OFString *__autoreleasing nillable) outputdir = nilptr, tags = nilptr, limit = nilptr;
    bool showLabels = true;
    const auto ARGUMENTS = (OFOptionsParserOption[]){
        { .shortOption = 'o', .longOption = @"output-directory", .hasArgument = true, .argumentPtr = &outputdir },
        { .shortOption = 't', .longOption = @"tags", .hasArgument = true, .argumentPtr = &tags },
        { .shortOption = 'l', .longOption = @"limit", .hasArgument = true, .argumentPtr = &limit },
        { .shortOption = 'L', .longOption = @"no-labels", .hasArgument = false, .argumentPtr = NULL },
        {0}
    };

    auto parser = [OFOptionsParser parserWithOptions:ARGUMENTS];
    OFUnichar opt;

    if (parser.remainingArguments.count == 0) {
        [OFStdErr writeString:@"No arguments specified.\n"];
        [OFApplication terminateWithStatus:1];
        return;
    }

    while ((opt = [parser nextOption])) {
        bool quit = false;
        switch (opt) {
            case 'o':
            case 't':
            case 'l':
                break;
            case 'L':
                showLabels = false;
                break;
            case '?':
                [OFStdErr writeFormat:@"Unknown option: -%c\n", parser.lastOption];
                quit = true;
                break;
            case ':':
                [OFStdErr writeFormat:@"Missing argument for option: -%c\n", parser.lastOption];
                quit = true;
                break;
            default:
                [OFStdErr writeFormat:@"Unhandled option: -%c\n", parser.lastOption];
                quit = true;
                break;
        }

        if (quit) {
            [OFApplication terminateWithStatus:1];
            return;
        }
    }

    $assert_nonnil(outputdir);
    $assert_nonnil(tags);
    limit = (limit != nilptr) ? limit : @"10";

    size_t totalLimit = (size_t)limit.unsignedLongLongValue;
    if (totalLimit == 0) {
        [OFStdErr writeString:@"Limit must be greater than 0.\n"];
        [OFApplication terminateWithStatus:1];
        return;
    }

    OFString *apiKey = $assert_nonnil(OFApplication.environment[@"GELBOORU_API_KEY"]);
    OFString *userID = $assert_nonnil(OFApplication.environment[@"GELBOORU_USER_ID"]);
    OFIRI *outputIRI = [OFIRI fileIRIWithPath:outputdir isDirectory:true];
    OFArray<OFString *> *tagList = [tags componentsSeparatedByString:@" "];
    rateLimiter = [[RequestRateLimiter alloc] initWithRequestsPerSecond:10];
    progressBar = [[ProgressBar alloc] initWithTotalTasks:totalLimit showLabels:showLabels];

    downloadFuture = [self downloadPage:0
                              remaining:totalLimit
                                   tags:tagList
                              outputDir:outputIRI
                                 apiKey:apiKey
                                 userID:userID];

    [downloadFuture whenComplete:^(OFArray<ImageInfo *> *nillable infos, OFException *nillable error) {
        if (error) {
            [OFStdErr writeFormat:@"Download failed: %@\n", error];
            [progressBar completeWithTotal:progressBar.completedTasks];
            [OFApplication terminateWithStatus:1];
        } else {
            OFLog(@"All %zu downloads completed successfully", infos.count);
            [progressBar completeWithTotal:infos.count];
            [OFApplication terminate];
        }
    }];
}

- (Future<OFArray<ImageInfo *> *> *)downloadPage:(int)page
                                       remaining:(size_t)remaining
                                            tags:(OFArray<OFString *> *)tags
                                       outputDir:(OFIRI *)outputDir
                                          apiKey:(OFString *)apiKey
                                          userID:(OFString *)userID
{
    if (remaining == 0)
        return [Future resolved:[OFArray array]];

    downloadRequest = [DownloadRequest requestWithAPIKey:apiKey
                                                  userID:userID
                                                    tags:tags
                                                   limit:PAGE_LIMIT
                                                    page:page
                                         outputDirectory:outputDir
                                             rateLimiter:rateLimiter
                                              maxImages:remaining
                                            progressBar:progressBar];

    auto requestFuture = [downloadRequest.response catch:^id(OFException *nillable exception) {
        [OFStdErr writeFormat:@"Error during download request %@\n", exception];
        @throw exception;
    }];

    return [requestFuture bind:^id(OFArray<ImageDownloadRequest *> *dlRequests) {
        if (dlRequests.count == 0)
            return [Future resolved:[OFArray array]];

        OFLog(@"Starting downloads for %zu posts (page %d)", dlRequests.count, page);

        auto responseFutures =
            (OFArray<Future<ImageInfo *> *> *)[dlRequests map:^id(ImageDownloadRequest *dlreq) {
                OFString *label = dlreq.destination.lastPathComponent;
                [progressBar startTaskWithLabel:label];
                return [[dlreq.response catch:^ImageInfo *(OFException *nillable exception) {
                    [progressBar finishTaskWithLabel:label];
                    [OFStdErr writeFormat:@"Error during image download request %@\n", exception];
                    @throw exception;
                }] map:^id(ImageInfo *info) {
                    [progressBar finishTaskWithLabel:label];
                    return info;
                }];
            }];

        return [[Future all: $assert_nonnil(responseFutures)] bind:^id(OFArray<ImageInfo *> *infos) {
            size_t downloaded = infos.count;
            size_t newRemaining = remaining > downloaded ? remaining - downloaded : 0;

            if (newRemaining == 0 || downloaded == 0)
                return [Future resolved:infos];

            return [[self  downloadPage: page + 1
                              remaining: newRemaining
                                   tags: tags
                              outputDir: outputDir
                                 apiKey: apiKey
                                 userID: userID] map:^id(OFArray<ImageInfo *> *moreInfos) {
                OFMutableArray<ImageInfo *> *all = [OFMutableArray array];
                [all addObjectsFromArray:infos];
                [all addObjectsFromArray:moreInfos];
                [all makeImmutable];
                return all;
            }];
        }];
    }];
}

@end

$assume_nonnil_end

OF_APPLICATION_DELEGATE(Application);
