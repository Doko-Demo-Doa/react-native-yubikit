#import <Foundation/Foundation.h>

@class YKFManagementDeviceInfo;

NS_ASSUME_NONNULL_BEGIN

@interface YubikitDeviceInfoHelper : NSObject

+ (NSDictionary *)dictionaryFromDeviceInfo:(YKFManagementDeviceInfo *)deviceInfo;

@end

NS_ASSUME_NONNULL_END
