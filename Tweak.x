#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <assert.h>
#include <stdbool.h>
#include <unistd.h>
#include <xpc/xpc.h>
#include <dispatch/dispatch.h>
#import <objc/runtime.h>

// Do this to pass most iPad checks
UIUserInterfaceIdiom userInterfaceIdiom = UIUserInterfaceIdiomPad;
@implementation UIDevice(hook)
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    return userInterfaceIdiom;
}
@end

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    static BOOL called = NO;
    called = !called;
    if (called) {
        return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
    } else {
        return %orig;
    }
}
%end

// The following hooks are taken from various sources, please refer to tweaks that enable Slide Over.
@interface SpringBoard : NSObject
@end
@implementation SpringBoard(hook)
- (NSInteger)homeScreenRotationStyle {
	return 2;
}
@end

@interface SBMedusaConfigurationUsageMetric : NSObject
@end
@implementation SBMedusaConfigurationUsageMetric(hook)
- (BOOL)_isFloatingActive {
	return YES;
}
@end

@interface SBPlatformController : NSObject
@end
@implementation SBPlatformController(hook)
-(NSInteger)medusaCapabilities {
    return 2;
}
@end

@interface SBApplication : NSObject
@end
@implementation SBApplication(hook)
-(BOOL)isMedusaCapable {
    return YES;
}

- (BOOL)_supportsApplicationType:(int)arg1 {
	return YES;
}
@end

@interface SBMainWorkspace : NSObject
@end
@implementation SBMainWorkspace(hook)
- (BOOL)isMedusaEnabled {
    return YES;
}
@end

@interface SBFloatingDockController : NSObject
@end
@implementation SBFloatingDockController(hook)
+ (BOOL)isFloatingDockSupported {
    return YES;
}
@end
