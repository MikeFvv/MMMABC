

#if TARGET_OS_IOS || TARGET_OS_TV
#import <UIKit/UIKit.h>

#ifndef _MMV_UIKIT_AFNETWORKING_
    #define _MMV_UIKIT_AFNETWORKING_

#if TARGET_OS_IOS
    #import "MMVAFAutoPurgingImageCache.h"
    #import "MMVAFImageDownloader.h"
    #import "MMVAFNetworkActivityIndicatorManager.h"
    #import "UIRefreshControl+MMVAFNetworking.h"
    #import "UIWebView+MMVAFNetworking.h"
#endif

    #import "UIActivityIndicatorView+MMVAFNetworking.h"
    #import "UIButton+MMVAFNetworking.h"
    #import "UIImageView+MMVAFNetworking.h"
    #import "UIProgressView+MMVAFNetworking.h"
#endif /* _MMV_UIKIT_AFNETWORKING_ */
#endif
