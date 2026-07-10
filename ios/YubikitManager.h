#import <Foundation/Foundation.h>
#import <YubiKit/YubiKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YubikitManager : NSObject <YKFManagerDelegate>

+ (instancetype)shared;

- (void)startUsbDiscovery;
- (void)stopUsbDiscovery;
- (void)startNfcDiscovery;
- (void)stopNfcDiscovery;

- (nullable id<YKFConnectionProtocol>)connectionForHandle:(NSString *)handle;
- (void)removeConnectionForHandle:(NSString *)handle;
- (NSArray<NSDictionary *> *)listDevices;

@end

NS_ASSUME_NONNULL_END
