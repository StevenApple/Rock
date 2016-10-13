#import <Foundation/Foundation.h>

@interface VSNameValue : NSObject

-(id)initWithName:(NSString *)name
         andValue:(NSString *)value;

- (NSString *)name;

- (NSString *)value;

- (NSData *)getBytes;

@end
