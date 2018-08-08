


#import "MMVAFNetworking.h"
#import "MMVAFHTTPSessionManager.h"


// 定义请求类型的枚举
typedef NS_ENUM(NSUInteger,HttpRequestType)
{
  
  HttpRequestTypeGet = 0,
  HttpRequestTypePost
  
};
typedef void(^requestSuccess)( NSDictionary * object);

typedef void(^requestFailure)( NSError *error);
typedef void(^uploadProgress)(float progress);
typedef void(^downloadProgress)(float progress);


@interface MMNetWorkManager : MMVAFHTTPSessionManager

+(instancetype)shareManager;


+(void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments withSuccessBlock:( requestSuccess)successBlock withFailureBlock:( requestFailure)failureBlock progress:(downloadProgress)progress;


@end


