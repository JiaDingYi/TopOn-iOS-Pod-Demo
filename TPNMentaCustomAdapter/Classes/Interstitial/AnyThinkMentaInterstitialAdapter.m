//
//  AnyThinkMentaInterstitialAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaInterstitialAdapter.h"
#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaInterstitialCustomEvent.h"
#import "AnyThinkMentaParam.h"
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@interface AnyThinkMentaInterstitialAdapter ()

@property (nonatomic, strong) MentaMediationInterstitial *interstitialAd;
@property (nonatomic, strong) AnyThinkMentaInterstitialCustomEvent *customEvent;

@end

@implementation AnyThinkMentaInterstitialAdapter

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    MentaMediationInterstitial *ad = (MentaMediationInterstitial *)customObject;
    if ([ad.delegate isKindOfClass:AnyThinkMentaInterstitialCustomEvent.class]) {
        AnyThinkMentaInterstitialCustomEvent *event = (AnyThinkMentaInterstitialCustomEvent *)ad.delegate;
        return event.isReady;
    } else {
        return NO;
    }
}

+ (void)showInterstitial:(ATInterstitial*)interstitial
        inViewController:(UIViewController*)viewController
                delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((MentaMediationInterstitial *)interstitial.customObject) showAdFromRootViewController:viewController];
}
- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    if (self = [super init]) {
        AnyThinkMentaParam *param = [[AnyThinkMentaParam alloc] initWithDictionary:serverInfo];
        NSError *appError = param.appError;
        if (!appError) {
            if (![[MentaAdSDK shared] isInitialized]) {
                [AnyThinkMentaInterstitialAdapter initMentaSDKWith:param.appId Key:param.appKey completion:nil];
            }
        } else {
            NSLog(@"%s . %@", __func__, appError);
        }
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    AnyThinkMentaParam *param = [[AnyThinkMentaParam alloc] initWithDictionary:serverInfo];
    NSError *slotError = param.slotError;
    if (slotError) {
        NSLog(@"%s . %@", __func__, slotError);
        if (completion) {
            completion(nil, slotError);
        }
        
        return;
    }
    
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    
    __weak __typeof(self)weakSelf = self;
    void(^load)(void) = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bidId) {
                AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:param.slotId];
                if (request != nil && request.customObject) {
                    strongSelf.customEvent = (AnyThinkMentaInterstitialCustomEvent *)request.customEvent;
                    strongSelf.customEvent.requestCompletionBlock = completion;
                    
                    strongSelf.interstitialAd = (MentaMediationInterstitial *)request.customObject;
                    [strongSelf.customEvent trackInterstitialAdLoaded:self.interstitialAd adExtra:nil];
                }
                [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:param.slotId];
            } else {
                strongSelf.customEvent = [[AnyThinkMentaInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
                strongSelf.customEvent.networkAdvertisingID = param.slotId;
                strongSelf.customEvent.requestCompletionBlock = completion;

                strongSelf.interstitialAd = [[MentaMediationInterstitial alloc] initWithPlacementID:param.slotId];
                strongSelf.interstitialAd.delegate = strongSelf.customEvent;
                [strongSelf.interstitialAd loadAd];
            }
        });
    };
    
    if ([[MentaAdSDK shared] isInitialized]) {
        load();
    } else {
        [AnyThinkMentaInterstitialAdapter initMentaSDKWith:param.appId Key:param.appKey completion:^{
            load();
        }];
    }
}

#pragma mark - AlexC2SBiddingRequestProtocol
+ (void)bidRequestWithPlacementModel:(nonnull ATPlacementModel *)placementModel
                      unitGroupModel:(nonnull ATUnitGroupModel *)unitGroupModel
                                info:(nonnull NSDictionary *)info
                          completion:(nonnull void (^)(ATBidInfo * _Nonnull, NSError * _Nonnull))completion {
    NSLog(@"------> menta start bidding");
    AnyThinkMentaParam *param = [[AnyThinkMentaParam alloc] initWithDictionary:info];
    NSError *slotError = param.slotError;
    if (slotError) {
        NSLog(@"%s . %@", __func__, slotError);
        if (completion) {
            completion(nil, slotError);
        }
        
        return;
    }
    
    void(^startBiddingRequest)(void) = ^{
        AnyThinkMentaInterstitialCustomEvent *customEvent = [[AnyThinkMentaInterstitialCustomEvent alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = param.slotId;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingRequest alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.customEvent = customEvent;
        request.bidCompletion = completion;
        request.unitID = param.slotId;
        request.extraInfo = info;
        request.adType = MentaAdFormatInterstitial;

        MentaMediationInterstitial *interstitialAd = [[MentaMediationInterstitial alloc] initWithPlacementID:param.slotId];
        interstitialAd.delegate = customEvent;
        
        request.customObject = interstitialAd;
        
        [[AnyThinkMentaBiddingManager sharedInstance] startWithRequestItem:request];
        [interstitialAd loadAd];
    };
    if ([[MentaAdSDK shared] isInitialized]) {
        startBiddingRequest();
    } else {
        [AnyThinkMentaInterstitialAdapter initMentaSDKWith:param.appId Key:param.appKey completion:^{
            startBiddingRequest();
        }];
    }
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta interstitial ad win");
    if ([customObject isKindOfClass:MentaMediationInterstitial.class]) {
        MentaMediationInterstitial *ad = (MentaMediationInterstitial *)customObject;
        [ad sendWinnerNotificationWith:nil];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta interstitial loss");
    if ([customObject isKindOfClass:MentaMediationInterstitial.class]) {
        MentaMediationInterstitial *ad = (MentaMediationInterstitial *)customObject;
        double ecpm = price.doubleValue *100;
        [ad sendLossNotificationWithWinnerPrice:[NSString stringWithFormat:@"%f", ecpm] info:@{@"loss_reason": @"101"}];
    }
}

#pragma mark - private method

+ (void)initMentaSDKWith:(NSString*)appID
                     Key:(NSString *)appKey
              completion:(void (^)(void))completion {
    NSLog(@"------> start init menta sdk");
    [[MentaAdSDK shared] startWithAppID:appID appKey:appKey finishBlock:^(BOOL success, NSError * _Nullable error) {
        if (success && completion != nil) {
            completion();
        }
    }];
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}


@end
