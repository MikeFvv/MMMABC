

#import <Foundation/Foundation.h>

#import <TargetConditionals.h>

#if TARGET_OS_IOS || TARGET_OS_TV

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 This category adds methods to the UIKit framework's `UIProgressView` class. The methods in this category provide support for binding the progress to the upload and download progress of a session task.
 */
@interface UIProgressView (MMVAFNetworking)

///------------------------------------
/// @name Setting Session Task Progress
///------------------------------------

/**
 Binds the progress to the upload progress of the specified session task.

 @param task The session task.
 @param animated `YES` if the change should be animated, `NO` if the change should happen immediately.
 */
- (void)setProgressWithUploadProgressOfTask:(NSURLSessionUploadTask *)task
                                   animated:(BOOL)animated;

/**
 Binds the progress to the download progress of the specified session task.

 @param task The session task.
 @param animated `YES` if the change should be animated, `NO` if the change should happen immediately.
 */
- (void)setProgressWithDownloadProgressOfTask:(NSURLSessionDownloadTask *)task
                                     animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

#endif
