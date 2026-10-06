// Audio and in-stream video ad blocking: hooks Spotify's ads product state
// and disables the Swift ad service loaders.
#import "Core/SGCore.h"
#import "AdBlock.h"

@interface SPTAdsProductState : NSObject
- (BOOL)adsEnabled;
@end

%hook SPTAdsProductState
- (BOOL)adsEnabled {
    if (SGAdBlockAudioVideoEnabled()) return NO;
    return %orig;
}
%end

%hook _TtC19AdsPlatform_AdsImpl14AdsServiceImpl
- (void)load {
    if (SGAdBlockAudioVideoEnabled()) {
        SGLog(@"adblock: suppressed AdsServiceImpl.load");
        SGRecordBlockedAd(@"Audio & Video");
        return;
    }
    %orig;
}
%end

%hook _TtC29AdsNowPlaying_InStreamAdsImpl18InStreamAdsService
- (void)load {
    if (SGAdBlockAudioVideoEnabled()) {
        SGLog(@"adblock: suppressed InStreamAdsService.load");
        SGRecordBlockedAd(@"Audio & Video");
        return;
    }
    %orig;
}
%end

%hook _TtC20NativeAds_LoggerImpl26NativeAdsLoggerServiceImpl
- (void)load {
    if (SGAdBlockAudioVideoEnabled()) {
        SGLog(@"adblock: suppressed NativeAdsLoggerServiceImpl.load");
        return;
    }
    %orig;
}
%end

%ctor {
    if (SGAdBlockAudioVideoEnabled()) {
        %init;
        SGRequireClasses(@[
            @"SPTAdsProductState",
            @"_TtC19AdsPlatform_AdsImpl14AdsServiceImpl",
            @"_TtC29AdsNowPlaying_InStreamAdsImpl18InStreamAdsService",
            @"_TtC20NativeAds_LoggerImpl26NativeAdsLoggerServiceImpl"
        ]);
    }
}
