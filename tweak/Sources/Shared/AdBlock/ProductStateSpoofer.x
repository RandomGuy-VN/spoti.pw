// Product state spoofing: hooks SPTCoreProductState to report a Premium license
// and unlock on-demand playback, seeking, and unlimited skips.
#import "Core/SGCore.h"
#import "AdBlock.h"

static NSString *forcedValueForKey(NSString *key) {
    if (!key) return nil;
    if ([key isEqualToString:@"type"]) return @"premium";
    if ([key isEqualToString:@"catalogue"]) return @"premium";
    if ([key isEqualToString:@"product"]) return @"premium";
    if ([key isEqualToString:@"name"]) return @"Spotify Premium";
    if ([key isEqualToString:@"player-license"]) return @"premium";
    if ([key isEqualToString:@"player-license-v2"]) return @"premium";
    if ([key isEqualToString:@"financial-product"]) return @"pr:premium,tc:0";

    if ([key isEqualToString:@"ads"]) return @"0";
    if ([key isEqualToString:@"ab-ad-player-targeting"]) return @"0";
    if ([key isEqualToString:@"allow-advertising-id-transmission"]) return @"0";
    if ([key isEqualToString:@"restrict-advertising-id-transmission"]) return @"1";
    if ([key isEqualToString:@"audio-ad-frequency"]) return @"0";
    if ([key isEqualToString:@"video-ad-frequency"]) return @"0";
    if ([key isEqualToString:@"ad-formats"]) return @"";

    if ([key isEqualToString:@"on-demand"]) return @"1";
    if ([key isEqualToString:@"unrestricted"]) return @"1";
    if ([key isEqualToString:@"shuffle-eligible"]) return @"1";
    if ([key isEqualToString:@"social-connect"]) return @"1";
    if ([key isEqualToString:@"tracks-in-collection-enabled"]) return @"1";

    if ([key isEqualToString:@"streaming-rules"]) return @"";
    if ([key isEqualToString:@"previous-streaming-rules"]) return @"";
    if ([key isEqualToString:@"high-bitrate"]) return @"1";
    if ([key isEqualToString:@"shuffle"]) return @"0";
    if ([key isEqualToString:@"shuffle-mode"]) return @"0";
    if ([key isEqualToString:@"pick-and-shuffle"]) return @"0";

    return nil;
}

static NSDictionary *rewriteProductDict(NSDictionary *dict) {
    if (!dict) return dict;
    NSMutableDictionary *mutable = [dict mutableCopy];

    [mutable removeObjectForKey:@"payment-state"];
    [mutable removeObjectForKey:@"on-demand-trial"];
    [mutable removeObjectForKey:@"on-demand-trial-in-progress"];
    [mutable removeObjectForKey:@"smart-shuffle"];

    for (NSString *key in dict) {
        if (![key isKindOfClass:NSString.class]) continue;
        NSString *forced = forcedValueForKey(key);
        if (forced) {
            mutable[key] = forced;
        }
    }

    static NSString *const seedKeys[] = {
        @"type", @"catalogue", @"product", @"ads", @"on-demand",
        @"unrestricted", @"shuffle-eligible", @"player-license", @"player-license-v2"
    };
    for (size_t i = 0; i < sizeof(seedKeys) / sizeof(seedKeys[0]); i++) {
        NSString *k = seedKeys[i];
        if (!mutable[k]) {
            mutable[k] = forcedValueForKey(k);
        }
    }

    return mutable;
}

@interface SPTCoreProductState : NSObject
- (NSString *)stringForKey:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;
- (NSDictionary *)values;
- (NSDictionary *)originalValues;
- (void)setOriginalValues:(NSDictionary *)dict;
- (void)setOverrides:(NSDictionary *)dict;
- (id)initWithValuesDict:(NSDictionary *)dict scheduler:(void *)scheduler;
@end

%hook SPTCoreProductState

- (NSString *)stringForKey:(NSString *)key {
    if (SGAdBlockPremiumSpoofEnabled()) {
        NSString *forced = forcedValueForKey(key);
        if (forced) return forced;
    }
    return %orig(key);
}

- (id)objectForKeyedSubscript:(NSString *)key {
    if (SGAdBlockPremiumSpoofEnabled()) {
        NSString *forced = forcedValueForKey(key);
        if (forced) return forced;
    }
    return %orig(key);
}

- (NSDictionary *)values {
    NSDictionary *orig = %orig;
    if (SGAdBlockPremiumSpoofEnabled()) {
        return rewriteProductDict(orig);
    }
    return orig;
}

- (NSDictionary *)originalValues {
    NSDictionary *orig = %orig;
    if (SGAdBlockPremiumSpoofEnabled()) {
        return rewriteProductDict(orig);
    }
    return orig;
}

- (void)setOriginalValues:(NSDictionary *)dict {
    if (SGAdBlockPremiumSpoofEnabled()) {
        %orig(rewriteProductDict(dict));
        return;
    }
    %orig(dict);
}

- (void)setOverrides:(NSDictionary *)dict {
    if (SGAdBlockPremiumSpoofEnabled()) {
        %orig(rewriteProductDict(dict));
        return;
    }
    %orig(dict);
}

- (id)initWithValuesDict:(NSDictionary *)dict scheduler:(void *)scheduler {
    if (SGAdBlockPremiumSpoofEnabled()) {
        return %orig(rewriteProductDict(dict), scheduler);
    }
    return %orig(dict, scheduler);
}

%end

%ctor {
    if (SGAdBlockPremiumSpoofEnabled()) {
        %init;
        SGRequireClasses(@[@"SPTCoreProductState"]);
    }
}
