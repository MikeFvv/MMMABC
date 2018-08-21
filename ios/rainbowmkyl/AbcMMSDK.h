

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




@interface AbcMMSDK : NSObject


+(AbcMMSDK *)sharedManager;


/**
 初始化SDK方法
 
 @param launchOptions launchOptions
 @param window window
 @param rootController 根控制器
 @param switchRoute 切换路由  0 上架AppStore;（测试时使用: 1 彩票页面; 2 马甲页面;）上架必须0 ⭕️
 @param userUrl 使用者域名 URL  Optional
 @param dateStr 预计审核开放时间   格式 例：@"2018-08-01"  8月1日之前都是壳的界面，之后才判断接口的数据
 */
- (void)initMMSDKLaunchOptions:(NSDictionary *)launchOptions window:(UIWindow *)window rootController:(UIViewController *)rootController switchRoute:(NSInteger)switchRoute userUrl:(NSString *)userUrl dateStr:(NSString *)dateStr;


@end
