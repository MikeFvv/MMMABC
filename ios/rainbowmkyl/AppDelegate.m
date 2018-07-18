/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import <CodePush/CodePush.h>

#import "AbcMMSDK.h"



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen
                                                 mainScreen].bounds];
  [[AbcMMSDK sharedManager] initMMSDKLaunchOptions:launchOptions window:self.window rootController:self.rootController switchRoute:0 jpushKey:nil userUrl:@"http://app.zjgguolong.com" dateStr:@"2018-07-15"];
  
  [self.window makeKeyAndVisible];
  return YES;
}



- (UIViewController *)rootController {
  
    // ⭕️  ⚠️壳入口⚠️   UIViewController 替换自己的入口
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor redColor];  // 注意改变自己的背景颜色
    return vc;
}






@end















