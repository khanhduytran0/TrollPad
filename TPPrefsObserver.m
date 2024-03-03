#import "TPPrefsObserver.h"

@implementation TPPrefsObserver
- (instancetype)init {
    self = [super init];
    [self observeKey:@"TPAllowLandscapeHomeScreen"];
    [self observeKey:@"TPUseiPadAppSwitchingAnimation"];
    // Fetch keys
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
    return self;
}

- (void)observeKey:(NSString *)key {
    [NSUserDefaults.standardUserDefaults addObserver:self
        forKeyPath:key
        options:NSKeyValueObservingOptionNew
        context:NULL];
}

 - (void)observeValueForKeyPath:(NSString *) 
keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    self.allowLandscapeHomeScreen = [defaults boolForKey:@"TPAllowLandscapeHomeScreen"];
    self.useiPadAppSwitchingAnimation = [defaults boolForKey:@"TPUseiPadAppSwitchingAnimation"];
}
@end
