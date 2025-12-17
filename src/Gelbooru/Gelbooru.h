#import "common.h"

$assume_nonnil_begin

enum GBPostRating: uint8_t {
    GBPostRatingUnknown = 0,
    GBPostRatingSafe,
    GBPostRatingQuestionable,
    GBPostRatingExplicit
};

/// attributes { limit, offset, count }
@interface GBAttributes : OFObject
@property (readonly) uint64_t limit;   // 0..=100 :contentReference[oaicite:4]{index=4}
@property (readonly) uint64_t offset;  // index of first item in this page :contentReference[oaicite:5]{index=5}
@property (readonly) uint64_t count;   // total matching items :contentReference[oaicite:6]{index=6}

- (instancetype)initWithJSONDictionary: (OFDictionary<OFString *, id> *)dict;
@end

/// A single post entry (core fields are reliably present in many clients)
@interface GBPost : OFObject
// Core fields :contentReference[oaicite:7]{index=7}
@property (readonly) uint64_t postID;
@property (readonly) OFString *md5;
@property (readonly) OFString *fileURL;     // "file_url" :contentReference[oaicite:8]{index=8}
@property (readonly) OFString *tagsString;  // space-separated "tags" :contentReference[oaicite:9]{index=9}
@property (readonly) OFString *imageName;   // "image" original filename :contentReference[oaicite:10]{index=10}

// Frequently available extras in Gelbooru-style JSON :contentReference[oaicite:11]{index=11}
@property (readonly) OFString *nillable previewURL;    // "preview_url"
@property (readonly) OFString *nillable sampleURL;     // "sample_url"
@property (readonly) int64_t width;                     // "width"
@property (readonly) int64_t height;                    // "height"
@property (readonly) int64_t score;                     // "score"
@property (readonly) OFString *nillable source;        // "source"
@property (readonly) OFString *nillable createdAtRaw;  // "created_at" (string in many responses)
@property (readonly) int64_t change;                    // "change" (often unix-ish)
@property (readonly) uint64_t creatorID;                // "creator_id"
@property (readonly) bool hasChildren;                  // "has_children"
@property (readonly) OFString *nillable status;        // "status"
@property (readonly) int64_t previewWidth;              // "preview_width"
@property (readonly) int64_t previewHeight;             // "preview_height"
@property (readonly) int64_t sampleWidth;               // "sample_width"
@property (readonly) int64_t sampleHeight;              // "sample_height"
@property (readonly) enum GBPostRating rating;               // "rating"

/// Convenience: split tagsString on spaces.
@property (readonly) OFArray<OFString *> *tags;

- (instancetype)initWithJSONDictionary: (OFDictionary<OFString *, id> *)dict;
@end

/// Top-level response: { attributes: {...}, post: [...] }.
/// Note: `post` may be missing/NULL when count==0 or page out of range. :contentReference[oaicite:12]{index=12}
@interface GBPostsResponse : OFObject
@property (readonly) GBAttributes *attributes;
@property (readonly) OFArray<GBPost *> *posts;

- (instancetype)initWithJSONDictionary: (OFDictionary<OFString *, id> *)dict;
@end

$assume_nonnil_end
