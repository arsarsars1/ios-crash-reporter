#import "CrashSignalCapture.h"
#import "crash_signal_capture.h"

#import <stdlib.h>

@implementation CrashSignalCapture

+ (BOOL)installWithPendingPath:(NSString *)pendingPath {
    return crashreporter_signal_install(pendingPath.fileSystemRepresentation) ? YES : NO;
}

+ (nullable NSString *)consumePendingAtPath:(NSString *)pendingPath {
    char *raw = crashreporter_signal_consume(pendingPath.fileSystemRepresentation);
    if (raw == NULL) {
        return nil;
    }
    NSString *result = [NSString stringWithUTF8String:raw];
    free(raw);
    return result;
}

@end
