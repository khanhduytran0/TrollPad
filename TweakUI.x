#import "UIKitPrivate.h"
#import <rootless.h>

static BOOL forcePadKBIdiom = YES, showShortcutButtonsOnKeyboard;

// Unlock iPadOS keyboard
UIUserInterfaceIdiom UIKeyboardGetSafeDeviceIdiom();
%hookf(UIUserInterfaceIdiom, UIKeyboardGetSafeDeviceIdiom) {
    return forcePadKBIdiom ? UIUserInterfaceIdiomPad : %orig;
}

// Allow UIHoverGestureRecognizer and pointer interaction on iPhone
%hook UIPointerInteraction
- (void)_updateInteractionIsEnabled {
    UIView *view = self.view;
    BOOL enabled = self.enabled; // && view.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad
    for(id<_UIPointerInteractionDriver> driver in self.drivers) {
        driver.view = enabled ? view : nil;
    }
    // to keep it fast, ivar offset is cached for later direct access
    static ptrdiff_t ivarOff = 0;
    if(!ivarOff) {
        ivarOff = ivar_getOffset(class_getInstanceVariable(self.class, "_observingPresentationNotification"));
    }

    BOOL *observingPresentationNotification = (BOOL *)((uint64_t)(__bridge void *)self + ivarOff);
    if(!enabled && *observingPresentationNotification) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIPresentationControllerPresentationTransitionWillBeginNotification object:nil];
        *observingPresentationNotification = NO;
    }
}
%end

// Fix bottom padding
%hook UIKeyboardImpl
+ (UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSUInteger)arg1 inputMode:(id)arg2 {
    forcePadKBIdiom = NO;
    UIEdgeInsets result = %orig;
    forcePadKBIdiom = YES;
    return result;
}
%end

// Fix bottom padding when floating
%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect bounds = %orig;
    if (!UIDevice._hasHomeButton && UIKeyboardImpl.isFloating) {
        bounds.origin.y = -25;
    } else {
        bounds.origin.y = 0;
    }
    return bounds;
}
%end

%hook UISystemInputAssistantViewController
// Fix predictive bar not occupying entire area
- (CGFloat)_centerViewWidthForTraitCollection:(id)tc interfaceOrientation:(UIInterfaceOrientation)orientation {
    forcePadKBIdiom = NO;
    NSInteger result = %orig;
    forcePadKBIdiom = YES;
    return result;
}

// Show assistant buttons when enabled
- (void)setInputAssistantButtonItemsForResponder:(id)item {
    forcePadKBIdiom = showShortcutButtonsOnKeyboard;
    %orig;
    forcePadKBIdiom = YES;
}
%end

%hook UIInputWindowControllerHosting
- (UIEdgeInsets)_inputViewPadding {
    UIEdgeInsets result = %orig;
    if (!UIDevice._hasHomeButton && UIKeyboardImpl.isFloating) {
        result.bottom -= 25;
    }
    return result;
}
%end

static void loadPrefs() {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@(ROOT_PATH("/var/mobile/Library/Preferences/com.kdt.trollpad.plist"))];
	showShortcutButtonsOnKeyboard = [[settings objectForKey:@"TPShowShortcutButtonsOnKeyboard"] boolValue];
}

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.kdt.trollpad/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
