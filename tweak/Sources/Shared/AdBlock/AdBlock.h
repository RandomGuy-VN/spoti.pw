// Ad blocking: suppresses audio and in-stream video ads, sponsored playlist headers and banners,
// Hubs promotional shelves and cards, ClientMessagingPlatform upsells and fullscreen takeovers,
// and unlocks unlimited skips and on-demand playback via remote configuration flags.
#import <UIKit/UIKit.h>

#define SGKeyAdBlockMaster         @"spotifyglass.adblock.enabled"
#define SGKeyAdBlockAudioVideo     @"spotifyglass.adblock.audioVideo"
#define SGKeyAdBlockBanners        @"spotifyglass.adblock.banners"
#define SGKeyAdBlockHubs           @"spotifyglass.adblock.hubs"
#define SGKeyAdBlockUpsells        @"spotifyglass.adblock.upsells"
#define SGKeyAdBlockPlayback       @"spotifyglass.adblock.playback"

// Accessors (master switch gates sub-switches; unset switches default to ON)
BOOL SGAdBlockEnabled(void);
BOOL SGAdBlockAudioVideoEnabled(void);
BOOL SGAdBlockBannersEnabled(void);
BOOL SGAdBlockHubsEnabled(void);
BOOL SGAdBlockUpsellsEnabled(void);
BOOL SGAdBlockPlaybackEnabled(void);

// Blocked counters and statistics
void SGRecordBlockedAd(NSString *category);
void SGRecordBlockedAds(NSString *category, NSUInteger count);
NSUInteger SGBlockedAdCount(NSString *category);
NSUInteger SGBlockedAdTotalCount(void);
NSArray<NSString *> *SGBlockedAdCategories(void);
void SGResetBlockedAds(void);

// Mod Settings page
UIViewController *SGAdBlockSettingsPage(void);
