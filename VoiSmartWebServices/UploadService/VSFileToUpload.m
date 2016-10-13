#import "VSFileToUpload.h"

#define VS_FILE_TO_UPLOAD_NEW_LINE @"\r\n"

@interface VSFileToUpload()

@property (strong, nonatomic) NSString *file;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *paramName;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSData *data;

@end

@implementation VSFileToUpload

-(id)initWithPath:(NSString *)path
    parameterName:(NSString *)parameterName
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType
{
    self = [super init];
    
    if (self) {
        _file = path;
        _paramName = parameterName;
        _contentType = contentType;
        _fileName = fileName;
        
        if (_fileName == nil || [_fileName isEqualToString:@""]) {
            _fileName = [_file lastPathComponent];
        }
    }
    
    return self;
}

-(id)initWithData:(NSData *)data
    parameterName:(NSString *)parameterName
         fileName:(NSString *)fileName
      contentType:(NSString *)contentType
{
    self = [super init];
    
    if (self) {
        _data = data;
        _paramName = parameterName;
        _contentType = contentType;
        _fileName = fileName;
        
        if (_fileName == nil || [_fileName isEqualToString:@""]) {
            _fileName = [_file lastPathComponent];
        }
    }
    
    return self;
}

- (NSData *)getMultipartHeader
{
    NSString *format = @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n";
    return [[NSString stringWithFormat:format,
            self.paramName,
            self.fileName,
            self.contentType]
            dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getData
{
    if (_data == nil) {
        return [NSData dataWithContentsOfFile:self.file];
    }

    return self.data;
}

- (long)length
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:self.file
                                    error:nil];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    return [fileSizeNumber longValue];
}

@end
