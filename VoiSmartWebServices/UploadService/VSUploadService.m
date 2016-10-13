#import "VSUploadService.h"
#import "VSNameValue.h"
#import "VSFileToUpload.h"

static VSUploadService *_sharedInstance = nil;

@interface VSUploadService()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, strong) void (^ successCallBackFunction)(NSInteger, NSData *);
@property (nonatomic, strong) void (^ errorCallBackFunction)(NSError *);

@end

@implementation VSUploadService

+ (VSUploadService *)sharedInstance
{
    @synchronized(self) {
        
        if (!_sharedInstance)
            _sharedInstance = [[VSUploadService alloc] init];
    }
    
    return _sharedInstance;
}

- (void)startUploadRequest:(VSUploadRequest *)uploadRequest
executeWhenResponseIsSuccessful:(void (^)(NSInteger, NSData *))successCallBack
  executeWhenAnErrorOccurs:(void (^)(NSError *))errorCallBack
{
    self.successCallBackFunction = successCallBack;
    self.errorCallBackFunction = errorCallBack;
    
    NSString *boundary = [self getBoundary];
    NSData *boundaryBytes = [self getBoundaryBytesUsingString:boundary];
    
    NSMutableURLRequest *request =
        [self getMultipartHttpURLConnectionWithURL:uploadRequest.getServerUrl
                                           headers:uploadRequest.getHeaders
                                       andBoundary:boundary];
    
    NSMutableData *httpBody = [NSMutableData data];
    
    httpBody = [self setRequestParameters:uploadRequest.getParameters
                        withBoundaryBytes:boundaryBytes
                                 appendTo:httpBody];
    
    httpBody = [self appendFiles:uploadRequest.getFilesToUpload
                              to:httpBody
               withBoundaryBytes:boundaryBytes];
    
    [httpBody appendData:[self getTrailerBytesUsingString:boundary]];
    
    [request setHTTPBody:httpBody];
    
    self.connection = [[NSURLConnection alloc]
                       initWithRequest:[request copy]
                       delegate:self
                       startImmediately:YES];
}

- (NSString *)getBoundary
{
    return [NSString stringWithFormat:@"---------------------------%.0f",
            ([[NSDate date] timeIntervalSince1970] * 100000.0)];
}

- (NSData *)getBoundaryBytesUsingString:(NSString *)boundary
{
    return [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]
            dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getTrailerBytesUsingString:(NSString *)boundary
{
    return [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary]
            dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableURLRequest *)getMultipartHttpURLConnectionWithURL:(NSString *)url
                                               headers:(NSArray *)headers
                                           andBoundary:(NSString *)boundary
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request addValue:@"multipart/form-data" forHTTPHeaderField:@"ENCTYPE"];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
   forHTTPHeaderField:@"Content-Type"];
    
    if (headers && [headers count] > 0) {
        for (VSNameValue *header in headers) {
            [request addValue:header.value forHTTPHeaderField:header.name];
        }
    }
    
    return request;
}

- (NSMutableData *)setRequestParameters:(NSArray *)parameters
                      withBoundaryBytes:(NSData *)boundaryBytes
                               appendTo:(NSMutableData *)data
{
    if (parameters && [parameters count] > 0) {
        for (VSNameValue *parameter in parameters) {
            [data appendData:boundaryBytes];
            [data appendData:parameter.getBytes];
        }
    }
    [data appendData:boundaryBytes];

    return data;
}

- (NSMutableData *)appendFiles:(NSArray *)filesToUpload
                            to:(NSMutableData *)data
             withBoundaryBytes:(NSData *)boundaryBytes
{
    //TODO: use only when showing progress of the operation
    //long totalBytes = [self getTotalBytes:filesToUpload];
    
    for (VSFileToUpload *file in filesToUpload) {
        [data appendData:file.getMultipartHeader];
        [data appendData:file.getData];
        [data appendData:boundaryBytes];
    }
    
    return data;
}

- (long)getTotalBytes:(NSArray *)filesToUpload
{
    long total = 0;
    
    if (filesToUpload && [filesToUpload count] > 0) {
        for (VSFileToUpload *file in filesToUpload) {
            total += file.length;
        }
    }
    
    return total;
}

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

@end
