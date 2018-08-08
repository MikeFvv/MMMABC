

#if TARGET_OS_IOS || TARGET_OS_TV

#import <UIKit/UIKit.h>

@interface UIImage (MMVAFNetworking)

+ (UIImage*) safeImageWithData:(NSData*)data;

@end

#endif
