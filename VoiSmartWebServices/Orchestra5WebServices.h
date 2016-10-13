//
//  Orchestra5WebServices.h
//  VoiSmart Web Services
//
//  Created by Alex on 11/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiSmartWebServicesFactory.h"
#import "VoiSmartWebService.h"
#import "VSSOAPRequest.h"
#import "CachedStringWithFailureExpiration.h"
#import "VSUploadRequest.h"
#import "VSUploadService.h"

@interface Orchestra5WebServices : NSObject <VoiSmartWebServices>

@end
