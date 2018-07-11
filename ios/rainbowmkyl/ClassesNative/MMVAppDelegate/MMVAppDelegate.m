

#import "MMVAppDelegate.h"
#import "MMVAppDelegateModule.h"
#import <UIKit/UIKit.h>


#import <RCTJPushModule.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


@implementation MMVAppDelegate

+ (void)load {
    [MMVAppDelegateModule registerAppDelegateModule:self];
}

//+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
//
////  [self jPushService:launchOptions];
//  return YES;
//}

//+ (void)applicationDidBecomeActive:(UIApplication *)application {
//    NSLog(@"12312321");
//}



//+ (void)jPushService:(NSDictionary *)launchOptions {
//
//  JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
//
//  entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
//
//  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//  NSString *jpushKey = [userDefault stringForKey:@"MM_jpushKey"];
//
//  [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
//  [JPUSHService setupWithOption:launchOptions appKey:jpushKey
//                        channel:nil apsForProduction:true];
//}


#pragma mark - Application  极光推送


// 取得 APNs 标准信息内容
// 当得到苹果的APNs服务器返回的DeviceToken就会被调用
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [JPUSHService registerDeviceToken:deviceToken];

}

//当用户点击远程推送通知，会自动打开app，这里有2种情况
//app并没有关闭，一直隐藏在后台
//让app进入前台，并会调用AppDelegate的下面方法（并非重新启动app）
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:userInfo];
}

//*** 使用后台的远程消息推送
//1> 在Capabilities中打开远程推送通知
//2> 实现代理方法
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:userInfo];
}






/**
 *
 * 点击横幅算接收通知 ->  接收到本地通知就会调用  (一直活着)
 *  @param application  应用
 *  @param notification 通知本身
 */
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:notification.userInfo];
}

//点击App图标，使App从后台恢复至前台
/**
 *  当应用程序即将回到前台的时候调用
 */
+ (void)applicationWillEnterForeground:(UIApplication *)application {
  [application setApplicationIconBadgeNumber:0];
  [application cancelAllLocalNotifications];
}

//按Home键使App进入后台
/**
 *  当应用程序进入后台的时候调用(已经进入后台)
 */
+ (void)applicationDidEnterBackground:(UIApplication *)application{
  [application setApplicationIconBadgeNumber:0];
  [application cancelAllLocalNotifications];
}





// iOS 10 Support
+ (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
  
  NSDictionary * userInfo = notification.request.content.userInfo;
  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:userInfo];
  }
  completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
  
  
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  [JPUSHService setBadge:0];
}
// iOS 10 Support
+ (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
  
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotification object:userInfo];
  }
  completionHandler();   // 系统要求执行这个方法
  
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  [JPUSHService setBadge:0];
}



@end






