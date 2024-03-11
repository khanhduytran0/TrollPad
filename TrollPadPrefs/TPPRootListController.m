#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import "TPPRootListController.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/com.kdt.trollpad.plist"

@implementation TPPRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
    }
    return _specifiers;
}

- (void)openDisplayArrangement {
    UIViewController *controller = [NSClassFromString(@"DBSArrangementViewController") new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)openSourceCode {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/khanhduytran0/TrollPad"] options:@{} completionHandler:nil];
}

- (void)openTwitter {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://twitter.com/TranKha50277352"] options:@{} completionHandler:nil];
}

- (void)respring {
    NSURL *returnURL = [NSURL URLWithString:@"prefs:root=TrollPad"];
    SBSRelaunchAction *action = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:0 targetURL:returnURL];
    [[NSClassFromString(@"FBSSystemService") sharedService] sendActions:[NSSet setWithObject:action] withResult:nil];
}

@end
