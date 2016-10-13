#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VoiSmartWebService.h"

@interface VSUserExtensionsRetriever : NSObject

- (id)initWithWebServices:(id<VoiSmartWebServices>)services;

- (void)retrieveExtensionsForUsername:(NSString *)username
                            withAlias:(NSString *)alias
                     inViewController:(UIViewController *)viewController;

@end