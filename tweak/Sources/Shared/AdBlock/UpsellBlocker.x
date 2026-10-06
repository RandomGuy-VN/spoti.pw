// Upsells and promotional modal blocking: drops fullscreen takeovers,
// promotional bottom sheets, upsell banner elements, and Encore upsell dialogs.
#import "Core/SGCore.h"
#import "AdBlock.h"
#import <UIKit/UIKit.h>

@interface _TtC37Messaging_ClientMessagingPlatformImpl33FullscreenContainerViewController : UIViewController
@end

@interface _TtC37Messaging_ClientMessagingPlatformImpl28ModalContainerViewController : UIViewController
@end

@interface _TtC37Messaging_ClientMessagingPlatformImpl52ClientMessagingPlatformBottomSheetPageViewController : UIViewController
@end

@interface _TtC37Messaging_ClientMessagingPlatformImpl33ClientMessagingPlatformBannerView : UIView
@end

@interface _TtC18Upsells_ElementKitP33_11E507536F1F78CA735FB7F17658749321UpsellBannerElementUI : UIView
@end

@interface _TtC24Jam_QueueIntegrationImpl28PremiumUpsellBannerElementUI : UIView
@end

@interface _TtC19ReinventFree_ECMKit25PremiumUpsellControlPanel : UIView
@end

@interface SPTEncorePopUpPresenter : NSObject
- (void)presentPopUp:(id)popUp;
@end

// Upsell services
%hook _TtC19Upsells_ServiceImpl18UpsellsServiceImpl
- (void)load {
    if (SGAdBlockUpsellsEnabled()) {
        SGLog(@"adblock: suppressed UpsellsServiceImpl.load");
        SGRecordBlockedAd(@"Popups & Upsells");
        return;
    }
    %orig;
}
%end

%hook _TtC31PremiumUpsell_UpsellServiceImpl17UpsellServiceImpl
- (void)load {
    if (SGAdBlockUpsellsEnabled()) {
        SGLog(@"adblock: suppressed Premium UpsellServiceImpl.load");
        SGRecordBlockedAd(@"Popups & Upsells");
        return;
    }
    %orig;
}
%end

%hook _TtC45ReinventFree_ContextualUpsellPremiumPromoImpl39ContextualUpsellPremiumPromoServiceImpl
- (void)load {
    if (SGAdBlockUpsellsEnabled()) {
        SGLog(@"adblock: suppressed ContextualUpsellPremiumPromoServiceImpl.load");
        SGRecordBlockedAd(@"Popups & Upsells");
        return;
    }
    %orig;
}
%end

%hook _TtC40Referrals_ReferralsUpsellCardElementImpl37ReferralsUpsellCardElementServiceImpl
- (void)load {
    if (SGAdBlockUpsellsEnabled()) {
        SGLog(@"adblock: suppressed ReferralsUpsellCardElementServiceImpl.load");
        SGRecordBlockedAd(@"Popups & Upsells");
        return;
    }
    %orig;
}
%end

%hook _TtC31ReinventFree_DownloadUpsellImpl21DownloadUpsellService
- (void)load {
    if (SGAdBlockUpsellsEnabled()) {
        SGLog(@"adblock: suppressed DownloadUpsellService.load");
        return;
    }
    %orig;
}
%end

%hook _TtC28Jam_FreeHostedJamsUpsellImpl31FreeHostedJamsUpsellServiceImpl
- (void)load {
    if (SGAdBlockUpsellsEnabled()) {
        SGLog(@"adblock: suppressed FreeHostedJamsUpsellServiceImpl.load");
        return;
    }
    %orig;
}
%end

%hook _TtC30Jam_FreeUserSkipUpsellPageImpl29FreeUserSkipUpsellPageService
- (void)load {
    if (SGAdBlockUpsellsEnabled()) {
        SGLog(@"adblock: suppressed FreeUserSkipUpsellPageService.load");
        return;
    }
    %orig;
}
%end

// Client Messaging Platform containers
%hook _TtC37Messaging_ClientMessagingPlatformImpl33FullscreenContainerViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if (SGAdBlockUpsellsEnabled()) {
        self.view.hidden = YES;
        self.view.alpha = 0;
        self.view.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        });
        SGRecordBlockedAd(@"Popups & Upsells");
    }
}
%end

