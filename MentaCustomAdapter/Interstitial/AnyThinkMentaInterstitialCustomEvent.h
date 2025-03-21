//
//  AnyThinkMentaInterstitialCustomEvent.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaInterstitialCustomEvent : ATInterstitialCustomEvent <MentaUnifiedInterstitialAdDelegate>

@property (nonatomic, assign, readonly) BOOL isReady;

@end

NS_ASSUME_NONNULL_END
