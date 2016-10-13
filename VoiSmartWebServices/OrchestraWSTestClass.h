//
//  OrchestraNGTestClass.h
//  VoiSmart Web Services
//
//  Created by Alex on 09/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiSmartWebServicesFactory.h"

@interface OrchestraWSTestClass : NSObject<VoiSmartWebServiceDelegate>

- (id) initWithWebServiceImplementation:(id<VoiSmartWebServices>)webServices
                               username:(NSString *)username
                               password:(NSString *)password
                                   host:(NSString *)host;

- (id) initWithOrchestra5;
- (id) initWithOrchestraNG;

- (void) startTest;

@end
