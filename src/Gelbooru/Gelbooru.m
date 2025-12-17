#import "Gelbooru.h"

#pragma mark - GBAttributes

@implementation GBAttributes

- (instancetype)initWithJSONDictionary:(OFDictionary<OFString *, id> *)dict
{
    self = [super init];

    _limit  = [$cast(OFNumber, dict[@"limit"])  unsignedLongLongValue];
    _offset = [$cast(OFNumber, dict[@"offset"]) unsignedLongLongValue];
    _count  = [$cast(OFNumber, dict[@"count"])  unsignedLongLongValue];

    return self;
}

@end

#pragma mark - GBPost

@implementation GBPost

static enum GBPostRating parseRating(OFString *nillable ratingStr)
{
    if (ratingStr == nilptr) return GBPostRatingUnknown;

    OFString *lower = [ratingStr lowercaseString];

    if ([lower isEqual: @"safe"] or [lower isEqual: @"s"] or [lower isEqual: @"general"] or [lower isEqual: @"g"])
        return GBPostRatingSafe;
    if ([lower isEqual: @"questionable"] or [lower isEqual: @"q"])
        return GBPostRatingQuestionable;
    if ([lower isEqual: @"explicit"] or [lower isEqual: @"e"])
        return GBPostRatingExplicit;

    return GBPostRatingUnknown;
}

- (instancetype)initWithJSONDictionary:(OFDictionary<OFString *, id> *)dict
{
    self = [super init];

    // Core fields
    _postID     = $cast(OFNumber, dict[@"id"]).unsignedLongLongValue;
    _md5        = $cast(OFString, dict[@"md5"]);
    _fileURL    = $cast(OFString, dict[@"file_url"]);
    _tagsString = $cast(OFString, dict[@"tags"]);
    _imageName  = $cast(OFString, dict[@"image"]);

    // Nullable extras (treat empty strings as nil)
    id previewURLVal = dict[@"preview_url"];
    if (previewURLVal != nilptr and [previewURLVal isKindOfClass: OFString.class] and ((OFString *)previewURLVal).length > 0) {
        _previewURL = previewURLVal;
    } else {
        _previewURL = nilptr;
    }

    id sampleURLVal = dict[@"sample_url"];
    if (sampleURLVal != nilptr and [sampleURLVal isKindOfClass: OFString.class] and ((OFString *)sampleURLVal).length > 0) {
        _sampleURL = sampleURLVal;
    } else {
        _sampleURL = nilptr;
    }

    id sourceVal = dict[@"source"];
    if (sourceVal != nilptr and [sourceVal isKindOfClass: OFString.class] and ((OFString *)sourceVal).length > 0) {
        _source = sourceVal;
    } else {
        _source = nilptr;
    }

    id createdAtVal = dict[@"created_at"];
    _createdAtRaw = (createdAtVal != nilptr and [createdAtVal isKindOfClass: OFString.class]) ? createdAtVal : nilptr;

    id statusVal = dict[@"status"];
    _status = (statusVal != nilptr and [statusVal isKindOfClass: OFString.class]) ? statusVal : nilptr;

    // Numeric fields
    id widthVal = dict[@"width"];
    _width = (widthVal != nilptr) ? $cast(OFNumber, widthVal).longLongValue : 0;

    id heightVal = dict[@"height"];
    _height = (heightVal != nilptr) ? $cast(OFNumber, heightVal).longLongValue : 0;

    id scoreVal = dict[@"score"];
    _score = (scoreVal != nilptr) ? $cast(OFNumber, scoreVal).longLongValue : 0;

    id changeVal = dict[@"change"];
    _change = (changeVal != nilptr) ? $cast(OFNumber, changeVal).longLongValue : 0;

    id creatorIDVal = dict[@"creator_id"];
    _creatorID = (creatorIDVal != nilptr) ? $cast(OFNumber, creatorIDVal).unsignedLongLongValue : 0;

    id hasChildrenVal = dict[@"has_children"];
    if (hasChildrenVal != nilptr) {
        if ([hasChildrenVal isKindOfClass: OFNumber.class]) {
            _hasChildren = ((OFNumber *)hasChildrenVal).boolValue;
        } else if ([hasChildrenVal isKindOfClass: OFString.class]) {
            _hasChildren = [hasChildrenVal isEqual: @"true"];
        } else {
            _hasChildren = false;
        }
    } else {
        _hasChildren = false;
    }

    id previewWidthVal = dict[@"preview_width"];
    _previewWidth = (previewWidthVal != nilptr) ? $cast(OFNumber, previewWidthVal).longLongValue : 0;

    id previewHeightVal = dict[@"preview_height"];
    _previewHeight = (previewHeightVal != nilptr) ? $cast(OFNumber, previewHeightVal).longLongValue : 0;

    id sampleWidthVal = dict[@"sample_width"];
    _sampleWidth = (sampleWidthVal != nilptr) ? $cast(OFNumber, sampleWidthVal).longLongValue : 0;

    id sampleHeightVal = dict[@"sample_height"];
    _sampleHeight = (sampleHeightVal != nilptr) ? $cast(OFNumber, sampleHeightVal).longLongValue : 0;

    // Rating
    id ratingVal = dict[@"rating"];
    OFString *nillable ratingStr = (ratingVal != nilptr and [ratingVal isKindOfClass: OFString.class]) ? ratingVal : nilptr;
    _rating = parseRating(ratingStr);

    return self;
}

- (OFArray<OFString *> *)tags
{
    return [_tagsString componentsSeparatedByString: @" "];
}

@end

#pragma mark - GBPostsResponse

@implementation GBPostsResponse

- (instancetype)initWithJSONDictionary:(OFDictionary<OFString *, id> *)dict
{
    self = [super init];

    // Parse @attributes
    OFDictionary<OFString *, id> *attrsDict = $cast(OFDictionary, dict[@"@attributes"]);
    _attributes = [[GBAttributes alloc] initWithJSONDictionary: attrsDict];

    // Parse post array (may be nil or missing if count == 0)
    id postVal = dict[@"post"];
    if (postVal == nilptr) {
        _posts = [OFArray array];
    } else {
        OFArray<OFDictionary<OFString *, id> *> *postArray = $cast(OFArray, postVal);
        auto *parsedPosts = [OFMutableArray<GBPost *> arrayWithCapacity: postArray.count];

        for (OFDictionary<OFString *, id> *postDict in postArray) {
            GBPost *post = [[GBPost alloc] initWithJSONDictionary: postDict];
            [parsedPosts addObject: post];
        }

        [parsedPosts makeImmutable];
        _posts = parsedPosts;
    }

    return self;
}

@end
