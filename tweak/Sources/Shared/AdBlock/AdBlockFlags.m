// Forces Spotify's remote-config flags for advertising, campaigns, upsells,
// and capping to off, and on-demand playback flags to on.
#import "Core/SGCore.h"
#import "AdBlock.h"

static id forcedFlag(NSString *key) {
    if (!key || !SGAdBlockEnabled()) return nil;

    if (SGAdBlockAudioVideoEnabled()) {
        if ([key isEqualToString:@"ads"]) return @NO;
        if ([key isEqualToString:@"enable_ads"]) return @NO;
        if ([key isEqualToString:@"enable_audio_ads"]) return @NO;
        if ([key isEqualToString:@"enable_video_ads"]) return @NO;
        if ([key isEqualToString:@"audio-ad-frequency"]) return @0;
        if ([key isEqualToString:@"video-ad-frequency"]) return @0;
        if ([key isEqualToString:@"ab-ad-player-targeting"]) return @0;
        if ([key isEqualToString:@"allow-advertising-id-transmission"]) return @0;
        if ([key isEqualToString:@"restrict-advertising-id-transmission"]) return @1;
    }

    if (SGAdBlockBannersEnabled()) {
        if ([key isEqualToString:@"enable_display_ads"]) return @NO;
        if ([key isEqualToString:@"enable_search_ad"]) return @NO;
        if ([key isEqualToString:@"enable_search_ads"]) return @NO;
        if ([key isEqualToString:@"enable_search_banner_ad"]) return @NO;
        if ([key isEqualToString:@"enable_search_banner_ads"]) return @NO;
        if ([key isEqualToString:@"enable_search_sponsored_ad"]) return @NO;
        if ([key isEqualToString:@"enable_search_sponsored_ads"]) return @NO;
        if ([key isEqualToString:@"enable_home_ad"]) return @NO;
        if ([key isEqualToString:@"enable_home_ads"]) return @NO;
        if ([key isEqualToString:@"enable_home_banner_ad"]) return @NO;
        if ([key isEqualToString:@"enable_home_banner_ads"]) return @NO;
        if ([key isEqualToString:@"enable_home_sponsored_ad"]) return @NO;
        if ([key isEqualToString:@"enable_home_sponsored_ads"]) return @NO;
    }

    if (SGAdBlockUpsellsEnabled()) {
        if ([key isEqualToString:@"enable_premium_upsell"]) return @NO;
        if ([key isEqualToString:@"enable_upsell"]) return @NO;
        if ([key isEqualToString:@"show_upsell"]) return @NO;
        if ([key isEqualToString:@"show_premium_upsell"]) return @NO;
        if ([key isEqualToString:@"enable_campaigns"]) return @NO;
        if ([key isEqualToString:@"enable_promotions"]) return @NO;
        if ([key isEqualToString:@"enable_search_upsell"]) return @NO;
        if ([key isEqualToString:@"enable_home_upsell"]) return @NO;
        if ([key isEqualToString:@"ios-feature-shuffletoggleupsell.is_enabled_pt2"]) return @NO;
        if ([key isEqualToString:@"ios-feature-shuffletoggleupsell.linear_upsell_new_style_experiment_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-feature-shuffletoggleupsell.play_modes_upsell_new_style_experiment_enabled"]) return @NO;
    }

    if (SGAdBlockPlaybackEnabled()) {
        if ([key isEqualToString:@"on-demand"]) return @YES;
        if ([key isEqualToString:@"unrestricted"]) return @YES;
        if ([key isEqualToString:@"shuffle-eligible"]) return @YES;
        if ([key isEqualToString:@"enable_common_capping"]) return @NO;
        if ([key isEqualToString:@"enable_pns_common_capping"]) return @NO;
        if ([key isEqualToString:@"enable_pick_and_shuffle_common_capping"]) return @NO;
        if ([key isEqualToString:@"enable_pick_and_shuffle_dynamic_cap"]) return @NO;
        if ([key isEqualToString:@"enable_free_on_demand_experiment"]) return @NO;
        if ([key isEqualToString:@"enable_playback_timeout_service"]) return @NO;
        if ([key isEqualToString:@"enable_playback_timeout_error_ui"]) return @NO;
        if ([key isEqualToString:@"crossfade_enabled"]) return @YES;
        if ([key isEqualToString:@"automix_enabled"]) return @YES;
    }

    return nil;
}

__attribute__((constructor)) static void registerAdBlockFlagForcer(void) {
    SGFlagForcer forcer = ^id(NSString *key) { return forcedFlag(key); };
    SGRegisterFlagForcer(NO, forcer, forcer);
}
