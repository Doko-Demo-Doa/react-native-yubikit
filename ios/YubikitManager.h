#import <Foundation/Foundation.h>
#import <YubiKit/YubiKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^YubikitManagerEventHandler)(NSString *type, NSDictionary * _Nullable payload);

@interface YubikitManager : NSObject <YKFManagerDelegate>

/// Set by YubikitCore while it has JS-side "YubiKeyEvent" listeners registered.
/// Invoked on device attach/detach/connection-failure so it can be re-emitted to JS.
@property (nonatomic, copy, nullable) YubikitManagerEventHandler eventHandler;

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
