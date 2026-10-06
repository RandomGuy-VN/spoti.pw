// Network ad blocking: an NSURLProtocol that intercepts advertising endpoints
// and answers them with HTTP 204 No Content to drop network overhead.
#import "Core/SGCore.h"
#import "AdBlock.h"

@interface SGAdBlockProtocol : NSURLProtocol
@end

static BOOL isAdRequest(NSURL *url) {
    if (!url) return NO;
    NSString *host = url.host.lowercaseString;
    NSString *path = url.path.lowercaseString;

    if ([host isEqualToString:@"ad.spotify.com"] ||
        [host isEqualToString:@"ads.spotify.com"] ||
        [host isEqualToString:@"aet.spotify.com"] ||
        [host hasPrefix:@"aet."] ||
        [host containsString:@"doubleclick.net"] ||
        [host containsString:@"googlesyndication.com"]) {
        return YES;
    }

    static NSString *const adPaths[] = {
        @"/ads/",
        @"/ad-logic/",
        @"/dac/view/v1/",
        @"/ad-slot/",
        @"/ad-inventory/",
        @"/ad-on-app-open",
        @"/sponsored/",
        @"/promoted/",
        @"/campaign/",
        @"/billboard/",
        @"/marquee/",
        @"/leavebehind",
        @"/leave-behind",
        @"/display-ad/",
        @"/search-ad",
        @"/home-ad",
        @"/merchandising/",
        @"/premium-marketing/upsellOffer",
        @"/trials-facade/start-trial"
    };

    for (size_t i = 0; i < sizeof(adPaths) / sizeof(adPaths[0]); i++) {
        if ([path containsString:adPaths[i]]) return YES;
    }

    if ([path containsString:@"/esperanto/"] &&
        ([path containsString:@"ad"] || [path containsString:@"slot"])) {
        return YES;
    }

    if ([path containsString:@"pendragon"] && [path containsString:@"fetchmessage"]) {
        return YES;
    }

    return NO;
}

@implementation SGAdBlockProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (!SGAdBlockNetworkEnabled()) return NO;
    return isAdRequest(request.URL);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    SGRecordBlockedAd(@"Network Endpoints");
    NSHTTPURLResponse *answer = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                            statusCode:204
                                                           HTTPVersion:@"HTTP/1.1"
                                                          headerFields:@{}];
    [self.client URLProtocol:self didReceiveResponse:answer cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end

static NSURLSessionConfiguration *carryingAdBlockProtocol(NSURLSessionConfiguration *configuration) {
    if (!configuration || [configuration.protocolClasses containsObject:SGAdBlockProtocol.class]) return configuration;
    NSMutableArray *classes = [configuration.protocolClasses mutableCopy] ?: [NSMutableArray array];
    [classes insertObject:SGAdBlockProtocol.class atIndex:0];
    configuration.protocolClasses = classes;
    return configuration;
}

%hook NSURLSessionConfiguration

+ (NSURLSessionConfiguration *)defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = %orig;
    return carryingAdBlockProtocol(configuration);
}

+ (NSURLSessionConfiguration *)ephemeralSessionConfiguration {
    NSURLSessionConfiguration *configuration = %orig;
    return carryingAdBlockProtocol(configuration);
}

%end

%ctor {
    if (SGAdBlockNetworkEnabled()) {
        [NSURLProtocol registerClass:SGAdBlockProtocol.class];
        %init;
    }
}
