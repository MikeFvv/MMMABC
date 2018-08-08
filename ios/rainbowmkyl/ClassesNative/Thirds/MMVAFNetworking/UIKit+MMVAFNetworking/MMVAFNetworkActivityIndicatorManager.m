

#import "MMVAFNetworkActivityIndicatorManager.h"

#if TARGET_OS_IOS
#import "MMVAFURLSessionManager.h"

typedef NS_ENUM(NSInteger, MMVAFNetworkActivityManagerState) {
    MMVAFNetworkActivityManagerStateNotActive,
    MMVAFNetworkActivityManagerStateDelayingStart,
    MMVAFNetworkActivityManagerStateActive,
    MMVAFNetworkActivityManagerStateDelayingEnd
};

static NSTimeInterval const kMMVDefaultAFNetworkActivityManagerActivationDelay = 1.0;
static NSTimeInterval const kMMVDefaultAFNetworkActivityManagerCompletionDelay = 0.17;

static NSURLRequest * MMVAFNetworkRequestFromNotification(NSNotification *notification) {
    if ([[notification object] respondsToSelector:@selector(originalRequest)]) {
        return [(NSURLSessionTask *)[notification object] originalRequest];
    } else {
        return nil;
    }
}

typedef void (^MMVAFNetworkActivityActionBlock)(BOOL networkActivityIndicatorVisible);

@interface MMVAFNetworkActivityIndicatorManager ()
@property (readwrite, nonatomic, assign) NSInteger activityCount;
@property (readwrite, nonatomic, strong) NSTimer *activationDelayTimer;
@property (readwrite, nonatomic, strong) NSTimer *completionDelayTimer;
@property (readonly, nonatomic, getter = isNetworkActivityOccurring) BOOL networkActivityOccurring;
@property (nonatomic, copy) MMVAFNetworkActivityActionBlock networkActivityActionBlock;
@property (nonatomic, assign) MMVAFNetworkActivityManagerState currentState;
@property (nonatomic, assign, getter=isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;

- (void)updateCurrentStateForNetworkActivityChange;
@end

@implementation MMVAFNetworkActivityIndicatorManager

+ (instancetype)sharedManager {
    static MMVAFNetworkActivityIndicatorManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.currentState = MMVAFNetworkActivityManagerStateNotActive;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:MMVAFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:MMVAFNetworkingTaskDidSuspendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:MMVAFNetworkingTaskDidCompleteNotification object:nil];
    self.activationDelay = kMMVDefaultAFNetworkActivityManagerActivationDelay;
    self.completionDelay = kMMVDefaultAFNetworkActivityManagerCompletionDelay;

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_activationDelayTimer invalidate];
    [_completionDelayTimer invalidate];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled == NO) {
        [self setCurrentState:MMVAFNetworkActivityManagerStateNotActive];
    }
}

- (void)setNetworkingActivityActionWithBlock:(void (^)(BOOL networkActivityIndicatorVisible))block {
    self.networkActivityActionBlock = block;
}

- (BOOL)isNetworkActivityOccurring {
    @synchronized(self) {
        return self.activityCount > 0;
    }
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible {
    if (_networkActivityIndicatorVisible != networkActivityIndicatorVisible) {
        [self willChangeValueForKey:@"networkActivityIndicatorVisible"];
        @synchronized(self) {
             _networkActivityIndicatorVisible = networkActivityIndicatorVisible;
        }
        [self didChangeValueForKey:@"networkActivityIndicatorVisible"];
        if (self.networkActivityActionBlock) {
            self.networkActivityActionBlock(networkActivityIndicatorVisible);
        } else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:networkActivityIndicatorVisible];
        }
    }
}

- (void)setActivityCount:(NSInteger)activityCount {
	@synchronized(self) {
		_activityCount = activityCount;
	}

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentStateForNetworkActivityChange];
    });
}

