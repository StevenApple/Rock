//
//  VSWebRequest.h
//  VoiSmart Web Services
//
//  Created by Alex on 08/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSWebRequest : NSObject <NSURLConnectionDataDelegate>

- (void) addParameterWithName:(NSString *)paramName
                     andValue:(NSString *)paramValue;

- (void) sendRequestToURL:(NSString *)url
executeWhenResponseIsSuccessful:(void (^)(NSInteger, NSData *))successCallBack
executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack;

@end
