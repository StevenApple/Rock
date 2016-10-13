//
//  VoiSmartWebServicesFactory.m
//  VoiSmart Web Services
//
//  Created by Alex on 14/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VoiSmartWebServicesFactory.h"

static id<VoiSmartWebServices> wsInstance = nil;
static VSOrchestraVersion instanceVersion;

@implementation VoiSmartWebServicesFactory

+ (id<VoiSmartWebServices>) getVersion:(VSOrchestraVersion)version
{
    if (wsInstance == nil || version != instanceVersion) {
        switch (version) {
            case ORCHESTRA_5:
                wsInstance = [[Orchestra5WebServices alloc] init];
                instanceVersion = ORCHESTRA_5;
                break;
                
            case ORCHESTRA_NG:
                wsInstance = [[OrchestraNGWebServices alloc] init];
                instanceVersion = ORCHESTRA_NG;
                break;
        }
    }
    
    return wsInstance;
}

+ (NSString *) getUsernameFromJabberIDstring:(NSString *)jabberId
{
    NSString *username = nil;
    
    if (jabberId == nil || [jabberId isEqualToString:@""]) {
        username = @"";
    } else if ([jabberId rangeOfString:@"@"].location != NSNotFound) {
        username = [jabberId componentsSeparatedByString:@"@"][0];
    } else {
        username = jabberId;
    }
    
    return username;
}

@end
