//
//  AnyThinkMentaBannerAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaBannerAdapter.h"
#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaBannerCustomEvent.h"
#import "AnyThinkMentaParam.h"
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@interface AnyThinkMentaBannerAdapter ()

@property (nonatomic, strong) AnyThinkMentaBannerCustomEvent *customEvent;
@property (nonatomic, strong) MentaMediationBanner *bannerAd;

@end

@implementation AnyThinkMentaBannerAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    if (self = [super init]) {
        AnyThinkMentaParam *param = [[AnyThinkMentaParam alloc] initWithDictionary:serverInfo];
        NSError *appError = param.appError;
        if (!appError) {
            if (![[MentaAdSDK shared] isInitialized]) {
                [AnyThinkMentaBannerAdapter initMentaSDKWith:param.appId Key:param.appKey completion:nil];
            }
        } else {
            NSLog(@"%s . %@", __func__, appError);
        }
    }
    return self;
}

-(void)loadADWithInfo:(NSDictionary*)serverInfo
            localInfo:(NSDictionary*)localInfo
           completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    AnyThinkMentaParam *param = [[AnyThinkMentaParam alloc] initWithDictionary:serverInfo];
    NSError *slotError = param.slotError;
    if (slotError) {
        NSLog(@"%s . %@", __func__, slotError);
        if (completion) {
            completion(nil, slotError);
        }
        
        return;
    }
    
    CGFloat width = 320;
    CGFloat height = 50;
    id size = localInfo[kATAdLoadingExtraBannerAdSizeKey];
    if (size && [size isKindOfClass:NSValue.class]) {
        CGSize bannerSize = [(NSValue *)size CGSizeValue];
        width = bannerSize.width;
        height = bannerSize.height;
    }
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    NSString *requestUUID = serverInfo[@"tracking_info_request_id"];
    
    __weak typeof(self) weakSelf = self;
    void(^load)(void) = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:requestUUID];
            
            if (bidId && request != nil && request.customObject) {
                NSLog(@"------> bidding load success %@ - customevent %@", requestUUID, request.customEvent);
                AnyThinkMentaBannerCustomEvent *customEvent = (AnyThinkMentaBannerCustomEvent *)request.customEvent;
                customEvent.requestCompletionBlock = completion;
                MentaMediationBanner *bannerAd = (MentaMediationBanner *)request.customObject;
                if ([bannerAd isAdReady]) {
                    [customEvent trackBannerAdLoaded:bannerAd adExtra:nil];
                }
                return;
            }
            
            strongSelf.customEvent = [[AnyThinkMentaBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            strongSelf.customEvent.width = width;
            strongSelf.customEvent.height = height;
            strongSelf.customEvent.networkAdvertisingID = param.slotId;
            strongSelf.customEvent.requestCompletionBlock = completion;
            strongSelf.customEvent.UUID = requestUUID;

            strongSelf.bannerAd = [[MentaMediationBanner alloc] initWithPlacementID:param.slotId];
            strongSelf.bannerAd.delegate = strongSelf.customEvent;
            [strongSelf.bannerAd loadAd];
        });
    };
    
    if ([[MentaAdSDK shared] isInitialized]) {
        load();
    } else {
        [AnyThinkMentaBannerAdapter initMentaSDKWith:param.appId Key:param.appKey completion:^{
            load();
        }];
    }
}

#pragma mark - AlexC2SBiddingRequestProtocol
+ (void)bidRequestWithPlacementModel:(nonnull ATPlacementModel *)placementModel 
                      unitGroupModel:(nonnull ATUnitGroupModel *)unitGroupModel
                                info:(nonnull NSDictionary *)info
                          completion:(nonnull void (^)(ATBidInfo * _Nonnull, NSError * _Nonnull))completion {
    AnyThinkMentaParam *param = [[AnyThinkMentaParam alloc] initWithDictionary:info];
    NSError *slotError = param.slotError;
    if (slotError) {
        NSLog(@"%s . %@", __func__, slotError);
        if (completion) {
            completion(nil, slotError);
        }
        
        return;
    }
    
    CGFloat width = 320;
    CGFloat height = 50;
    id size = info[kATAdLoadingExtraBannerAdSizeKey];
    if (size && [size isKindOfClass:NSValue.class]) {
        CGSize bannerSize = [(NSValue *)size CGSizeValue];
        width = bannerSize.width;
        height = bannerSize.height;
    }
    
    NSString *requestUUID = info[@"tracking_info_request_id"];
    
    [AnyThinkMentaBannerAdapter initMentaSDKWith:param.appId Key:param.appKey completion:^{
        AnyThinkMentaBannerCustomEvent *customEvent = [[AnyThinkMentaBannerCustomEvent alloc] initWithInfo:info localInfo:info];
        customEvent.width = width;
        customEvent.height = height;
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = param.slotId;
        customEvent.UUID = requestUUID;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingRequest alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.customEvent = customEvent;
        request.bidCompletion = completion;
        request.unitID = param.slotId;
        request.extraInfo = info;
        request.adType = MentaAdFormatBanner;
        request.UUID = requestUUID;
        
        MentaMediationBanner *bannerAd = [[MentaMediationBanner alloc] initWithPlacementID:param.slotId];
        bannerAd.delegate = customEvent;
        
        request.customObject = bannerAd;
        [[AnyThinkMentaBiddingManager sharedInstance] startWithRequestItem:request];;
        [bannerAd loadAd];
        NSLog(@"------> menta start bidding %@, customevent %@", requestUUID, customEvent);
    }];
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta banner ad win");
    if ([customObject isKindOfClass:MentaMediationBanner.class]) {
        MentaMediationBanner *ad = (MentaMediationBanner *)customObject;
        [ad sendWinnerNotificationWith:nil];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta banner ad loss");
    if ([customObject isKindOfClass:MentaMediationBanner.class]) {
        MentaMediationBanner *ad = (MentaMediationBanner *)customObject;
        double ecpm = price.doubleValue *100;
        [ad sendLossNotificationWithWinnerPrice:[NSString stringWithFormat:@"%f", ecpm] info:@{@"loss_reason": @"101"}];
    }
}

+(void)showBanner:(ATBanner* )banner inView:(UIView* )view presentingViewController:(UIViewController* )viewController {
    MentaMediationBanner *bannerAd = (MentaMediationBanner *)banner.bannerView;
    NSLog(@"------> show banner view");
    if ([bannerAd isAdReady]) {
        [view addSubview:bannerAd.bannerAdView];
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
