

#import "UIActivityIndicatorView+MMVAFNetworking.h"
#import <objc/runtime.h>

#if TARGET_OS_IOS || TARGET_OS_TV

#import "MMVAFURLSessionManager.h"

@interface MMVAFActivityIndicatorViewNotificationObserver : NSObject
@property (readonly, nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
- (instancetype)initWithActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView;

- (void)setAnimatingWithStateOfTask:(NSURLSessionTask *)task;

@end

@implementation UIActivityIndicatorView (MMVAFNetworking)

- (MMVAFActivityIndicatorViewNotificationObserver *)af_notificationObserver {
    MMVAFActivityIndicatorViewNotificationObserver *notificationObserver = objc_getAssociatedObject(self, @selector(af_notificationObserver));
    if (notificationObserver == nil) {
        notificationObserver = [[MMVAFActivityIndicatorViewNotificationObserver alloc] initWithActivityIndicatorView:self];
        objc_setAssociatedObject(self, @selector(af_notificationObserver), notificationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return notificationObserver;
}

- (void)setAnimatingWithStateOfTask:(NSURLSessionTask *)task {
    [[self af_notificationObserver] setAnimatingWithStateOfTask:task];
}

@end

@implementation MMVAFActivityIndicatorViewNotificationObserver

- (instancetype)initWithActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView
{
    self = [super init];
    if (self) {
        _activityIndicatorView = activityIndicatorView;
    }
    return self;
}

- (void)setAnimatingWithStateOfTask:(NSURLSessionTask *)task {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidResumeNotification object:nil];
    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidSuspendNotification object:nil];
    [notificationCenter removeObserver:self name:MMVAFNetworkingTaskDidCompleteNotification object:nil];
    
    if (task) {
        if (task.state != NSURLSessionTaskStateCompleted) {
            UIActivityIndicatorView *activityIndicatorView = self.activityIndicatorView;
            if (task.state == NSURLSessionTaskStateRunning) {
                [activityIndicatorView startAnimating];
            } else {
                [activityIndicatorView stopAnimating];
            }

            [notificationCenter addObserver:self selector:@selector(af_startAnimating) name:MMVAFNetworkingTaskDidResumeNotification object:task];
            [notificationCenter addObserver:self selector:@selector(af_stopAnimating) name:MMVAFNetworkingTaskDidCompleteNotification object:task];
            [notificationCenter addObserver:self selector:@selector(af_stopAnimating) name:MMVAFNetworkingTaskDidSuspendNotification object:task];
        }
    }
}

#pragma mark -

- (void)af_startAnimating {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView startAnimating];
    });
}

- (void)af_stopAnimating {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
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
