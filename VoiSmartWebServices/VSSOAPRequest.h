//
//  VSSOAPRequest.h
//  VoiSmart Web Services
//
//  Created by Alex on 11/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@interface VSSOAPRequest : NSObject <NSURLConnectionDataDelegate>

- (void) sendSOAPRequestToUrl:(NSString *)url
              soapRequestBody:(NSString *)soapRequestBody
executeWhenResponseIsSuccessful:(void (^)(DDXMLDocument *))successCallBack
     executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack;

@end
