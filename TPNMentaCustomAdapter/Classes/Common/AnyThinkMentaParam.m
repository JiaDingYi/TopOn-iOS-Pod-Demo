//
//  AnyThinkMentaParam.m
//  TPNMentaCustomAdapterNew
//
//  Created by vlion on 2025/9/24.
//

#import "AnyThinkMentaParam.h"

@interface AnyThinkMentaParam ()

@property (nonatomic, strong) NSDictionary *info;

@end


@implementation AnyThinkMentaParam

- (instancetype)initWithDictionary:(NSDictionary *)info {
    if (self = [super init]) {
        self.info = info;
        
        _appId = [self valueForKeys:@[@"appid", @"app_id"]];
        _appKey = [self valueForKeys:@[@"appkey", @"app_key"]];
        _slotId = [self valueForKeys:@[@"slotID", @"slot_id"]];
    }
    return self;
}

- (NSError *)appError {
    if (self.appId && self.appKey) {
        return nil;
    }
    return [NSError errorWithDomain:@"Menta adpater config app param error" code:1 userInfo:nil];
}

- (NSError *)slotError {
    if (self.appId && self.appKey && self.slotId) {
        return nil;
    }
    return [NSError errorWithDomain:@"Menta adpater config slot param error" code:1 userInfo:nil];
}

- (nullable id)valueForKeys:(NSArray<NSString *> *)keys {
    if (!self.info || !self.info.count) {
        return nil;
    }
    
    if (!keys || !keys.count) {
        return nil;
    }
    
    NSString *finalKey = nil;
    for (NSString *key1 in keys) {
        for (NSString *key2 in self.info.allKeys) {
            if ([key1.lowercaseString isEqualToString:key2.lowercaseString]) {
                finalKey = key2;
                break;
            }
        }
    }
    return finalKey ? self.info[finalKey] : nil;
}

@end
