//
//  VSWebServiceError.m
//  VoiSmart Web Services
//
//  Created by Alex on 17/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VSWebServiceError.h"

/**
 * When you make changes here, don't forget to reflect them also in the
 * VSWebServiceErrorCode declaration in VSWebServiceError.h
 */
static NSString *const VSWebServiceErrorCodeDescriptionKey[] = {
    [VS_WS_CONNECTION_ERROR] = @"Error while connecting to the PBX",
    [VS_WS_LOGIN_ERROR] = @"Error while logging in into the PBX",
    [VS_WS_NO_LICENSE] = @"You don't have the required license",
    [VS_WS_NO_SIP_ACCOUNTS] = @"You don't have any SIP account"
};

@implementation VSWebServiceError

- (id) initWithErrorCode:(VSWebServiceErrorCode)errorCode
{
    self = [super initWithDomain:VSWebServiceErrorDomain
                            code:errorCode
                        userInfo:@{NSLocalizedDescriptionKey:VSWebServiceErrorCodeDescriptionKey[errorCode]}];
    
    return self;
}

- (NSString *)localizedDescription
{
    return [self.userInfo valueForKey:NSLocalizedDescriptionKey];
}

@end
