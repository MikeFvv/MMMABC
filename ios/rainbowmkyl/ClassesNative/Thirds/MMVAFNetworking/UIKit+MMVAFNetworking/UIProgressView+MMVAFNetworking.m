

#import "UIProgressView+MMVAFNetworking.h"

#import <objc/runtime.h>

#if TARGET_OS_IOS || TARGET_OS_TV

#import "MMVAFURLSessionManager.h"

static void * MMVAFTaskCountOfBytesSentContext = &MMVAFTaskCountOfBytesSentContext;
static void * MMVAFTaskCountOfBytesReceivedContext = &MMVAFTaskCountOfBytesReceivedContext;

#pragma mark -

@implementation UIProgressView (MMVAFNetworking)

- (BOOL)af_uploadProgressAnimated {
    return [(NSNumber *)objc_getAssociatedObject(self, @selector(af_uploadProgressAnimated)) boolValue];
}

- (void)af_setUploadProgressAnimated:(BOOL)animated {
    objc_setAssociatedObject(self, @selector(af_uploadProgressAnimated), @(animated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)af_downloadProgressAnimated {
    return [(NSNumber *)objc_getAssociatedObject(self, @selector(af_downloadProgressAnimated)) boolValue];
}

- (void)af_setDownloadProgressAnimated:(BOOL)animated {
    objc_setAssociatedObject(self, @selector(af_downloadProgressAnimated), @(animated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)setProgressWithUploadProgressOfTask:(NSURLSessionUploadTask *)task
                                   animated:(BOOL)animated
{
    if (task.state == NSURLSessionTaskStateCompleted) {
        return;
    }
    
    [task addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptions)0 context:MMVAFTaskCountOfBytesSentContext];
    [task addObserver:self forKeyPath:@"countOfBytesSent" options:(NSKeyValueObservingOptions)0 context:MMVAFTaskCountOfBytesSentContext];

    [self af_setUploadProgressAnimated:animated];
}

- (void)setProgressWithDownloadProgressOfTask:(NSURLSessionDownloadTask *)task
                                     animated:(BOOL)animated
{
    if (task.state == NSURLSessionTaskStateCompleted) {
        return;
    }
    
    [task addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptions)0 context:MMVAFTaskCountOfBytesReceivedContext];
    [task addObserver:self forKeyPath:@"countOfBytesReceived" options:(NSKeyValueObservingOptions)0 context:MMVAFTaskCountOfBytesReceivedContext];

    [self af_setDownloadProgressAnimated:animated];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(__unused NSDictionary *)change
                       context:(void *)context
{
    if (context == MMVAFTaskCountOfBytesSentContext || context == MMVAFTaskCountOfBytesReceivedContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesSent))]) {
            if ([object countOfBytesExpectedToSend] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setProgress:[object countOfBytesSent] / ([object countOfBytesExpectedToSend] * 1.0f) animated:self.af_uploadProgressAnimated];
                });
            }
        }

        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            if ([object countOfBytesExpectedToReceive] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setProgress:[object countOfBytesReceived] / ([object countOfBytesExpectedToReceive] * 1.0f) animated:self.af_downloadProgressAnimated];
                });
            }
        }

        if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
            if ([(NSURLSessionTask *)object state] == NSURLSessionTaskStateCompleted) {
                @try {
                    [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];

                    if (context == MMVAFTaskCountOfBytesSentContext) {
                        [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))];
                    }

                    if (context == MMVAFTaskCountOfBytesReceivedContext) {
                        [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
                    }
                }
                @catch (NSException * __unused exception) {}
            }
        }
    }
}

@end

#endif
