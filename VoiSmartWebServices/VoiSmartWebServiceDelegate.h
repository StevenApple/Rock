//
//  VoiSmartWebServiceDelegate.h
//  VoiSmart Web Services
//
//  Created by Alex on 08/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSWebServiceError.h"
#import "VSSipAccountConfig.h"
#import "VSCallRegistryItem.h"
#import "VSContact.h"
#import "VSPhoneNumber.h"

@protocol VoiSmartWebServiceDelegate <NSObject>

@optional
- (void) loginResponseReceivedWithSuccess:(BOOL)success
                                    token:(NSString *)token
                        validityInSeconds:(long)validityInSeconds
                                    error:(NSError *)error;

- (void) receivedLicenseIsValid:(BOOL)valid
            withWebServiceToken:(NSString *)webServiceToken
                          error:(NSError *)error;

- (void) receivedSipAccounts:(NSArray *)sipAccounts
                       error:(NSError *)error;

- (void) receivedCalls:(NSArray *)calls
                 error:(NSError *)error;

- (void) receivedContacts:(NSArray *)contacts
                    error:(NSError *)error;

- (void) receivedUserExtensions:(NSArray *)extensions
                          error:(NSError *)error;

- (void) receivedFaxNumbers:(NSArray *)faxNumbers
                      error:(NSError *)error;

- (void) faxProgressChanged:(NSNumber *)percent;

- (void) faxSendingCompletedWithResponseCode:(NSNumber *)code
                                  andMessage:(NSString *)message;

- (void) faxSendingError:(NSError *)error;

- (void) makeCallResult:(BOOL)success;

@end
