#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//The first string is the number and the second one is the owner name
typedef void(^SelectedNumberBlock)(NSString *, NSString *);

@interface VSInsertNumberActionSheetDelegate : NSObject <UIActionSheetDelegate, UIAlertViewDelegate>

-(void)showInViewController:(UIViewController *)controller
    onNumberProvidedExecute:(SelectedNumberBlock)block;

@end
