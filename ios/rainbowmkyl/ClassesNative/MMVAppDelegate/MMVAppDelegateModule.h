

/**
 可使用方法列表
 + (void)applicationDidFinishLaunching:(UIApplication *)application;
 + (void)applicationDidBecomeActive:(UIApplication *)application;
 + (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;
 + (void)applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0);
 + (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
 + (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0);
 + (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
 + (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
 
 使用前需要实现，不需要继承
 + (void)load {
 [MMVAppDelegateModule registerAppDelegateModule:self];
 }
 
 使用规范：单独拿出一个类，类名结尾Module
 */

#import <Foundation/Foundation.h>

@interface MMVAppDelegateModule : NSObject

+ (void)registerAppDelegateModule:(Class)moduleClass;


@end
