#import "VSNameValue.h"

@interface VSNameValue()

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *value;

@end

@implementation VSNameValue

-(id)initWithName:(NSString *)name
         andValue:(NSString *)value
{
    self = [super init];
    
    if (self) {
        _name = name;
        _value = value;
    }
    
    return self;
}

- (NSString *)name
{
    return _name;
}

- (NSString *)value
{
    return _value;
}

- (NSData *)getBytes
{
    return [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@",
             self.name, self.value] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
