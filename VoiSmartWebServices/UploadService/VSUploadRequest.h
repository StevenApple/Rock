#import <Foundation/Foundation.h>

@interface VSUploadRequest : NSObject

-(id)initWithServerURL:(NSString *)serverUrl;

-(void)validate;

-(void)addFileToUploadWithPath:(NSString *)path
                 parameterName:(NSString *)parameterName
                      fileName:(NSString *)fileName
                andContentType:(NSString *)contentType;

-(void)addFileToUploadWithData:(NSData *)data
                 parameterName:(NSString *)parameterName
                      fileName:(NSString *)fileName
                andContentType:(NSString *)contentType;

-(void)addHeaderWithName:(NSString *)headerName
                andValue:(NSString *)headerValue;

-(void)addParameterWithName:(NSString *)parameterName
                   andValue:(NSString *)parameterValue;

-(NSString *)getServerUrl;

-(NSArray *)getFilesToUpload;

-(NSArray *)getHeaders;

-(NSArray *)getParameters;

@end
