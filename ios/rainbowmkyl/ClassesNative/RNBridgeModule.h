

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

// 实现RCTBridgeModule协议
@interface RNBridgeModule : RCTEventEmitter

+ (void)postNotifyWithinfo:(NSDictionary *)info;

@end
