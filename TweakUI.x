#import <UIKit/UIKit.h>

@interface UIDevice(private)
+ (BOOL)_hasHomeButton;
@end
@interface UIKeyboardImpl : NSObject
+ (BOOL)isFloating;
@end

// Unlock iPadOS keyboard
static BOOL forcePadKBIdiom, isUnderDockTweakInstalled = YES;
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
- (instancetype)init {
    isUnderDockTweakInstalled = %c(UnderDockStackView) != nil;
    return %orig;
}

// Fix predictive bar not occupying entire area
- (CGFloat)_centerViewWidthForTraitCollection:(id)tc interfaceOrientation:(UIInterfaceOrientation)orientation {
    forcePadKBIdiom = NO;
    NSInteger result = %orig;
    forcePadKBIdiom = YES;
    return result;
}

// Hide assistant buttons when UnderDock tweak is present
- (void)setInputAssistantButtonItemsForResponder:(id)item {
    forcePadKBIdiom = !isUnderDockTweakInstalled;
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
