#import "common.h"

$assume_nonnil_begin

/// Simple multi-task progress indicator for terminal output.
@interface ProgressBar : OFObject

@property(readonly, nonatomic) size_t totalTasks;
@property(readonly, nonatomic) size_t completedTasks;
@property(readonly, nonatomic) size_t activeTasks;
@property(readonly, nonatomic) uint64_t totalBytes;
@property(readonly, nonatomic) uint64_t downloadedBytes;
@property(assign, nonatomic) bool showLabels;

- (instancetype)initWithTotalTasks:(size_t)total;
- (instancetype)initWithTotalTasks:(size_t)total showLabels:(bool)showLabels;

- (void)startTaskWithLabel:(OFString *nillable)label;
- (void)setExpectedBytes:(uint64_t)bytes forLabel:(OFString *nillable)label;
- (void)addReceivedBytes:(uint64_t)bytes forLabel:(OFString *nillable)label;
- (void)finishTaskWithLabel:(OFString *nillable)label;
- (void)completeWithTotal:(size_t)finalTotalTasks;

@end

$assume_nonnil_end
