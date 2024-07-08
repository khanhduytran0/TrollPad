#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "SpringBoard.h"
#import "TPPrefsObserver.h"
#import "UIKitPrivate.h"

#include <assert.h>
#include <dlfcn.h>
#include <stdbool.h>
#include <unistd.h>
#include <dispatch/dispatch.h>

// #define DEBUG_LOG_IDIOM
#ifdef DEBUG_LOG_IDIOM
@interface NSThread(private)
+ (NSString *)ams_symbolicatedCallStackSymbols;
@end
#endif

static TPPrefsObserver* pref;

// Since some methods explicitly check for user interface idiom, I have no better way to fool them
// so I just hook them, set iPad idiom when necessary and set back to iPhone after calling original

static uint16_t forcePadIdiom = 0;

%hook UIDevice
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    // Ever wondered how I obtained those random functions to hook? This is my way
#ifdef DEBUG_LOG_IDIOM
    {
        static NSFileHandle *fileHandle;
        static int left = 100;
        static NSString *tmpOut = @"/var/mobile/Documents/stack.txt";
        static NSString *realOut = @"/var/mobile/Documents/stack_out.txt";
        if (!fileHandle) {
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:tmpOut];
            if (!fileHandle) {
                if (forcePadIdiom > 0) {
                    return UIUserInterfaceIdiomPad;
                } else {
                    return %orig;
                }
            }
            [fileHandle seekToEndOfFile];
        }

        // Log every single call stack to file
        NSString *stackTrace = [NSThread ams_symbolicatedCallStackSymbols];
        [fileHandle writeData:[stackTrace dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (left-- == 0) {
            left = 100;
            [fileHandle closeFile];
            fileHandle = nil;
            [NSFileManager.defaultManager removeItemAtPath:realOut error:nil];
            [NSFileManager.defaultManager moveItemAtPath:tmpOut toPath:realOut error:nil];
        }
        return UIUserInterfaceIdiomPad;
    }
#endif

    if (forcePadIdiom > 0) {
        return UIUserInterfaceIdiomPad;
    } else {
        return %orig;
    }
}
%end

%hook UITraitCollection
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    if (forcePadIdiom > 0) {
        return UIUserInterfaceIdiomPad;
    } else {
        return %orig;
    }
}
%end

/*
%hook SBFloatingDockView
- (CGFloat)contentHeightForBounds:(CGRect)frame {
    if (frame.size.width > frame.size.height) {
        CGFloat width = frame.size.height;
        frame.size.height = frame.size.width;
        frame.size.width = width;
    }
    return %orig;
}
%end
*/

// Fix status bar for the external display
%hook _UIStatusBar
- (void)_prepareVisualProviderIfNeeded {
    UIScreen *screen = self._effectiveTargetScreen;
    if (forcePadIdiom || screen != UIScreen.mainScreen) {
        // For performance reason, we're gonna overwrite userInterfaceIdiom directly
        // userInterfaceIdiom: ldr x0, [x0, #0x8]
        uint64_t *collection = (uint64_t *)(__bridge void *)screen.traitCollection;
        if (collection) {
            collection[1] = UIUserInterfaceIdiomPad;
        }
    }
    %orig;
}
%end
%hook UIStatusBarWindow
- (void)setStatusBar:(UIStatusBar *)statusBar {
    if (self.windowScene.screen._isExternal) {
        statusBar.statusBar.targetScreen = self.windowScene.screen;
    }
    %orig;
}
%end

/*
%hook SBSystemShellExtendedDisplayControllerPolicy
-(void)displayController:(id)arg1 didBeginTransaction:(id)arg2 sceneManager:(id)arg3 displayConfiguration:(id)arg4 deactivationReasons:(unsigned long long)arg5 {
    forcePadIdiom++;
    %orig;
    forcePadIdiom--;
}
%end
*/

// Enable Medusa multitasking (three-dots) button on top
%hook SBFullScreenSwitcherLiveContentOverlayCoordinator
-(void)layoutStateTransitionCoordinator:(id)arg1 transitionDidBeginWithTransitionContext:(id)arg2 {
    forcePadIdiom++;
    %orig;
    forcePadIdiom--;
}
%end
/*
%hook SBShelfLiveContentOverlayCoordinator
-(void)layoutStateTransitionCoordinator:(id)arg1 transitionDidBeginWithTransitionContext:(id)arg2 {
    forcePadIdiom++;
    %orig;
    forcePadIdiom--;
}
%end
*/

// Fix iOS 16 multitasking (split screen, slide over, stage manager)
%hook SBMainSwitcherControllerCoordinator
- (void)_loadContentViewControllerIfNecessaryForWindowScene:(id)scene {
    forcePadIdiom++;
    %orig;
    forcePadIdiom--;
}
%end

