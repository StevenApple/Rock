#import <Foundation/Foundation.h>

@interface VSFileToUpload : NSObject

-(id)initWithPath:(NSString *)path
    parameterName:(NSString *)parameterName
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType;

-(id)initWithData:(NSData *)data
    parameterName:(NSString *)parameterName
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType;

- (NSData *)getMultipartHeader;

- (NSData *)getData;

- (long)length;

@end
