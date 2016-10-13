#import "VSUtility.h"
#import "MBProgressHUD.h"
#import <MapKit/MapKit.h>
#import "VSConfiguration.h"
#import "PJSipWrapper.h"
#import "VSMakeCallbackCall.h"
#include <arpa/inet.h>

@implementation VSUtility

+ (UIViewController *) getViewControllerWithIdentifier:(NSString *)identifier
                                    fromStorybordNamed:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    return controller;
}

+ (NSURL *) getApplicationDocumentDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (void) initCoreDataDocumentWithName:(NSString *)documentName
                onSuccessPerformBlock:(void (^) (UIManagedDocument *))successBlock
                onErrorPerformBlock:(void (^) (void))errorBlock
{
    NSURL *pathURL = [[self getApplicationDocumentDirectory] URLByAppendingPathComponent:documentName];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:pathURL];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[pathURL path]]) {
        [document openWithCompletionHandler:^(BOOL success){
            if (success)
                successBlock(document);
            else
                errorBlock();
        }];
    } else {
        [document saveToURL:pathURL
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success){
              if (success)
                  successBlock(document);
              else
                  errorBlock();
          }];
    }
}

+ (BOOL) applicationIsNotActive
{
    return ([UIApplication sharedApplication].applicationState != UIApplicationStateActive);
}

+ (NSNumber *) getNowTimestamp
{
    return [NSNumber numberWithDouble:([NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970)];
}

+ (BOOL)isMultitaskingSupported
{
    return [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]
            && [[UIDevice currentDevice] isMultitaskingSupported];
}

+ (void) showMessageDialogWithLocalizedTitle:(NSString *)title
                         andLocalizedMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(title, nil)
                          message:NSLocalizedString(message, nil)
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
    
    [alert show];
}

+ (void) showMessageDialogWithTitle:(NSString *)title
                         andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    
    [alert show];
}

+ (UIImage *)imageWithImage:(UIImage *)sourceImage
withMaxWidthOrHeightScaledTo:(float)bound
{
    float originalWidth = sourceImage.size.width;
    float originalHeight = sourceImage.size.height;

    float scaleFactor;
    
    if (originalHeight > originalWidth) {
        scaleFactor = bound / originalHeight;
        
    } else {
        scaleFactor = bound / originalWidth;
    }
    
    float newWidth = originalWidth * scaleFactor;
    float newHeight = originalHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledWithRatio:(double)ratio {
    
    if (ratio < 0.0)
        ratio = 0.0;
    else if (ratio > 1.0)
        ratio = 1.0;
    
    CGSize newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (void)makeGSMphoneCallTo:(NSString *)phoneNumber
{
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *phoneURLString = [NSString stringWithFormat:@"telprompt:%@", escapedPhoneNumber];
    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    
    } else {
        [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                   andLocalizedMessage:@"DEVICE_CANT_MAKE_GSM_CALLS"];
    }
}

+ (void)openMapsToAddress:(NSString *)string inView:(UIView *)view
{
    NSString *oneLineAddress = [string stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
    
    [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:oneLineAddress
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         [MBProgressHUD hideAllHUDsForView:view animated:YES];

                         // Convert the CLPlacemark to an MKPlacemark
                         // Note: There's no error checking for a failed geocode
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc]
                                                   initWithCoordinate:geocodedPlacemark.location.coordinate
                                                   addressDictionary:geocodedPlacemark.addressDictionary];
                         
                         // Create a map item for the geocoded address to pass to Maps app
                         MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:geocodedPlacemark.name];
                         
                         // Set the directions mode to "Driving"
                         // Can use MKLaunchOptionsDirectionsModeWalking instead
                         NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                         
                         // Get the "Current User Location" MKMapItem
                         MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                         
                         // Pass the current location and destination map items to the Maps app
                         // Set the direction mode in the launchOptions dictionary
                         [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                         
                     }];
    } else {
        [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                   andLocalizedMessage:@"DEVICE_NO_NAVIGATION"];
    }
}

+ (NSArray *)getAllFilesInAppDocuments
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error;

    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath
                                                               error:&error];
}

+ (NSArray *)getAllFilesInAppDocumentsWithExtension:(NSString *)extension
{
    NSArray *allFiles = [VSUtility getAllFilesInAppDocuments];
    NSMutableArray *filteredFiles = [NSMutableArray arrayWithCapacity:[allFiles count]];

    for (NSString *file in allFiles) {
        if ([file hasSuffix:extension]) {
            [filteredFiles addObject:file];
        }
    }
    
    return [NSArray arrayWithArray:filteredFiles];
}

+(void) makeCallTo:(NSString *)phoneNumber
{
    if ([phoneNumber length] > 0) {
        VSAccountConfig *accountConfig = [VSConfiguration sharedInstance].accountConfig;
        
        if (![accountConfig isDefined]) {
            [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                       andLocalizedMessage:@"NO_ACCOUNT"];
            return;
        }
        
        if ([accountConfig isVoIPCallType]) {
            if (![[PJSipWrapper sharedInstance] isRegistered]) {
                [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                           andLocalizedMessage:@"CALL_ERROR_SIP_UNREGISTERED"];
                return;
            }
            
            long session = [[PJSipWrapper sharedInstance] makeCallTo:phoneNumber];
            
            if (session < 0) {
                [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                           andLocalizedMessage:@"CALL_ERROR_CONNECTIVITY"];
            }
            
        } else {
            if (accountConfig.myPhoneNumber == nil || [accountConfig.myPhoneNumber length] == 0) {
                [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                           andLocalizedMessage:@"CALL_ERROR_CALLBACK_NOT_CONFIGURED"];
            
            } else if (accountConfig.orchestraVersion == ORCHESTRA_5) {
                [VSUtility showMessageDialogWithLocalizedTitle:@"ERROR"
                                           andLocalizedMessage:@"CALLBACK_NOT_SUPPORTED"];
            
            } else {
                VSMakeCallbackCall *callback = [[VSMakeCallbackCall alloc]
                                                initWithWebServices:[accountConfig getWebServicesInstance]];
                [callback makeCallToNumber:phoneNumber
                        andConnectToNumber:accountConfig.myPhoneNumber];
            }
        }
    }
}

+(BOOL)isNumber:(NSString *)string {
    return ([string rangeOfCharacterFromSet:[[NSMutableCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound);
}

+(BOOL)isIPaddress:(NSString *)string
{
    struct sockaddr_in sa;
    int result = inet_pton(AF_INET, [string cStringUsingEncoding:NSASCIIStringEncoding], &(sa.sin_addr));
    return result != 0;
}

@end
