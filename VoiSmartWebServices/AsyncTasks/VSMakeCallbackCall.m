//
//  VSMakeCallbackCall.m
//  Softphone
//
//  Created by Alex Gotev on 27/01/15.
//  Copyright (c) 2015 voismart. All rights reserved.
//

#import "VSMakeCallbackCall.h"
#import "MBProgressHUD.h"
#import "VSUtility.h"

@interface VSMakeCallbackCall() <VoiSmartWebServiceDelegate>

@property (weak, nonatomic) id<VoiSmartWebServices> webServices;
@property (strong, nonatomic) NSString *numberToCall;
@property (strong, nonatomic) NSString *numberToConnect;

@end

@implementation VSMakeCallbackCall

-(id)initWithWebServices:(id<VoiSmartWebServices>)services
{
    self = [super init];
    
    if (self) {
        self.webServices =  services;
    }
    
    return self;
}

-(void)makeCallToNumber:(NSString *)numberToCall andConnectToNumber:(NSString *)numberToConnect
{
    self.numberToCall =  numberToCall;
    self.numberToConnect = numberToConnect;
    
    [VSUtility showMessageDialogWithLocalizedTitle:@"CALLBACK"
                               andLocalizedMessage:@"CALLBACK_IN_PROGRESS"];

    [self.webServices getLicenseAndSendResponseToDelegate:self];
}

- (void) receivedLicenseIsValid:(BOOL)valid
            withWebServiceToken:(NSString *)webServiceToken
                          error:(NSError *)error
{
    if (valid && webServiceToken != nil && [webServiceToken length] > 0) {
        [self.webServices makeCallWithToken:webServiceToken
                                   toNumber:self.numberToCall
                         andConnectToNumber:self.numberToConnect
                                   delegate:self];
        //async response sent to receivedUserExtensions:error:
        
    } else {
        [VSUtility showMessageDialogWithLocalizedTitle:@"WARNING"
                                   andLocalizedMessage:@"INVALID_LICENSE"];
    }
}

-(void)makeCallResult:(BOOL)success
{
    if (!success)
        [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                   andLocalizedMessage:@"CALLBACK_ERROR"];
}

@end
