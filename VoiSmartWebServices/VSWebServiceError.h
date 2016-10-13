//
//  VSWebServiceError.h
//  VoiSmart Web Services
//
//  Created by Alex on 17/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * When you make changes here, don't forget to reflect them also in the
 * VSWebServiceErrorCodeDescriptionKey declaration in VSWebServiceError.m
 */
typedef NS_ENUM(NSInteger, VSWebServiceErrorCode) {
    VS_WS_CONNECTION_ERROR,
    VS_WS_LOGIN_ERROR,
    VS_WS_NO_LICENSE,
    VS_WS_NO_SIP_ACCOUNTS
};

static NSString *const VSWebServiceErrorDomain = @"com.voismart.webservice.error";

@interface VSWebServiceError : NSError

- (id) initWithErrorCode:(VSWebServiceErrorCode)errorCode;

@end
