#import <Preferences/PSListController.h>

@interface TPPRootListController : PSListController

@end

// Respring
@interface SBSRelaunchAction : NSObject
+ (SBSRelaunchAction *)actionWithReason:(NSString *)reason options:(NSUInteger)options targetURL:(NSURL *)url;
@end

@interface FBSSystemService : NSObject
+ (FBSSystemService *)sharedService;
- (void)sendActions:(NSSet *)actions withResult:(id *)result;
@end
