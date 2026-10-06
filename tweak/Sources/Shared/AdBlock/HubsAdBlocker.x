// Hubs ad blocking: strips advertisement, sponsor, and promotional shelf
// components from HubFramework JSON models before rendering.
#import "Core/SGCore.h"
#import "AdBlock.h"

static BOOL containsAdKeyword(NSString *str) {
    if (!str || !str.length) return NO;
    NSString *lower = str.lowercaseString;
    static NSString *const keywords[] = {
        @"sponsored", @"upsell", @"campaign", @"promoted", @"premium-upsell",
        @"billboard", @"interstitial", @"marquee", @"leavebehind", @"leave-behind",
        @"displayad", @"display-ad", @"fullbleed", @"full-bleed", @"leaderboard",
        @"advertisement", @"sponsor", @"native-ad", @"mobile-ads", @"search-ad",
        @"home-ad", @"sponsored-content", @"sponsored-ad", @"ad-card",
        @"native-ad-home-shelf", @"sponsored-shelf", @"sponsored-row",
        @"ad-shelf", @"ad-row", @"sponsored-item", @"ad-item", @"upgrade-component",
        @"mobile-display-ad-card", @"mobile-ads-display-ad-element"
    };
    for (size_t i = 0; i < sizeof(keywords) / sizeof(keywords[0]); i++) {
        if ([lower containsString:keywords[i]]) return YES;
    }
    return NO;
}

static BOOL isAdComponent(NSDictionary *comp) {
    if (![comp isKindOfClass:NSDictionary.class]) return NO;
    id componentVal = comp[@"component"];
    if ([componentVal isKindOfClass:NSDictionary.class]) {
        NSString *ns = componentVal[@"namespace"];
        NSString *name = componentVal[@"name"];
        if (containsAdKeyword(ns) || containsAdKeyword(name)) return YES;
    } else if ([componentVal isKindOfClass:NSString.class]) {
        if (containsAdKeyword(componentVal)) return YES;
    }

    NSString *ident = comp[@"id"];
    if (containsAdKeyword(ident)) return YES;

    NSString *type = comp[@"type"];
    if (containsAdKeyword(type)) return YES;

    id meta = comp[@"metadata"];
    if ([meta isKindOfClass:NSDictionary.class]) {
        if ([meta[@"ad"] boolValue] || [meta[@"is_ad"] boolValue] || [meta[@"is_sponsored"] boolValue]) return YES;
        for (NSString *k in meta) {
            if (containsAdKeyword(k)) return YES;
        }
    }

    id logging = comp[@"logging"];
    if ([logging isKindOfClass:NSDictionary.class]) {
        if (containsAdKeyword(logging[@"type"])) return YES;
        for (NSString *k in logging) {
            if (containsAdKeyword(k)) return YES;
        }
    }

    id custom = comp[@"custom"];
    if ([custom isKindOfClass:NSDictionary.class]) {
        for (NSString *k in custom) {
            if (containsAdKeyword(k)) return YES;
        }
    }

    return NO;
}

static NSArray *filterComponents(NSArray *components, NSUInteger *blockedCount) {
    if (![components isKindOfClass:NSArray.class]) return components;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:components.count];
    for (id item in components) {
        if ([item isKindOfClass:NSDictionary.class]) {
            if (isAdComponent(item)) {
                if (blockedCount) (*blockedCount)++;
                continue;
            }
            NSMutableDictionary *mutableItem = [item mutableCopy];
            if (mutableItem[@"children"]) mutableItem[@"children"] = filterComponents(mutableItem[@"children"], blockedCount);
            if (mutableItem[@"rows"]) mutableItem[@"rows"] = filterComponents(mutableItem[@"rows"], blockedCount);
            if (mutableItem[@"body"]) mutableItem[@"body"] = filterComponents(mutableItem[@"body"], blockedCount);
            [result addObject:mutableItem];
        } else {
            [result addObject:item];
        }
    }
    return result;
}

static NSDictionary *filterHubsDictionary(NSDictionary *dict) {
    if (![dict isKindOfClass:NSDictionary.class]) return dict;
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    NSUInteger blocked = 0;

    if ([mutableDict[@"body"] isKindOfClass:NSArray.class]) {
        mutableDict[@"body"] = filterComponents(mutableDict[@"body"], &blocked);
    }
    if ([mutableDict[@"header"] isKindOfClass:NSDictionary.class]) {
        if (isAdComponent(mutableDict[@"header"])) {
            [mutableDict removeObjectForKey:@"header"];
            blocked++;
        } else {
            NSMutableDictionary *header = [mutableDict[@"header"] mutableCopy];
            if (header[@"children"]) {
                header[@"children"] = filterComponents(header[@"children"], &blocked);
            }
            mutableDict[@"header"] = header;
        }
    }
    if ([mutableDict[@"overlays"] isKindOfClass:NSArray.class]) {
        mutableDict[@"overlays"] = filterComponents(mutableDict[@"overlays"], &blocked);
    }
    if ([mutableDict[@"sections"] isKindOfClass:NSArray.class]) {
        mutableDict[@"sections"] = filterComponents(mutableDict[@"sections"], &blocked);
    }

    if (blocked > 0) {
        for (NSUInteger i = 0; i < blocked; i++) {
            SGRecordBlockedAd(@"Hubs & Shelves");
        }
    }
    return mutableDict;
}

%hook HUBViewModelBuilderImplementation
- (void)addJSONDictionary:(NSDictionary *)dictionary {
    if (!SGAdBlockHubsEnabled() || !dictionary) {
        %orig(dictionary);
        return;
    }
    %orig(filterHubsDictionary(dictionary));
}
%end

%ctor {
    if (SGAdBlockHubsEnabled()) {
        %init;
        SGRequireClasses(@[@"HUBViewModelBuilderImplementation"]);
    }
}
