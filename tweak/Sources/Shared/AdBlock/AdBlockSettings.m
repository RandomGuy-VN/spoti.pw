// Ad blocker settings page in Mod Settings.
#import "Settings/SGModPage.h"
#import "AdBlock.h"

static SGModSection *countersSection(void) {
    NSMutableArray<SGModRow *> *counts = [NSMutableArray array];
    for (NSString *category in SGBlockedAdCategories()) {
        [counts addObject:SGStatRow(category, ^NSString *{
            return @(SGBlockedAdCount(category)).stringValue;
        })];
    }
    [counts addObject:SGStatRow(@"Total", ^NSString *{
        return @(SGBlockedAdTotalCount()).stringValue;
    })];
    [counts addObject:SGActionRow(@"Reset ad counters", nil, ^{
        SGResetBlockedAds();
    })];
    return SGSection(@"Ads blocked so far", counts);
}

UIViewController *SGAdBlockSettingsPage(void) {
    return [[SGModPage alloc] initWithTitle:@"Ad blocker" intro:SGRestartNote sections:@[
        SGSection(@"Ad blocker", @[
            SGWithSymbol(SGSwitchRow(@"Block ads", @"Master switch to enable all ad blocking features", SGKeyAdBlockMaster), @"shield.checkerboard"),
        ]),
        SGSection(@"Surfaces", @[
            SGWithSymbol(SGSwitchRow(@"Audio & video ads", @"Block in-stream audio and video ads", SGKeyAdBlockAudioVideo), @"speaker.slash"),
            SGWithSymbol(SGSwitchRow(@"Banners & sponsored content", @"Hide sponsored playlist headers, cards and brand banners", SGKeyAdBlockBanners), @"rectangle.badge.xmark"),
            SGWithSymbol(SGSwitchRow(@"Clutter & ad shelves", @"Filter out promotional shelves and cards in Home and Search", SGKeyAdBlockHubs), @"square.grid.2x2"),
            SGWithSymbol(SGSwitchRow(@"Popups & upsells", @"Block fullscreen takeovers, bottom sheets and upsell dialogs", SGKeyAdBlockUpsells), @"xmark.diamond"),
            SGWithSymbol(SGSwitchRow(@"Block ad network requests", @"Intercept and drop requests to Spotify advertising endpoints", SGKeyAdBlockNetwork), @"network.slash"),
        ]),
        SGSection(@"Playback", @[
            SGWithSymbol(SGSwitchRow(@"Unlimited skips & on-demand", @"Unlock track selection, seeking, and remove the 6-skip hourly limit", SGKeyAdBlockPremiumSpoof), @"forward.fill"),
        ]),
        countersSection(),
    ] footer:nil];
}
