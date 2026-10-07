// Banners and sponsored content blocking: suppresses sponsored playlist headers,
// now-playing bar attachments, and in-feed advertisement elements.
#import <UIKit/UIKit.h>
#import "Core/SGCore.h"
#import "AdBlock.h"

@interface _TtC18AdsPlatform_ECMKit37AdsSponsoredPlaylistHeaderCentralView : UIView
@end

@interface _TtC22AdsPlatform_ElementKit15HtmlAdElementUI : UIView
@end

@interface _TtC19AdsPlatform_DSAImpl11DSAMainView : UIView
@end

// View-level suppression: uses alpha = 0 and userInteractionEnabled = NO to safely
// hide views without breaking Encore or UIStackView layout calculations.
%hook _TtC18AdsPlatform_ECMKit37AdsSponsoredPlaylistHeaderCentralView
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockBannersEnabled()) {
        self.alpha = 0;
        self.userInteractionEnabled = NO;
        SGRecordBlockedAd(@"Banners & Sponsored");
    }
}
%end

%hook _TtC22AdsPlatform_ElementKit15HtmlAdElementUI
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockBannersEnabled()) {
        self.alpha = 0;
        self.userInteractionEnabled = NO;
        SGRecordBlockedAd(@"Banners & Sponsored");
    }
}
%end

%hook _TtC19AdsPlatform_DSAImpl11DSAMainView
- (void)didMoveToSuperview {
    %orig;
    if (SGAdBlockBannersEnabled()) {
        self.alpha = 0;
        self.userInteractionEnabled = NO;
        SGRecordBlockedAd(@"Banners & Sponsored");
    }
}
%end

%ctor {
    if (SGAdBlockBannersEnabled()) {
        %init;
        SGRequireClasses(@[
            @"_TtC18AdsPlatform_ECMKit37AdsSponsoredPlaylistHeaderCentralView",
            @"_TtC22AdsPlatform_ElementKit15HtmlAdElementUI",
            @"_TtC19AdsPlatform_DSAImpl11DSAMainView"
        ]);
    }
}
