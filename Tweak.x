#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "TPPrefsObserver.h"

#include <assert.h>
#include <stdbool.h>
#include <unistd.h>
#include <xpc/xpc.h>
#include <dispatch/dispatch.h>

static TPPrefsObserver* pref;

// Since some methods explicitly check for user interface idiom, I have no better way to fool them
// so I just hook them, set iPad idiom when necessary and set back to iPhone after calling original
static UIUserInterfaceIdiom overrideIdiom = UIUserInterfaceIdiomPhone;
%hook UIDevice
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    return overrideIdiom;
}
%end

// Enable Medusa decoration (three-dots button) on top
%hook SBFullScreenSwitcherSceneLiveContentOverlay
- (void)configureWithWorkspaceEntity:(id)arg1 referenceFrame:(CGRect)arg2 contentOrientation:(NSInteger)arg3 containerOrientation:(long long)arg4 layoutRole:(NSInteger)arg5 sbsDisplayLayoutRole:(NSInteger)arg6 spaceConfiguration:(NSInteger)arg7 floatingConfiguration:(NSInteger)arg8 hasClassicAppOrientationMismatch:(BOOL)arg9 sizingPolicy:(NSInteger)arg10 {
    overrideIdiom = UIUserInterfaceIdiomPad;
    %orig;
    overrideIdiom = UIUserInterfaceIdiomPhone;
}
%end

// Fix iOS 16 multitasking (split screen, slide over, stage manager)
%hook SBMainSwitcherControllerCoordinator
- (void)_loadContentViewControllerIfNecessaryForWindowScene:(id)scene {
    overrideIdiom = UIUserInterfaceIdiomPad;
    %orig;
    overrideIdiom = UIUserInterfaceIdiomPhone;
}
%end

// FIXME: Is this needed?
%hook SBTraitsPipelineManager
-(id)defaultOrientationAnimationSettingsAnimatable:(BOOL)animatable {
    overrideIdiom = UIUserInterfaceIdiomPad;
    id result = %orig;
    overrideIdiom = UIUserInterfaceIdiomPhone;
    return result;
}
%end

// Workaround for iPhones with home button not being able to open Control Center
%hook BSPlatform
- (NSInteger)homeButtonType {
     return 2;
}
%end
%hook SBControlCenterController
-(NSUInteger)presentingEdge {
    return 1;
}
%end

// Use iPadOS app switching animation instead
%hook SBFluidSwitcherViewController
- (BOOL)isDevicePad {
    return pref.useiPadAppSwitchingAnimation;
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

// Force iPad app switcher, otherwise it will be broken
%hook SBAppSwitcherSettings
- (NSInteger)effectiveSwitcherStyle {
    return 2;
}
%end

#pragma mark - Bypass Keyboard & Mouse requirement
@interface SBExternalDisplayRuntimeAvailabilitySettings : NSObject
@property(nonatomic, assign) BOOL requirePointer, requireHardwareKeyboard;
@end
%hook SBExternalDisplayRuntimeAvailabilitySettings
- (void)setDefaultValues {
    self.requireHardwareKeyboard = NO;
    self.requirePointer = NO;
}
%end

BOOL MGGetBoolAnswer(NSString* property);
%hookf(BOOL, MGGetBoolAnswer, NSString* property) {
    // Hook ipad, DeviceSupportsEnhancedMultitasking
    if ([property isEqualToString:@"DeviceSupportsEnhancedMultitasking"]) {
        return YES;
    }
    return %orig;
}

%ctor {
    pref = [TPPrefsObserver new];
}
