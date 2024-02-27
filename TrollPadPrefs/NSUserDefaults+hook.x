#import <Foundation/Foundation.h>

// Hook this to avoid real keys from being set
%hook NSUserDefaults
- (void)setBool:(BOOL)value forKey:(NSString *)key {
    if ([key isEqualToString:@"SBChamoisHideDock"]) {
        // Never ever set this to YES, as it is known to respring loop
        %orig(NO, key);
    } else if ([key hasPrefix:@"SBChamois"]) {
        %orig(value, [NSString stringWithFormat:@"TP%@", key]);
    } else {
        %orig;
    }
}

- (BOOL)boolForKey:(NSString *)key {
    if ([key hasPrefix:@"SBChamois"]) {
        return %orig([NSString stringWithFormat:@"TP%@", key]);
    } else {
        return %orig;
    }
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)key options:(NSKeyValueObservingOptions)options context:(void *)context {
    if ([key hasPrefix:@"SBChamois"]) {
        %orig(observer, [NSString stringWithFormat:@"TP%@", key], options, context);
    } else {
        %orig;
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)key context:(void *)context {
    if ([key hasPrefix:@"SBChamois"]) {
        %orig(observer, [NSString stringWithFormat:@"TP%@", key], context);
    } else {
        %orig;
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)key {
    if ([key hasPrefix:@"SBChamois"]) {
        %orig(observer, [NSString stringWithFormat:@"TP%@", key]);
    } else {
        %orig;
    }
}
%end