// Min width and height are 150, smaller may crash the app
%hook SBSwitcherChamoisLayoutAttributes
- (void)setGridWidths:(NSArray<NSNumber *> *)values {
    NSUInteger maxValue = values.lastObject.unsignedIntValue;
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 150; i < maxValue; i += 20) {
        [array addObject:@(i)];
    }
    [array addObject:@(maxValue)];
    %orig(array);
}

- (void)setGridHeights:(NSArray<NSNumber *> *)values {
    NSUInteger maxValue = values.lastObject.unsignedIntValue;
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 150; i < maxValue; i += 20) {
        [array addObject:@(i)];
    }
    [array addObject:@(maxValue)];
    %orig(array);
}
%end

// Override app limit, I don't think this is healthy for battery, so I won't make it unlimited...
%hook SBSwitcherChamoisSettings
- (NSUInteger)maximumNumberOfAppsOnStage {
    return 5;
}
%end

// FIXME: Is this needed?
%hook SBTraitsPipelineManager
-(id)defaultOrientationAnimationSettingsAnimatable:(BOOL)animatable {
    forcePadIdiom++;
    id result = %orig;
    forcePadIdiom--;
    return result;
}
%end

%hook SBTraitsSceneParticipantDelegate
// Allow upside down
- (BOOL)_isAllowedToHavePortraitUpsideDown {
    return YES;
}

// Fix orientation issue for portrait-only apps
- (NSInteger)_orientationMode {
    forcePadIdiom++;
    NSInteger result = %orig;
    forcePadIdiom--;
    return result;
}
%end

// Workaround for iPhones with home button not being able to open Control Center
%hook CCSControlCenterDefaults
- (NSUInteger)_defaultPresentationGesture {
    return 1;
}
%end
%hook SBHomeGestureSettings
- (BOOL)isHomeGestureEnabled {
    return YES;
}
%end
%hook SBControlCenterController
-(NSUInteger)presentingEdge {
    return 1;
}
%end

%hook SBFluidSwitcherViewController
// Use iPadOS app switching animation instead
- (BOOL)isDevicePad {
    return pref.useiPadAppSwitchingAnimation;
}

// Restore number of grid to 1
/*
- (NSUInteger)numberOfRowsInGridSwitcher {
    return 1;
}
*/
%end

// Fix truncated app name in app switcher
%hook SBAppSwitcherSettings
- (void)setDefaultValues {
    %orig;
    self.spacingBetweenLeadingEdgeAndIcon = 0;
    self.spacingBetweenTrailingEdgeAndLabels = 0;
}
%end

%hook UIApplication
- (id)_defaultSupportedInterfaceOrientations {
    forcePadIdiom++;
    id result = %orig;
    forcePadIdiom--;
    return result;
}
%end

// Allow upside down Home Screen
%hook SBHomeScreenViewController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return %orig | UIInterfaceOrientationMaskPortraitUpsideDown;
}
%end

// Allow upside down Lock Screen
%hook SBCoverSheetPrimarySlidingViewController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return %orig | UIInterfaceOrientationMaskPortraitUpsideDown;
}
%end

// The following hooks are taken from various sources, please refer to tweaks that enable Slide Over.
%hook SpringBoard
- (NSInteger)homeScreenRotationStyle {
    return pref.allowLandscapeHomeScreen ? 1 : %orig;
}
%end

%hook SBMedusaConfigurationUsageMetric
- (BOOL)_isFloatingActive {
    return YES;
}
%end

%hook SBPlatformController
- (BOOL)isHomeGestureEnabled {
    return YES;
}

- (NSInteger)medusaCapabilities {
    return 2;
}
%end

%hook SBApplication
- (BOOL)isMedusaCapable {
    return pref.forceEnableMedusaForLandscapeOnlyApps ||
        (self.info.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) != 0;
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

// Unlock external display support for MDC versions
int hookedExtDisplayEnabledFunc() {
    // clang forgets to PAC this function, so we need this ugly line
    int hack = 0; if (hack) { abort(); }

    return 1;
}

// Bypass Keyboard & Mouse requirement
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
    // Unlock external display support for MDC versions
    void *sbFoundationHandle = dlopen("/System/Library/PrivateFrameworks/SpringBoardFoundation.framework/SpringBoardFoundation", RTLD_GLOBAL);
    // iOS 16.0
    void *extDisplayEnabledFunc = dlsym(sbFoundationHandle, "SBChamoisExternalDisplayControllerIsEnabled");
    if (!extDisplayEnabledFunc) {
        // iOS 16.1.x
        extDisplayEnabledFunc = dlsym(sbFoundationHandle, "SBFIsChamoisExternalDisplayControllerAvailable");
    }
    if (extDisplayEnabledFunc) {
        MSHookFunction((void *)extDisplayEnabledFunc, (void *)hookedExtDisplayEnabledFunc, NULL);
    }

    pref = [TPPrefsObserver new];
}
