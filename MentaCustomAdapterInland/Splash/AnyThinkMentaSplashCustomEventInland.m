//
//  AnyThinkMentaCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by jdy on 2024/4/11.
//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import "AnyThinkMentaSplashCustomEventInland.h"
#import <MentaVlionBaseSDK/MentaVlionBaseSDK-umbrella.h>

@interface AnyThinkMentaSplashCustomEventInland ()

@property (nonatomic, assign) BOOL isReady;

@end

@implementation AnyThinkMentaSplashCustomEventInland

/// 开屏广告数据拉取成功
- (void)menta_splashAdDidLoad:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    self.isReady = YES;
    [self trackSplashAdLoaded:splashAd];
    MentaLog(@"------> menta_splashAdDidLoad ");
}

/// 开屏加载失败
- (void)menta_splashAd:(MentaUnifiedSplashAd *_Nonnull)splashAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
    self.isReady = NO;
    [self trackSplashAdLoadFailed:error];
    MentaLog(@"------> didFailWithError %@", error);
}

/// 开屏广告被点击了
- (void)menta_splashAdDidClick:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    [self trackSplashAdClick];
    MentaLog(@"------> menta_splashAdDidClick ");
}

/// 开屏广告关闭了
- (void)menta_splashAdDidClose:(MentaUnifiedSplashAd *_Nonnull)splashAd closeMode:(MentaSplashAdCloseMode)mode {
    [self trackSplashAdClosed:@{}];
    MentaLog(@"------> menta_splashAdDidClose ");
}

/// 开屏广告曝光
- (void)menta_splashAdDidExpose:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    [self trackSplashAdShow];
    MentaLog(@"------> menta_splashAdDidExpose ");

}

/// 广告策略服务加载成功
- (void)menta_didFinishLoadingADPolicy:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    MentaLog(@"------> menta_didFinishLoadingADPolicy ");
}

/// 开屏广告 展现的广告信息 曝光之后会触发该回调
- (void)menta_splashAd:(MentaUnifiedSplashAd *_Nonnull)splashAd bestTargetSourcePlatformInfo:(NSDictionary *_Nonnull)info {
    MentaLog(@"------> bestTargetSourcePlatformInfo");
}

- (void)dealloc
{
    MentaLog(@"------> %s", __FUNCTION__);
}

@end
