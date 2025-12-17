#import "Gelbooru/ProgressBar.h"

#include <stdatomic.h>
#include <stdio.h>

@implementation ProgressBar {
    _Atomic(size_t) _completed;
    size_t _total;
    _Atomic(uint64_t) _downloadedBytes;
    _Atomic(uint64_t) _expectedBytes;
    OFMutableArray<OFString *> *_active;
    OFMutableDictionary<OFString *, OFNumber *> *_expectedByLabel;
    OFTimer *nillable _timer;
    size_t _spinnerIndex;
    bool _finished;
}

- (instancetype)initWithTotalTasks:(size_t)total
{
    return [self initWithTotalTasks:total showLabels:true];
}

- (instancetype)initWithTotalTasks:(size_t)total showLabels:(bool)showLabels
{
    self = [super init];
    _total = total ? total : 1; // avoid divide-by-zero in display
    _showLabels = showLabels;
    atomic_store(&_completed, 0);
    atomic_store(&_downloadedBytes, 0);
    atomic_store(&_expectedBytes, 0);
    _active = [OFMutableArray array];
    _expectedByLabel = [OFMutableDictionary dictionary];
    _spinnerIndex = 0;
    _finished = false;

    _timer = [OFTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(tick:)
                                              object:nilptr
                                             repeats:true];
    return self;
}

- (size_t)totalTasks { return _total; }
- (size_t)completedTasks { return atomic_load(&_completed); }
- (size_t)activeTasks { @synchronized(self) { return _active.count; } }
- (uint64_t)totalBytes { return atomic_load(&_expectedBytes); }
- (uint64_t)downloadedBytes { return atomic_load(&_downloadedBytes); }

- (void)startTaskWithLabel:(OFString *nillable)label
{
    @synchronized(self) {
        if (label) [_active addObject:(OFString *)label];
    }
    [self render];
}

- (void)setExpectedBytes:(uint64_t)bytes forLabel:(OFString *nillable)label
{
    if (label == nilptr) return;
    @synchronized(self) {
        OFString *const nonNullLabel = (OFString *)label;
        OFNumber *prev = _expectedByLabel[nonNullLabel];
        uint64_t prevVal = prev ? prev.unsignedLongLongValue : 0;
        if (bytes != prevVal) {
            if (bytes > prevVal)
                atomic_fetch_add(&_expectedBytes, bytes - prevVal);
            else
                atomic_fetch_sub(&_expectedBytes, prevVal - bytes);
            _expectedByLabel[nonNullLabel] = [OFNumber numberWithUnsignedLongLong:bytes];
        }
    }
}

- (void)addReceivedBytes:(uint64_t)bytes forLabel:(OFString *nillable)label
{
    (void)label;
    atomic_fetch_add(&_downloadedBytes, bytes);
    [self render];
}

- (void)finishTaskWithLabel:(OFString *nillable)label
{
    @synchronized(self) {
        if (label) {
            OFString *const nonNullLabel = (OFString *)label;
            size_t idx = [_active indexOfObject:nonNullLabel];
            if (idx != OFNotFound)
                [_active removeObjectAtIndex:idx];
            [_expectedByLabel removeObjectForKey:nonNullLabel];
        }
        atomic_fetch_add(&_completed, 1);
        if (atomic_load(&_completed) >= _total)
            _finished = true;
    }
    [self render];
}

- (void)completeWithTotal:(size_t)finalTotal
{
    @synchronized(self) {
        _total = finalTotal ? finalTotal : atomic_load(&_completed);
        _finished = true;
    }
    [self render];
    [self newline];
}

- (void)tick:(OFTimer *)timer
{
    [self render];
}

#pragma mark - Rendering

- (void)render
{
    @synchronized(self) {
        if (_finished and _timer) {
            [_timer invalidate];
            _timer = nilptr;
        }

        static const char spinnerChars[] = { '|', '/', '-', '\\' };
        char spinner = spinnerChars[_spinnerIndex++ % (sizeof(spinnerChars) / sizeof(spinnerChars[0]))];
        size_t completed = atomic_load(&_completed);
        size_t activeCount = _active.count;
        size_t total = _total;
        uint64_t downloaded = atomic_load(&_downloadedBytes);
        uint64_t expected = atomic_load(&_expectedBytes);

        double ratio;
        if (expected > 0)
            ratio = (double)downloaded / (double)expected;
        else
            ratio = (total > 0) ? ((double)completed / (double)total) : 0.0;
        if (ratio > 1.0) ratio = 1.0;
        if (ratio < 0.0) ratio = 0.0;

        static const size_t barWidth = 30;
        size_t filled = (size_t)(ratio * (double)barWidth);
        if (filled > barWidth) filled = barWidth;

        OFMutableString *bar = [OFMutableString stringWithString:@"["];
        for (size_t i = 0; i < filled; i++) [bar appendString:@"="];
        if (filled < barWidth) {
            [bar appendString:@">"];
            for (size_t i = filled + 1; i < barWidth; i++) [bar appendString:@" "];
        }
        [bar appendString:@"]"];

        OFMutableString *line = [OFMutableString stringWithString:@"\r\033[K"];
        [line appendFormat:@"%c %@ %3.0f%%  tasks %zu/%zu active:%zu",
              spinner, bar, ratio * 100.0, completed, total, activeCount];

        OFString *downloadedStr = [self.class formatBytes:downloaded];
        OFString *remainingStr;
        if (expected > downloaded) {
            remainingStr = [self.class formatBytes:(expected - downloaded)];
        } else if (expected > 0) {
            remainingStr = @"0B";
        } else {
            remainingStr = @"?";
        }
        [line appendFormat:@"  downloaded: %@  remaining: %@", downloadedStr, remainingStr];

        if (_showLabels and activeCount > 0) {
            size_t showCount = (activeCount < 3u) ? activeCount : 3u;
            OFMutableArray<OFString *> *display = [OFMutableArray arrayWithCapacity:showCount];
            for (size_t i = 0; i < showCount; i++)
                [display addObject:_active[i]];
            [line appendFormat:@"  [%@%@]",
                   [display componentsJoinedByString:@", "],
                   (activeCount > showCount) ? @"..." : @""];
        }

        [OFStdOut writeString:line];
        fflush(stdout);
    }
}

- (void)newline
{
    [OFStdOut writeString:@"\n"];
    fflush(stdout);
}

+ (OFString *)formatBytes:(uint64_t)bytes
{
    double b = (double)bytes;
    if (b >= 1024.0 * 1024.0 * 1024.0)
        return [OFString stringWithFormat:@"%.2f GiB", b / (1024.0 * 1024.0 * 1024.0)];
    if (b >= 1024.0 * 1024.0)
        return [OFString stringWithFormat:@"%.2f MiB", b / (1024.0 * 1024.0)];
    if (b >= 1024.0)
        return [OFString stringWithFormat:@"%.2f KiB", b / 1024.0];
    return [OFString stringWithFormat:@"%llu B", (unsigned long long)bytes];
}

@end
