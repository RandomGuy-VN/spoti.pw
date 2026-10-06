// Ad blocking counters and preference accessors.
// Keeps thread-safe tallies of blocked ads per category in NSUserDefaults.
#import "Core/SGCore.h"
#import "AdBlock.h"

static NSString *const kAdBlockCountsKey = @"spotifyglass.adblock.counts";
static NSMutableDictionary<NSString *, NSNumber *> *sg_adCounts;

BOOL SGAdBlockEnabled(void) {
    return SGEnabled(SGKeyAdBlockMaster);
}

BOOL SGAdBlockAudioVideoEnabled(void) {
    return SGAdBlockEnabled() && SGEnabled(SGKeyAdBlockAudioVideo);
}

BOOL SGAdBlockBannersEnabled(void) {
    return SGAdBlockEnabled() && SGEnabled(SGKeyAdBlockBanners);
}

BOOL SGAdBlockHubsEnabled(void) {
    return SGAdBlockEnabled() && SGEnabled(SGKeyAdBlockHubs);
}

BOOL SGAdBlockUpsellsEnabled(void) {
    return SGAdBlockEnabled() && SGEnabled(SGKeyAdBlockUpsells);
}

BOOL SGAdBlockNetworkEnabled(void) {
    return SGAdBlockEnabled() && SGEnabled(SGKeyAdBlockNetwork);
}

BOOL SGAdBlockPremiumSpoofEnabled(void) {
    return SGAdBlockEnabled() && SGEnabled(SGKeyAdBlockPremiumSpoof);
}

NSArray<NSString *> *SGBlockedAdCategories(void) {
    return @[
        @"Audio & Video",
        @"Banners & Sponsored",
        @"Hubs & Shelves",
        @"Popups & Upsells",
        @"Network Endpoints"
    ];
}

static NSMutableDictionary<NSString *, NSNumber *> *countsLocked(void) {
    if (!sg_adCounts) {
        NSDictionary *saved = [NSUserDefaults.standardUserDefaults dictionaryForKey:kAdBlockCountsKey];
        sg_adCounts = saved ? [saved mutableCopy] : [NSMutableDictionary dictionary];
        NSSet<NSString *> *valid = [NSSet setWithArray:SGBlockedAdCategories()];
        for (NSString *key in sg_adCounts.allKeys) {
            if (![valid containsObject:key]) sg_adCounts[key] = nil;
        }
    }
    return sg_adCounts;
}

void SGRecordBlockedAd(NSString *category) {
    if (!category) return;
    @synchronized (NSUserDefaults.standardUserDefaults) {
        NSMutableDictionary *counts = countsLocked();
        NSUInteger current = [counts[category] unsignedIntegerValue];
        counts[category] = @(current + 1);
        [NSUserDefaults.standardUserDefaults setObject:counts forKey:kAdBlockCountsKey];
    }
}

NSUInteger SGBlockedAdCount(NSString *category) {
    if (!category) return SGBlockedAdTotalCount();
    @synchronized (NSUserDefaults.standardUserDefaults) {
        return [countsLocked()[category] unsignedIntegerValue];
    }
}

NSUInteger SGBlockedAdTotalCount(void) {
    @synchronized (NSUserDefaults.standardUserDefaults) {
        NSDictionary *counts = countsLocked();
        NSUInteger total = 0;
        for (NSNumber *val in counts.allValues) {
            total += val.unsignedIntegerValue;
        }
        return total;
    }
}

void SGResetBlockedAds(void) {
    @synchronized (NSUserDefaults.standardUserDefaults) {
        sg_adCounts = [NSMutableDictionary dictionary];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kAdBlockCountsKey];
    }
}
