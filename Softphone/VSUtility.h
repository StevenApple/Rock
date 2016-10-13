#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface VSUtility : NSObject

+ (UIViewController *) getViewControllerWithIdentifier:(NSString *)identifier
                                    fromStorybordNamed:(NSString *)storyboard;

// Gets this application's URL of the document directory
+ (NSURL *) getApplicationDocumentDirectory;

// Initializes a CoreData document with a given name in the app's document directory.
//
// If the document already exists, it will be opened, otherwise it will be created.
// The operation is asynchronous, so do everything ONLY into the successBlock
+ (void) initCoreDataDocumentWithName:(NSString *)documentName
                onSuccessPerformBlock:(void (^) (UIManagedDocument *))successBlock
                  onErrorPerformBlock:(void (^) (void))errorBlock;

+ (BOOL) applicationIsNotActive;

+ (NSNumber *) getNowTimestamp;

+ (BOOL) isMultitaskingSupported;

+ (void) showMessageDialogWithLocalizedTitle:(NSString *)title
                         andLocalizedMessage:(NSString *)message;

+ (void) showMessageDialogWithTitle:(NSString *)title
                         andMessage:(NSString *)message;

+ (UIImage *)imageWithImage:(UIImage *)sourceImage
withMaxWidthOrHeightScaledTo:(float)bound;

+ (UIImage *)imageWithImage:(UIImage *)image scaledWithRatio:(double)ratio;

+ (void)makeGSMphoneCallTo:(NSString *)phoneNumber;
+ (void)makeCallTo:(NSString *)phoneNumber;

+ (void)openMapsToAddress:(NSString *)string inView:(UIView *)view;

+ (NSArray *)getAllFilesInAppDocuments;
+ (NSArray *)getAllFilesInAppDocumentsWithExtension:(NSString *)extension;

+(BOOL)isNumber:(NSString *)string;

+(BOOL)isIPaddress:(NSString *)string;

@end
