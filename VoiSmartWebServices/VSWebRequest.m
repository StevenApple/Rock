//
//  VSWebRequest.m
//  VoiSmart Web Services
//
//  Created by Alex on 08/10/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VSWebRequest.h"

@interface VSWebRequest()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, strong) void (^ successCallBackFunction)(NSInteger, NSData *);
@property (nonatomic, strong) void (^ errorCallBackFunction)(NSError *);

@end

@implementation VSWebRequest

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
    self.successCallBackFunction(self.responseCode, self.responseData);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

#pragma mark - Class implementation -

- (NSMutableDictionary *)parameters
{
    if (_parameters == nil)
        _parameters = [[NSMutableDictionary alloc] init];
    
    return _parameters;
}

- (NSMutableData *)responseData
{
    if (_responseData == nil)
        _responseData = [[NSMutableData alloc] init];
    
    return _responseData;
}

- (void)addParameterWithName:(NSString *)paramName andValue:(NSString *)paramValue
{
    if (paramValue != nil)
        [self.parameters setObject:paramValue forKey:paramName];
}

- (NSString *)parameterRepresentationFor:(id)value withName:(NSString *)name {
    
    // Se è una stringa faccio solo l'escape
    if ([value isKindOfClass:[NSString class]])
        return [(NSString *)value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // Se invece è array o dizionario devo prima JSONizzarlo
    else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        
        NSError *error = nil;
        NSString *text = nil;
        NSData   *data = [NSJSONSerialization dataWithJSONObject:value options:kNilOptions error:&error];
        
        if (data)
            text = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (!error)
            return text;
        else {
            NSLog(@"Unable to convert parameter '%@' to JSON: %@.", name, [error description]);
            return nil;
        }
    }
    else
        return nil;
}

- (NSData *)createRequestData {
    
    NSMutableString *messageContent = [[NSMutableString alloc] initWithCapacity:512];
    
    // Metto i vari parametri
    for (NSString *key in self.parameters) {
        
        id value = self.parameters[key];
        NSString *representation = [self parameterRepresentationFor:value withName:key];
        
        if (representation) {
            
            if ([messageContent length] != 0)
                [messageContent appendString:@"&"];
            
            [messageContent appendFormat:@"%@=%@", key, representation];
        }
        else
            NSLog(@"Unsupported parameter representation for key '%@'.", key);
    }
    
    // Loggo il contenuto
    //NSLog(@"New POST request ready:\n - - - \n%@\n - - - \n", messageContent);
    
    // E lo ritorno
    return [messageContent dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)sendRequestToURL:(NSString *)url
executeWhenResponseIsSuccessful:(void (^)(NSInteger, NSData *))successCallBack
executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack
{
    self.successCallBackFunction = successCallBack;
    self.errorCallBackFunction = errorCallBack;
    
    NSData *requestData = [self createRequestData];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%tu", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

@end
