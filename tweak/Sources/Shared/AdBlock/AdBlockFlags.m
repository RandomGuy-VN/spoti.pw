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
        if ([key isEqualToString:@"ios-adsnowplaying-embeddednpv-impl.enable_ads_on_podcast"]) return @NO;
        if ([key isEqualToString:@"ios-adsnowplaying-embeddednpv-impl.embedded_ad_html_element_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-feature-adonappopen.frequency_capping_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-betamax-sdkintegration.kub_adap_on_ads_enabled"]) return @NO;
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
        if ([key isEqualToString:@"ios-nowplaying-scroll-impl.unified_leavebehind_npv_scroll_music_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-nowplaying-scroll-impl.unified_leavebehind_npv_scroll_podcast_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-adsembedded-embeddedctaelements-impl.small_ad_row_variant_enabled"]) return @NO;
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
        if ([key isEqualToString:@"ios-content-windowing.enable_track_preview_upsell"]) return @NO;
        if ([key isEqualToString:@"ios-feature-bluejay.schedule_prompt_capped_upsell_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-feature-magpie.upsellability_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-feature-nowplaying-modes.video_first_shuffle_upsell_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-feature-nowplaying-modes.video_first_skip_limit_upsell"]) return @NO;
        if ([key isEqualToString:@"ios-jam-freehostedjamsupsell-impl.free_hosted_jams_upsell_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-jam-freeusershuffleupsellsheetpage-impl.free_user_shuffle_upsell_sheet_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-jam-freeuserskipupsellpage-impl.free_user_skip_upsell_sheet_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-messaging-reduceinterventions-impl.enable_message_reinvent_free_n_p_v_suggestions_upsell"]) return @NO;
        if ([key isEqualToString:@"ios-reinventfree-contextualupsellpremiumpromo-impl.is_promo_cta_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-reinventfree-contextualupsellpremiumpromo-impl.show_time_cap_upsell_with_premium_badge"]) return @NO;
        if ([key isEqualToString:@"ios-reinventfree-controllerui-impl.enable_video_time_cap_upsell"]) return @NO;
        if ([key isEqualToString:@"ios-reinventfree-controllerui-impl.enable_video_time_cap_upsell_on_search"]) return @NO;
        if ([key isEqualToString:@"ios-reinventfree-downloadupsellpage-impl.contextual_page_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-reinventfree-timecappivot-impl.music_video_upsell_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-settings-mediaqualitypageplugin-impl.is_gbb_upsell_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-settings-mediaqualitypageplugin-impl.should_show_pigeon_upsell"]) return @NO;
        if ([key isEqualToString:@"ios-system-listeningparties.preview_ended_upsell_enabled"]) return @NO;
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
        if ([key isEqualToString:@"ios-feature-lyrics.enable_common_capping"]) return @NO;
        if ([key isEqualToString:@"ios-feature-bluejay.capping_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-feature-magpie.soft_cap_enabled"]) return @NO;
        if ([key isEqualToString:@"ios-jam-queueintegrationimpl.enable_jam_capped_premium_queue_banner"]) return @NO;
        if ([key isEqualToString:@"ios-feature-reinventfree-ondemandui-impl.enable_premium_panel"]) return @NO;
        if ([key isEqualToString:@"ios-feature-freeondemand.enable_free_on_demand_experiment"]) return @NO;
    }

    return nil;
}

__attribute__((constructor)) static void registerAdBlockFlagForcer(void) {
    SGFlagForcer forcer = ^id(NSString *key) { return forcedFlag(key); };
    SGRegisterFlagForcer(NO, forcer, forcer);
}