%hook _TtC37Messaging_ClientMessagingPlatformImpl28ModalContainerViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if (SGAdBlockUpsellsEnabled()) {
        self.view.hidden = YES;
        self.view.alpha = 0;
        self.view.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        });
        SGRecordBlockedAd(@"Popups & Upsells");
    }
}
%end

%hook _TtC37Messaging_ClientMessagingPlatformImpl52ClientMessagingPlatformBottomSheetPageViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if (SGAdBlockUpsellsEnabled()) {
        self.view.hidden = YES;
        self.view.alpha = 0;
        self.view.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        });
        SGRecordBlockedAd(@"Popups & Upsells");
    }
}
%end

// In-view banner elements
%hook _TtC37Messaging_ClientMessagingPlatformImpl33ClientMessagingPlatformBannerView
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockUpsellsEnabled()) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        if (self.superview) {
            [self removeFromSuperview];
            SGRecordBlockedAd(@"Popups & Upsells");
        }
    }
}
%end

%hook _TtC18Upsells_ElementKitP33_11E507536F1F78CA735FB7F17658749321UpsellBannerElementUI
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockUpsellsEnabled()) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        if (self.superview) {
            [self removeFromSuperview];
            SGRecordBlockedAd(@"Popups & Upsells");
        }
    }
}
%end

%hook _TtC24Jam_QueueIntegrationImpl28PremiumUpsellBannerElementUI
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockUpsellsEnabled()) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        if (self.superview) {
            [self removeFromSuperview];
            SGRecordBlockedAd(@"Popups & Upsells");
        }
    }
}
%end

%hook _TtC19ReinventFree_ECMKit25PremiumUpsellControlPanel
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockUpsellsEnabled()) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        if (self.superview) {
            [self removeFromSuperview];
            SGRecordBlockedAd(@"Popups & Upsells");
        }
    }
}
%end

// Legacy and Encore popups
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
static BOOL isUpsellDialog(id popUp) {
    if (!popUp) return NO;
    NSString *title = nil;
    NSString *desc = nil;
    if ([popUp respondsToSelector:@selector(model)]) {
        id model = [popUp performSelector:@selector(model)];
        if ([model respondsToSelector:@selector(title)]) title = [model performSelector:@selector(title)];
        if ([model respondsToSelector:@selector(descriptionText)]) desc = [model performSelector:@selector(descriptionText)];
    }
    if (!title && [popUp respondsToSelector:@selector(title)]) title = [popUp performSelector:@selector(title)];
    if (!desc && [popUp respondsToSelector:@selector(descriptionText)]) desc = [popUp performSelector:@selector(descriptionText)];
    if (!desc && [popUp respondsToSelector:@selector(body)]) desc = [popUp performSelector:@selector(body)];

    if ([title containsString:@"spoti.pw"] || [title containsString:@"spotifyglass"]) return NO;

    static NSString *const keywords[] = {
        @"premium", @"upgrade", @"subscribe", @"subscription",
        @"listening without limits", @"unlimited skips",
        @"play the songs you love", @"go premium", @"free account",
        @"ad-free", @"ad free", @"get premium", @"start premium",
        @"paywall", @"free tier", @"limited listening"
    };
    NSString *lowerTitle = title.lowercaseString;
    NSString *lowerDesc = desc.lowercaseString;
    for (size_t i = 0; i < sizeof(keywords) / sizeof(keywords[0]); i++) {
        if ((lowerTitle && [lowerTitle containsString:keywords[i]]) ||
            (lowerDesc && [lowerDesc containsString:keywords[i]])) {
            return YES;
        }
    }
    return NO;
}
#pragma clang diagnostic pop

%hook SPTEncorePopUpPresenter
- (void)presentPopUp:(id)popUp {
    if (SGAdBlockUpsellsEnabled() && isUpsellDialog(popUp)) {
        SGLog(@"adblock: suppressed upsell popup dialog");
        SGRecordBlockedAd(@"Popups & Upsells");
        return;
    }
    %orig;
}
%end

%ctor {
    if (SGAdBlockUpsellsEnabled()) {
        %init;
    }
}
