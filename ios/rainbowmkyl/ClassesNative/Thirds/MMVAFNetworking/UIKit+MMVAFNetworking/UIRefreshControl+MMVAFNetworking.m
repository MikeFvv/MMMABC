

#import "UIRefreshControl+MMVAFNetworking.h"
#import <objc/runtime.h>

#if TARGET_OS_IOS

#import "MMVAFURLSessionManager.h"

@interface MMVAFRefreshControlNotificationObserver : NSObject
@property (readonly, nonatomic, weak) UIRefreshControl *refreshControl;
- (instancetype)initWithActivityRefreshControl:(UIRefreshControl *)refreshControl;

- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task;

@end

@implementation UIRefreshControl (MMVAFNetworking)

- (MMVAFRefreshControlNotificationObserver *)af_notificationObserver {
    MMVAFRefreshControlNotificationObserver *notificationObserver = objc_getAssociatedObject(self, @selector(af_notificationObserver));
    if (notificationObserver == nil) {
        notificationObserver = [[MMVAFRefreshControlNotificationObserver alloc] initWithActivityRefreshControl:self];
        objc_setAssociatedObject(self, @selector(af_notificationObserver), notificationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return notificationObserver;
}

- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task {
    [[self af_notificationObserver] setRefreshingWithStateOfTask:task];
}

@end

@implementation MMVAFRefreshControlNotificationObserver

- (instancetype)initWithActivityRefreshControl:(UIRefreshControl *)refreshControl
{
    self = [super init];
    if (self) {
        _refreshControl = refreshControl;
    }
    return self;
}

- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidSuspendNotification object:nil];
    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidCompleteNotification object:nil];

    if (task) {
        UIRefreshControl *refreshControl = self.refreshControl;
        if (task.state == NSURLSessionTaskStateRunning) {
            [refreshControl beginRefreshing];

            [notificationCenter addObserver:self selector:@selector(af_beginRefreshing) name:MMVAFNetworkingTaskDidResumeNotification object:task];
            [notificationCenter addObserver:self selector:@selector(af_endRefreshing) name:MMVAFNetworkingTaskDidCompleteNotification object:task];
            [notificationCenter addObserver:self selector:@selector(af_endRefreshing) name:MMVAFNetworkingTaskDidSuspendNotification object:task];
        } else {
            [refreshControl endRefreshing];
        }
    }
}

#pragma mark -

- (void)af_beginRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
    });
}

- (void)af_endRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

#pragma mark -

- (void)dealloc {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidSuspendNotification object:nil];
}

@end

#endif
