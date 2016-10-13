//
//  VSMakeCallbackCall.h
//  Softphone
//
//  Created by Alex Gotev on 27/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiSmartWebService.h"

@interface VSMakeCallbackCall : NSObject

- (id)initWithWebServices:(id<VoiSmartWebServices>) services;

- (void)makeCallToNumber:(NSString *)numberToCall
      andConnectToNumber:(NSString *)numberToConnect;

@end
