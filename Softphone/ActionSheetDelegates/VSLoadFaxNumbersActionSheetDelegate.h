#import <Foundation/Foundation.h>
#import "VoiSmartWebServicesFactory.h"

//Contains the fax numbers that are loaded
typedef void(^SelectedFaxNumber)(NSString *);

@interface VSLoadFaxNumbersActionSheetDelegate : NSObject <VoiSmartWebServiceDelegate, UIActionSheetDelegate>

-(void)showInViewController:(UIViewController *)controller
         onCompletedExecute:(SelectedFaxNumber)block;

@end
