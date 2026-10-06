// Ad blocking: suppresses audio and in-stream video ads, sponsored playlist headers and banners,
// Hubs promotional shelves and cards, ClientMessagingPlatform upsells and fullscreen takeovers,
// advertising network requests, and unlocks unlimited skips and on-demand playback via product state.
#import <UIKit/UIKit.h>

#define SGKeyAdBlockMaster         @"spotifyglass.adblock.enabled"
#define SGKeyAdBlockAudioVideo     @"spotifyglass.adblock.audioVideo"
#define SGKeyAdBlockBanners        @"spotifyglass.adblock.banners"
#define SGKeyAdBlockHubs           @"spotifyglass.adblock.hubs"
#define SGKeyAdBlockUpsells        @"spotifyglass.adblock.upsells"
#define SGKeyAdBlockNetwork        @"spotifyglass.adblock.network"
#define SGKeyAdBlockPremiumSpoof   @"spotifyglass.adblock.premiumSpoof"

// Accessors (master switch gates sub-switches; unset switches default to ON)
BOOL SGAdBlockEnabled(void);
BOOL SGAdBlockAudioVideoEnabled(void);
BOOL SGAdBlockBannersEnabled(void);
BOOL SGAdBlockHubsEnabled(void);
BOOL SGAdBlockUpsellsEnabled(void);
BOOL SGAdBlockNetworkEnabled(void);
BOOL SGAdBlockPremiumSpoofEnabled(void);

// Blocked counters and statistics
void SGRecordBlockedAd(NSString *category);
NSUInteger SGBlockedAdCount(NSString *category);
NSUInteger SGBlockedAdTotalCount(void);
NSArray<NSString *> *SGBlockedAdCategories(void);
void SGResetBlockedAds(void);

// Mod Settings page
UIViewController *SGAdBlockSettingsPage(void);
