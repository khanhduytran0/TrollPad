#import <UIKit/UIKit.h>

@interface SBApplicationInfo : NSObject
@property(assign, nonatomic) UIInterfaceOrientationMask supportedInterfaceOrientations;
@end

@interface SBApplication : NSObject
@property(nonatomic, readonly) SBApplicationInfo *info;
@end

@interface SBAppSwitcherSettings : NSObject
@property(assign) CGFloat spacingBetweenLeadingEdgeAndIcon, spacingBetweenTrailingEdgeAndLabels;
@end

@interface SBExternalDisplayRuntimeAvailabilitySettings : NSObject
@property(nonatomic, assign) BOOL requirePointer, requireHardwareKeyboard;
@end

@interface SBFluidSwitcherItemContainer : UIView
- (BOOL)isResizingAllowed;
@end

@interface SBAppResizeGrabberView : UIView
@end

@interface SBWindowScene : UIWindowScene
- (BOOL)isExternalDisplayWindowScene;
@end
