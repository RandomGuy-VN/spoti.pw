// Ad blocking counters and preference accessors.
#import "Core/SGCore.h"
#import "AdBlock.h"
#import <os/lock.h>

static NSString *const kAdBlockCountsKey = @"spotifyglass.adblock.counts";
static os_unfair_lock sg_counterLock = OS_UNFAIR_LOCK_INIT;
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

BOOL SGAdBlockPlaybackEnabled(void) {
    return SGAdBlockEnabled() && SGEnabled(SGKeyAdBlockPlayback);
}

NSArray<NSString *> *SGBlockedAdCategories(void) {
    return @[
        @"Audio & Video",
        @"Banners & Sponsored",
        @"Hubs & Shelves",
        @"Popups & Upsells"
    ];
}

static NSMutableDictionary<NSString *, NSNumber *> *countsLocked(void) {
    if (!sg_adCounts) {
        NSDictionary *saved = [NSUserDefaults.standardUserDefaults dictionaryForKey:kAdBlockCountsKey];
        sg_adCounts = saved ? [saved mutableCopy] : [NSMutableDictionary dictionary];
        NSSet<NSString *> *valid = [NSSet setWithArray:SGBlockedAdCategories()];
        for (NSString *key in sg_adCounts.allKeys) {
            if (![valid containsObject:key]) [sg_adCounts removeObjectForKey:key];
        }
    }
    return sg_adCounts;
}

static void scheduleSaveLocked(void) {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("pw.spoti.adblock.save", DISPATCH_QUEUE_SERIAL);
    });
    NSDictionary *snapshot = [sg_adCounts copy];
    dispatch_async(queue, ^{
        [NSUserDefaults.standardUserDefaults setObject:snapshot forKey:kAdBlockCountsKey];
    });
}

void SGRecordBlockedAds(NSString *category, NSUInteger count) {
    if (!category || count == 0) return;
    os_unfair_lock_lock(&sg_counterLock);
    NSMutableDictionary *counts = countsLocked();
    NSUInteger current = [counts[category] unsignedIntegerValue];
    counts[category] = @(current + count);
    scheduleSaveLocked();
    os_unfair_lock_unlock(&sg_counterLock);
}

void SGRecordBlockedAd(NSString *category) {
    SGRecordBlockedAds(category, 1);
}

NSUInteger SGBlockedAdCount(NSString *category) {
    if (!category) return SGBlockedAdTotalCount();
    os_unfair_lock_lock(&sg_counterLock);
    NSUInteger count = [countsLocked()[category] unsignedIntegerValue];
    os_unfair_lock_unlock(&sg_counterLock);
    return count;
}

NSUInteger SGBlockedAdTotalCount(void) {
    os_unfair_lock_lock(&sg_counterLock);
    NSDictionary *counts = countsLocked();
    NSUInteger total = 0;
    for (NSNumber *val in counts.allValues) {
        total += val.unsignedIntegerValue;
    }
    os_unfair_lock_unlock(&sg_counterLock);
    return total;
}

void SGResetBlockedAds(void) {
    os_unfair_lock_lock(&sg_counterLock);
    sg_adCounts = [NSMutableDictionary dictionary];
    scheduleSaveLocked();
    os_unfair_lock_unlock(&sg_counterLock);
}
