//
//  OrchestraNGWebServices.h
//  VoiSmart Web Services
//
//  Created by Alex on 08/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiSmartWebServicesFactory.h"
#import "VoiSmartWebService.h"
#import "VSWebRequest.h"
#import "CachedStringWithFailureExpiration.h"
#import "VSUploadRequest.h"

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

@interface OrchestraNGWebServices : NSObject <VoiSmartWebServices>

@end
