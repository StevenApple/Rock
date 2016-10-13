//
//  VoiSmartWebServicesFactory.h
//  VoiSmart Web Services
//
//  Created by Alex on 14/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Orchestra5WebServices.h"
#import "OrchestraNGWebServices.h"

typedef NS_ENUM(NSInteger, VSOrchestraVersion) {
    ORCHESTRA_5,
    ORCHESTRA_NG
};

@interface VoiSmartWebServicesFactory : NSObject

+ (id<VoiSmartWebServices>)getVersion:(VSOrchestraVersion)version;

+ (NSString *) getUsernameFromJabberIDstring:(NSString *)jabberId;

@end
