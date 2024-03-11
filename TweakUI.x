#import <UIKit/UIKit.h>
#import <rootless.h>

static BOOL forcePadKBIdiom = YES, showShortcutButtonsOnKeyboard;

@interface UIDevice(private)
+ (BOOL)_hasHomeButton;
@end
@interface UIKeyboardImpl : NSObject
+ (BOOL)isFloating;
@end

// Unlock iPadOS keyboard
UIUserInterfaceIdiom UIKeyboardGetSafeDeviceIdiom();
%hookf(UIUserInterfaceIdiom, UIKeyboardGetSafeDeviceIdiom) {
    return forcePadKBIdiom ? UIUserInterfaceIdiomPad : %orig;
}

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
