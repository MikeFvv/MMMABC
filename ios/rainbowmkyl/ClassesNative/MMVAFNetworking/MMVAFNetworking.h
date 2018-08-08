

#import <Foundation/Foundation.h>
#import <Availability.h>
#import <TargetConditionals.h>

#ifndef _MVVAFNETWORKING_
    #define _MVVAFNETWORKING_

    #import "MMVAFURLRequestSerialization.h"
    #import "MMVAFURLResponseSerialization.h"
    #import "MMVAFSecurityPolicy.h"

#if !TARGET_OS_WATCH
    #import "MMVAFNetworkReachabilityManager.h"
#endif

    #import "MMVAFURLSessionManager.h"
    #import "MMVAFHTTPSessionManager.h"

#endif /* _MVVAFNETWORKING_ */
