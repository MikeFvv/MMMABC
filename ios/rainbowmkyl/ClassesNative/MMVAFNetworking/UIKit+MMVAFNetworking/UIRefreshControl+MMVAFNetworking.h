

#import <Foundation/Foundation.h>

#import <TargetConditionals.h>

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This category adds methods to the UIKit framework's `UIRefreshControl` class. The methods in this category provide support for automatically beginning and ending refreshing depending on the loading state of a session task.
 */
@interface UIRefreshControl (MMVAFNetworking)

///-----------------------------------
/// @name Refreshing for Session Tasks
///-----------------------------------

/**
 Binds the refreshing state to the state of the specified task.
 
 @param task The task. If `nil`, automatic updating from any previously specified operation will be disabled.
 */
- (void)setRefreshingWithStateOfTask:(NSURLSessionTask *)task;

@end

NS_ASSUME_NONNULL_END

#endif