- (void)incrementActivityCount {
    [self willChangeValueForKey:@"activityCount"];
	@synchronized(self) {
		_activityCount++;
	}
    [self didChangeValueForKey:@"activityCount"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentStateForNetworkActivityChange];
    });
}

- (void)decrementActivityCount {
    [self willChangeValueForKey:@"activityCount"];
	@synchronized(self) {
		_activityCount = MAX(_activityCount - 1, 0);
	}
    [self didChangeValueForKey:@"activityCount"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentStateForNetworkActivityChange];
    });
}

- (void)networkRequestDidStart:(NSNotification *)notification {
    if ([MMVAFNetworkRequestFromNotification(notification) URL]) {
        [self incrementActivityCount];
    }
}

- (void)networkRequestDidFinish:(NSNotification *)notification {
    if ([MMVAFNetworkRequestFromNotification(notification) URL]) {
        [self decrementActivityCount];
    }
}

#pragma mark - Internal State Management
- (void)setCurrentState:(MMVAFNetworkActivityManagerState)currentState {
    @synchronized(self) {
        if (_currentState != currentState) {
            [self willChangeValueForKey:@"currentState"];
            _currentState = currentState;
            switch (currentState) {
                case MMVAFNetworkActivityManagerStateNotActive:
                    [self cancelActivationDelayTimer];
                    [self cancelCompletionDelayTimer];
                    [self setNetworkActivityIndicatorVisible:NO];
                    break;
                case MMVAFNetworkActivityManagerStateDelayingStart:
                    [self startActivationDelayTimer];
                    break;
                case MMVAFNetworkActivityManagerStateActive:
                    [self cancelCompletionDelayTimer];
                    [self setNetworkActivityIndicatorVisible:YES];
                    break;
                case MMVAFNetworkActivityManagerStateDelayingEnd:
                    [self startCompletionDelayTimer];
                    break;
            }
            [self didChangeValueForKey:@"currentState"];
        }
        
    }
}

- (void)updateCurrentStateForNetworkActivityChange {
    if (self.enabled) {
        switch (self.currentState) {
            case MMVAFNetworkActivityManagerStateNotActive:
                if (self.isNetworkActivityOccurring) {
                    [self setCurrentState:MMVAFNetworkActivityManagerStateDelayingStart];
                }
                break;
            case MMVAFNetworkActivityManagerStateDelayingStart:
                //No op. Let the delay timer finish out.
                break;
            case MMVAFNetworkActivityManagerStateActive:
                if (!self.isNetworkActivityOccurring) {
                    [self setCurrentState:MMVAFNetworkActivityManagerStateDelayingEnd];
                }
                break;
            case MMVAFNetworkActivityManagerStateDelayingEnd:
                if (self.isNetworkActivityOccurring) {
                    [self setCurrentState:MMVAFNetworkActivityManagerStateActive];
                }
                break;
        }
    }
}

- (void)startActivationDelayTimer {
    self.activationDelayTimer = [NSTimer
                                 timerWithTimeInterval:self.activationDelay target:self selector:@selector(activationDelayTimerFired) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.activationDelayTimer forMode:NSRunLoopCommonModes];
}

- (void)activationDelayTimerFired {
    if (self.networkActivityOccurring) {
        [self setCurrentState:MMVAFNetworkActivityManagerStateActive];
    } else {
        [self setCurrentState:MMVAFNetworkActivityManagerStateNotActive];
    }
}

- (void)startCompletionDelayTimer {
    [self.completionDelayTimer invalidate];
    self.completionDelayTimer = [NSTimer timerWithTimeInterval:self.completionDelay target:self selector:@selector(completionDelayTimerFired) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.completionDelayTimer forMode:NSRunLoopCommonModes];
}

- (void)completionDelayTimerFired {
    [self setCurrentState:MMVAFNetworkActivityManagerStateNotActive];
}

- (void)cancelActivationDelayTimer {
    [self.activationDelayTimer invalidate];
}

- (void)cancelCompletionDelayTimer {
    [self.completionDelayTimer invalidate];
}

@end

#endif
