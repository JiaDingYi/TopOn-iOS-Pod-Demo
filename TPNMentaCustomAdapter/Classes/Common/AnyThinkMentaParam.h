//
//  AnyThinkMentaParam.h
//  TPNMentaCustomAdapterNew
//
//  Created by vlion on 2025/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaParam : NSObject

@property (nullable, nonatomic, copy, readonly) NSString *appId;
@property (nullable, nonatomic, copy, readonly) NSString *appKey;
@property (nullable, nonatomic, copy, readonly) NSString *slotId;

- (instancetype)initWithDictionary:(NSDictionary *)info;
- (nullable NSError *)appError;
- (nullable NSError *)slotError;

@end

NS_ASSUME_NONNULL_END
