#import <Foundation/Foundation.h>
#import "VSUploadRequest.h"

@interface VSUploadService : NSObject <NSURLConnectionDataDelegate>

+ (VSUploadService *) sharedInstance;

- (void)startUploadRequest:(VSUploadRequest *)uploadRequest
executeWhenResponseIsSuccessful:(void (^)(NSInteger, NSData *))successCallBack
  executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack;

@end
