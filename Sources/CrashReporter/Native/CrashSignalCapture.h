#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// ObjC façade over POSIX signal pending-file capture (visible to Swift via the pod module).
@interface CrashSignalCapture : NSObject

+ (BOOL)installWithPendingPath:(NSString *)pendingPath;
+ (nullable NSString *)consumePendingAtPath:(NSString *)pendingPath;

@end

NS_ASSUME_NONNULL_END
