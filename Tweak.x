#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <assert.h>
#include <stdbool.h>
#include <unistd.h>
#include <xpc/xpc.h>
#include <dispatch/dispatch.h>
#import <objc/runtime.h>

// Hook this to avoid real keys from being set
%hook NSUserDefaults
- (void)setBool:(BOOL)value forKey:(NSString *)key {
    if ([key isEqualToString:@"SBChamoisHideDock"]) {
        // Never ever set this to YES, as it is known to respring loop
        %orig(NO, key);
    } else if ([key hasPrefix:@"SBChamois"]) {
        %orig(value, [NSString stringWithFormat:@"TrollPad_%@", key]);
    } else {
        %orig;
    }
}

- (BOOL)boolForKey:(NSString *)key {
    if ([key hasPrefix:@"SBChamois"]) {
        return %orig([NSString stringWithFormat:@"TrollPad_%@", key]);
    } else {
        return %orig;
    }
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)key options:(NSKeyValueObservingOptions)options context:(void *)context {
    if ([key hasPrefix:@"SBChamois"]) {
        return %orig(observer, [NSString stringWithFormat:@"TrollPad_%@", key], options, context);
    } else {
        return %orig;
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)key context:(void *)context {
    if ([key hasPrefix:@"SBChamois"]) {
        return %orig(observer, [NSString stringWithFormat:@"TrollPad_%@", key], context);
    } else {
        return %orig;
    }
}
%end

// Do this to pass most iPad checks
%hook UIDevice
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    return UIUserInterfaceIdiomPad;
}
%end

/*
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return %c(_UIStatusBarVisualProvider_Split58);
}
%end
*/

// Workaround for iPhones with home button not being able to open Control Center
%hook BSPlatform
- (NSInteger)homeButtonType {
    return 2;
}
%end

// The following hooks are taken from various sources, please refer to tweaks that enable Slide Over.
%hook SpringBoard
- (NSInteger)homeScreenRotationStyle {
	return 2;
}
%end

%hook SBMedusaConfigurationUsageMetric
- (BOOL)_isFloatingActive {
	return YES;
}
%end

%hook SBPlatformController
-(NSInteger)medusaCapabilities {
    return 2;
}
%end

%hook SBApplication
-(BOOL)isMedusaCapable {
    return YES;
}

- (BOOL)_supportsApplicationType:(int)arg1 {
	return YES;
}
%end

%hook SBMainWorkspace
- (BOOL)isMedusaEnabled {
    return YES;
}
%end

%hook SBFloatingDockController
+ (BOOL)isFloatingDockSupported {
    return YES;
}
%end
