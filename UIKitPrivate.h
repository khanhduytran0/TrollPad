#import <UIKit/UIKit.h>

@interface UIDevice(private)
+ (BOOL)_hasHomeButton;
@end
@interface UIKeyboardImpl : NSObject
+ (BOOL)isFloating;
@end

@interface UIScreen(private)
- (BOOL)isUserInterfaceIdiomPad;
- (BOOL)_isExternal;
- (void)_setUserInterfaceIdiom:(UIUserInterfaceIdiom)idiom;
@end

@interface UIStatusBarWindow : UIWindow
@end

@interface _UIStatusBar
- (void)setTargetScreen:(UIScreen *)screen;
- (UIScreen *)targetScreen;
- (UIScreen *)_effectiveTargetScreen;
@end

@interface UIStatusBar
- (_UIStatusBar *)statusBar;
@end

@interface UIView(private)
- (UIScreen *)_screen;
@end
