

#import "MMVAppDelegateModule.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define APPDELEGATE_METHOD_MSG_SEND(__SELECTOR__, __OBJECT1__, __OBJECT2__) \
for (Class cls in MMVModuleClasses) { \
if ([cls respondsToSelector:__SELECTOR__]) { \
[cls performSelector:__SELECTOR__ withObject:__OBJECT1__ withObject:__OBJECT2__]; \
} \
} \

#define SELECTOR_IS_EQUAL(__SELECTOR1__, __SELECTOR2__) \
Method m1 = class_getClassMethod([MMVAppDelegateModule class], __SELECTOR1__); \
IMP imp1 = method_getImplementation(m1); \
Method m2 = class_getInstanceMethod([self class], __SELECTOR2__); \
IMP imp2 = method_getImplementation(m2); \

#define SWIZZLE_METHOD(__SELECTOR__) \
Swizzle([delegate class], @selector(__SELECTOR__), class_getClassMethod([MMVAppDelegateModule class], @selector(module_##__SELECTOR__)));

#define APPDELEGATE_RESULT_METHOD(__OBJECT1__,__OBJECT2__) \
BOOL result = YES; \
SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]); \
SELECTOR_IS_EQUAL(selector, _cmd) \
if (imp1 != imp2) { \
result = !![self performSelector:selector withObject:__OBJECT1__ withObject:__OBJECT2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __OBJECT1__, __OBJECT2__); \
return result; \

#define APPDELEGATE_METHOD(__OBJECT1__, __OBJECT2__) \
SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]); \
SELECTOR_IS_EQUAL(selector, _cmd) \
if (imp1 != imp2) { \
[self performSelector:selector withObject:__OBJECT1__ withObject:__OBJECT2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __OBJECT1__, __OBJECT2__); \

void Swizzle(Class class, SEL originalSelector, Method swizzledMethod)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    SEL swizzledSelector = method_getName(swizzledMethod);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod && originalMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    class_addMethod(class,
                    swizzledSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
}

static NSMutableArray<Class> *MMVModuleClasses;

BOOL MMVModuleClassIsRegistered(Class cls) {
    return [objc_getAssociatedObject(cls, &MMVModuleClassIsRegistered) ?: @YES boolValue];
}

@implementation MMVAppDelegateModule

+ (void)load {
    static dispatch_once_t onceKey;
    dispatch_once(&onceKey, ^{
        Swizzle([UIApplication class], @selector(setDelegate:), class_getInstanceMethod([UIApplication class], @selector(module_setDelegate:)));
    });
}

+ (void)registerAppDelegateModule:(Class)moduleClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MMVModuleClasses = [[NSMutableArray alloc] init];
    });
    
    // Register module
    [MMVModuleClasses addObject:moduleClass];
    
    objc_setAssociatedObject(moduleClass, &MMVModuleClassIsRegistered,
                             @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)module_applicationDidFinishLaunching:(UIApplication *)application {
    APPDELEGATE_METHOD(application, NULL);
}

+ (void)module_applicationDidBecomeActive:(UIApplication *)application {
//    DEF_APPDELEGATE_METHOD
    APPDELEGATE_METHOD(application, NULL);
}

+ (BOOL)module_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    APPDELEGATE_RESULT_METHOD(application, launchOptions);
}

+ (void)module_applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0) {
    APPDELEGATE_METHOD(application, NULL);
}





+ (void)module_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    APPDELEGATE_METHOD(application, deviceToken);
}

+ (void)module_didReceiveRemoteNotification:(UIApplication *)application NS_AVAILABLE_IOS(4_0) {
    APPDELEGATE_METHOD(application, NULL);
}

+ (void)module_application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    APPDELEGATE_METHOD(application, notification);
}

+ (void)module_applicationWillEnterForeground:(UIApplication *)application NS_AVAILABLE_IOS(4_0) {
    APPDELEGATE_METHOD(application, NULL);
}




+ (void)module_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(selector, _cmd)
    if (imp1 != imp2) {
        ((void(*)(id, SEL, id, id, id))(void *)objc_msgSend)(self,selector,application,userInfo,completionHandler);
    }
    
    void (* sendMoudle)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in MMVModuleClasses) {
        if ([cls instancesRespondToSelector:_cmd]) {
            sendMoudle(cls, _cmd, application, userInfo, completionHandler);
        }
    }
}

+ (BOOL)module_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0) {
    BOOL result = YES;
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        result = ((BOOL (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, ytx_selector, app, url, options);
    }
    
    BOOL (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in MMVModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, app, url, options);
        }
    }
    
    return result;
}

+ (BOOL)module_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = YES;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"module_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(selector, _cmd)
    if (imp1 != imp2) {
        result = ((BOOL (*)(id, SEL, id, id, id, id))(void *)objc_msgSend)(self, selector, application, url, sourceApplication, annotation);
    }
    BOOL (*typed_msgSend)(id, SEL, id, id, id, id) = (void *)objc_msgSend;
    for (Class cls in MMVModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, application, url, sourceApplication, annotation);
        }
    }
    return result;
}

+ (BOOL)module_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    APPDELEGATE_RESULT_METHOD(application, url);
}

@end

@implementation UIApplication (MMVApplication)

- (void)module_setDelegate:(id<UIApplicationDelegate>)delegate {
    static dispatch_once_t onceKey;
    dispatch_once(&onceKey, ^{
        SWIZZLE_METHOD(application:didFinishLaunchingWithOptions:);
        SWIZZLE_METHOD(applicationDidBecomeActive:);
        SWIZZLE_METHOD(applicationDidFinishLaunching:);
        SWIZZLE_METHOD(applicationDidEnterBackground:);
        
        
        // 新添
        SWIZZLE_METHOD(application:didRegisterForRemoteNotificationsWithDeviceToken:);
        SWIZZLE_METHOD(didReceiveRemoteNotification:);
        SWIZZLE_METHOD(application:didReceiveLocalNotification:);
        SWIZZLE_METHOD(applicationWillEnterForeground:);
        
        
        SWIZZLE_METHOD(application:didReceiveRemoteNotification:);
        SWIZZLE_METHOD(application:handleOpenURL:);
        SWIZZLE_METHOD(application:openURL:sourceApplication:annotation:);
        SWIZZLE_METHOD(application:openURL:options:);
    });
    [self module_setDelegate:delegate];
}

@end


