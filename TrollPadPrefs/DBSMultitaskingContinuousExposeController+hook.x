#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DBSMultitaskingContinuousExposeController : PSListController
@end

%hook DBSMultitaskingContinuousExposeController
- (NSArray *)specifiers {
    NSArray *specifiers = %orig;
	 for (PSSpecifier *specifier in specifiers) {
        NSString *key = specifier.properties[@"key"];
        if ([key hasPrefix:@"SBChamois"]) {
            specifier.properties[@"key"] = [@"TP" stringByAppendingString:key];
        }
    }
    return specifiers;
}
%end

%hook DBSContinuousExposeLayoutTableViewCell
- (UIView *)dockOptionView {
    UIView *result = %orig;
    result.alpha = 0.5f;
    result.userInteractionEnabled = NO;
    return result;
}
%end
