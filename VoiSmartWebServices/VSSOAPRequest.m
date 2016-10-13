//
//  VSSOAPRequest.m
//  VoiSmart Web Services
//
//  Created by Alex on 11/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VSSOAPRequest.h"

@interface VSSOAPRequest()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, strong) void (^ successCallBackFunction)(DDXMLDocument *);
@property (nonatomic, strong) void (^ errorCallBackFunction)(NSError *);

@end

@implementation VSSOAPRequest

#pragma mark - URLConnection Delegate -

- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.errorCallBackFunction(error);
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Qui dovrei controllare se "challenge.protectionSpace.host" è tra quelli
    // di cui non voglio controllare la validità del certificato
    // ma essendo che quell'URL l'ha messo l'utente stesso nelle impostazioni
    // facciamo che va sempre bene!
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        //if ([self.trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

#pragma mark - URLConnection Data Delegate -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseCode = ((NSHTTPURLResponse *)response).statusCode;
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    DDXMLDocument *response = [[DDXMLDocument alloc] initWithData:self.responseData options:0 error:&error];
    
    if (!error) {
        DDXMLNode *faultCode = [[response nodesForXPath:@"//faultcode/text()" error:&error] lastObject];
        DDXMLNode *faultDescription = [[response nodesForXPath:@"//faultstring/text()" error:nil] lastObject];
        
        if (faultCode) {
            NSLog(@"Soap Web Service failed with fault code %@ and description: %@",
                  [faultCode stringValue], [faultDescription stringValue]);
            self.errorCallBackFunction(error);
        } else {
            self.successCallBackFunction(response);
        }
        
    } else {
        self.errorCallBackFunction(error);
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

#pragma mark - Class implementation -

- (NSMutableData *)responseData
{
    if (_responseData == nil)
        _responseData = [[NSMutableData alloc] init];
    
    return _responseData;
}

- (void) sendSOAPRequestToUrl:(NSString *)url
              soapRequestBody:(NSString *)soapRequestBody
executeWhenResponseIsSuccessful:(void (^)(DDXMLDocument *))successCallBack
executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack
{
    self.successCallBackFunction = successCallBack;
    self.errorCallBackFunction = errorCallBack;
    
    NSString *soapRequest = [NSString stringWithFormat:
                    @"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                    "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
                    "xmlns:ns1=\"http://www.voismart.it/\">\n"
                    "<soapenv:Header/>\n"
                    "<soapenv:Body>\n%@\n"
                    "</soapenv:Body>\n"
                    "</soapenv:Envelope>", soapRequestBody];
    
    //NSLog(@"SOAP Request ready -------\n\n%@", soapRequest);
    
    NSData *soapData = [soapRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    unsigned long dataLength = (unsigned long)[soapData length];
    [request addValue:[NSString stringWithFormat:@"%lu", dataLength] forHTTPHeaderField:@"Content-Length"];
    [request addValue:url forHTTPHeaderField:@"SOAPAction"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:soapData];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

@end
