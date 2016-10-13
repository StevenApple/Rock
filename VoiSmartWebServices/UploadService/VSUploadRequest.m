#import "VSUploadRequest.h"
#import "VSFileToUpload.h"
#import "VSNameValue.h"

@interface VSUploadRequest()

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableArray *filesToUpload; //Array of VSFileToUpload
@property (strong, nonatomic) NSMutableArray *headers; //Array of VSNameValue
@property (strong, nonatomic) NSMutableArray *parameters; //Array of VSNameValue

@end

@implementation VSUploadRequest

- (id)initWithServerURL:(NSString *)serverUrl
{
    self = [super init];
    
    if (self) {
        _url = serverUrl;
    }
    
    return self;
}

- (NSArray *)filesToUpload
{
    if (_filesToUpload == nil) {
        _filesToUpload = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return _filesToUpload;
}

- (NSMutableArray *)headers
{
    if (_headers == nil) {
        _headers = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return _headers;
}

- (NSMutableArray *)parameters
{
    if (_parameters == nil) {
        _parameters = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return _parameters;
}

- (void)validate
{
    if (self.url == nil || [self.url isEqualToString:@""]) {
        [NSException raise:@"Request URL cannot be either null or empty"
                    format:@"Request URL cannot be either null or empty"];
    }
    
    if (![self.url hasPrefix:@"http"]) {
        [NSException raise:@"Specify either http:// or https:// as protocol"
                    format:@"Specify either http:// or https:// as protocol"];
    }
    
    if ([self.filesToUpload count] == 0) {
        [NSException raise:@"You have to add at least one file to upload"
                    format:@"You have to add at least one file to upload"];
    }
}

-(void)addFileToUploadWithPath:(NSString *)path
                 parameterName:(NSString *)parameterName
                      fileName:(NSString *)fileName
                andContentType:(NSString *)contentType
{
    VSFileToUpload *newFile = [[VSFileToUpload alloc]
                               initWithPath:path
                               parameterName:parameterName
                               fileName:fileName
                               contentType:contentType];
    [self.filesToUpload addObject:newFile];
}

-(void)addFileToUploadWithData:(NSData *)data
                 parameterName:(NSString *)parameterName
                      fileName:(NSString *)fileName
                andContentType:(NSString *)contentType
{
    VSFileToUpload *newFile = [[VSFileToUpload alloc]
                               initWithData:data
                               parameterName:parameterName
                               fileName:fileName
                               contentType:contentType];
    [self.filesToUpload addObject:newFile];
}

-(void)addHeaderWithName:(NSString *)headerName
                andValue:(NSString *)headerValue
{
    VSNameValue *header = [[VSNameValue alloc] initWithName:headerName
                                                   andValue:headerValue];
    [self.headers addObject:header];
}

-(void)addParameterWithName:(NSString *)parameterName
                   andValue:(NSString *)parameterValue
{
    VSNameValue *parameter = [[VSNameValue alloc] initWithName:parameterName
                                                      andValue:parameterValue];
    [self.parameters addObject:parameter];
}

-(NSString *)getServerUrl
{
    return self.url;
}

-(NSArray *)getFilesToUpload
{
    return [NSArray arrayWithArray:self.filesToUpload];
}

-(NSArray *)getHeaders
{
    return [NSArray arrayWithArray:self.headers];
}

-(NSArray *)getParameters
{
    return [NSArray arrayWithArray:self.parameters];
}

@end
