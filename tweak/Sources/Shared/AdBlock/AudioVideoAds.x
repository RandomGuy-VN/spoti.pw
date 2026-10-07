// Audio and in-stream video ad blocking: intercepts ad tracks reported
// by SPTEsperantoPlayer and automatically skips them immediately.
#import <Foundation/Foundation.h>
#import "Core/SGCore.h"
#import "AdBlock.h"
#import "Headers/SPTPlayer.h"

@interface SPTEsperantoPlayer : NSObject <SPTPlayer>
@end

@interface SPTPlayerTrack (AdBlock)
- (BOOL)isAdvertisement;
- (BOOL)spt_metadata_isAdvertisement;
@end

static NSString *sg_lastSkippedAdURI = nil;
static NSTimeInterval sg_lastSkippedTime = 0;

static BOOL isTrackAd(SPTPlayerTrack *track) {
    if (!track) return NO;

    if ([track respondsToSelector:@selector(isAdvertisement)] && [track isAdvertisement]) {
        return YES;
    }
    if ([track respondsToSelector:@selector(spt_metadata_isAdvertisement)] && [track spt_metadata_isAdvertisement]) {
        return YES;
    }

    id uri = [track respondsToSelector:@selector(URI)] ? track.URI : nil;
    NSString *uriStr = [uri isKindOfClass:NSURL.class] ? [(NSURL *)uri absoluteString] : [uri description];
    if (uriStr && ([uriStr containsString:@":ad:"] || [uriStr containsString:@":advertisement:"])) {
        return YES;
    }

    if ([track respondsToSelector:@selector(metadata)]) {
        NSDictionary *meta = track.metadata;
        if ([meta isKindOfClass:NSDictionary.class]) {
            if ([meta[@"is_advertisement"] boolValue] ||
                [meta[@"is_ad"] boolValue] ||
                meta[@"ad_id"] != nil) {
                return YES;
            }
        }
    }

    return NO;
}

%hook SPTEsperantoPlayer
- (id)state {
    id state = %orig;
    if (!SGAdBlockAudioVideoEnabled() || !state) return state;

    if ([state respondsToSelector:@selector(track)]) {
        SPTPlayerTrack *track = [(SPTPlayerState *)state track];
        if (track && isTrackAd(track)) {
            id uri = [track respondsToSelector:@selector(URI)] ? track.URI : nil;
            NSString *uriStr = [uri isKindOfClass:NSURL.class] ? [(NSURL *)uri absoluteString] : [uri description];
            NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

            if (![uriStr isEqualToString:sg_lastSkippedAdURI] || (now - sg_lastSkippedTime > 1.0)) {
                sg_lastSkippedAdURI = [uriStr copy];
                sg_lastSkippedTime = now;

                SGLog(@"adblock: audio ad track detected (%@), skipping immediately", track.trackTitle ?: uriStr);
                SGRecordBlockedAd(@"Audio & Video");

                id<SPTPlayer> player = (id<SPTPlayer>)self;
                if ([player respondsToSelector:@selector(skipToNextTrack)]) {
                    [player skipToNextTrack];
                }
            }
        }
    }
    return state;
}
%end

%ctor {
    if (SGAdBlockAudioVideoEnabled()) {
        %init;
        SGRequireClasses(@[@"SPTEsperantoPlayer"]);
    }
}
