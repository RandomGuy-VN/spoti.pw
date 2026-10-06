// Banners and sponsored content blocking: suppresses sponsored playlist headers,
// now-playing bar attachments, leavebehind cards, and in-feed advertisement elements.
#import "Core/SGCore.h"
#import "AdBlock.h"
#import <UIKit/UIKit.h>

@interface _TtC18AdsPlatform_ECMKit37AdsSponsoredPlaylistHeaderCentralView : UIView
@end

@interface _TtC22AdsPlatform_ElementKit15HtmlAdElementUI : UIView
@end

@interface _TtC19AdsPlatform_DSAImpl11DSAMainView : UIView
@end

%hook _TtC35AdsEmbedded_AdsSponsoredContextImpl30AdsSponsoredContextServiceImpl
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed AdsSponsoredContextServiceImpl.load");
        SGRecordBlockedAd(@"Banners & Sponsored");
        return;
    }
    %orig;
}
%end

%hook _TtC48AdsEmbedded_AdsSponsoredContextNPBAttachmentImpl43AdsSponsoredContextNPBAttachmentServiceImpl
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed AdsSponsoredContextNPBAttachmentServiceImpl.load");
        SGRecordBlockedAd(@"Banners & Sponsored");
        return;
    }
    %orig;
}
%end

%hook _TtC42AdsEmbedded_AdsSponsoredPlaylistHeaderImpl37AdsSponsoredPlaylistHeaderServiceImpl
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed AdsSponsoredPlaylistHeaderServiceImpl.load");
        SGRecordBlockedAd(@"Banners & Sponsored");
        return;
    }
    %orig;
}
%end

%hook _TtC36AdsStandalone_LeavebehindAdsBaseImpl25LeavebehindAdsBaseService
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed LeavebehindAdsBaseService.load");
        SGRecordBlockedAd(@"Banners & Sponsored");
        return;
    }
    %orig;
}
%end

%hook _TtC36AdsStandalone_LeavebehindAdsBaseImpl33LeavebehindAdsBaseInternalService
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed LeavebehindAdsBaseInternalService.load");
        SGRecordBlockedAd(@"Banners & Sponsored");
        return;
    }
    %orig;
}
%end

%hook _TtC35AdsEmbedded_EmbeddedCTAElementsImpl30EmbeddedCTAElementsServiceImpl
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed EmbeddedCTAElementsServiceImpl.load");
        SGRecordBlockedAd(@"Banners & Sponsored");
        return;
    }
    %orig;
}
%end

%hook _TtC36AdsEmbedded_EmbeddedAdControllerImpl31EmbeddedAdControllerServiceImpl
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed EmbeddedAdControllerServiceImpl.load");
        return;
    }
    %orig;
}
%end

%hook _TtC32AdsEmbedded_EmbeddedPlaylistImpl22PlaylistAdControllerV2
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed PlaylistAdControllerV2.load");
        return;
    }
    %orig;
}
%end

%hook _TtC32AdsEmbedded_EmbeddedPlaylistImpl24PlaylistAdControllerImpl
- (void)load {
    if (SGAdBlockBannersEnabled()) {
        SGLog(@"adblock: suppressed PlaylistAdControllerImpl.load");
        return;
    }
    %orig;
}
%end

// View-level suppression
%hook _TtC18AdsPlatform_ECMKit37AdsSponsoredPlaylistHeaderCentralView
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockBannersEnabled()) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        if (self.superview) {
            [self removeFromSuperview];
            SGRecordBlockedAd(@"Banners & Sponsored");
        }
    }
}
%end

%hook _TtC22AdsPlatform_ElementKit15HtmlAdElementUI
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockBannersEnabled()) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        if (self.superview) {
            [self removeFromSuperview];
            SGRecordBlockedAd(@"Banners & Sponsored");
        }
    }
}
%end

%hook _TtC19AdsPlatform_DSAImpl11DSAMainView
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockBannersEnabled()) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        if (self.superview) {
            [self removeFromSuperview];
        }
    }
}
%end

%ctor {
    if (SGAdBlockBannersEnabled()) {
        %init;
    }
}
