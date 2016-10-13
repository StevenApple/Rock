//
//  AppDelegate.m
//  Softphone
//
//  Created by Alex Gotev on 01/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "AppDelegate.h"
#import "VSIncomingCallViewController.h"
#import "VSInCallViewController.h"
#import "VSLocalNotifications.h"
#import "VSUtility.h"
#import "Configuration/VSConfiguration.h"
#import <FXForms.h>
#import "VSConnectionService.h"
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) VSIncomingCallViewController *incomingCall;
@property (strong, nonatomic) VSInCallViewController *inCall;
@property (strong, nonatomic) Reachability *reachability;

@end

@implementation AppDelegate

PJSipNotificationsReceiver *sipNotifications;
VSConnectionServiceEventReceiver *connServiceReceiver;
UILocalNotification *incomingCallNotification = nil;

- (VSIncomingCallViewController *)incomingCall
{
    if (_incomingCall == nil) {
        _incomingCall = (VSIncomingCallViewController *) [VSUtility getViewControllerWithIdentifier:@"IncomingCall"
                                                                                 fromStorybordNamed:@"Main"];
    }
    
    return _incomingCall;
}

- (VSInCallViewController *)inCall
{
    if (_inCall == nil) {
        _inCall = (VSInCallViewController *) [VSUtility getViewControllerWithIdentifier:@"InCall"
                                                                     fromStorybordNamed:@"Main"];
    }
    
    return _inCall;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Crashlytics startWithAPIKey:@"5ffa8dde03e4a1bd2be8de45316e0afbaddee63c"];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // The following line must only run under iOS 8. This runtime check prevents
    // it from running if it doesn't exist (such as running under iOS 7 or earlier).
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
#endif
    
    //Setup SIP events receiver
    sipNotifications = [[PJSipNotificationsReceiver alloc] init];
    sipNotifications.delegate = self;
    [sipNotifications registerObserver];
    
    //Setup connection service event receiver
    connServiceReceiver = [[VSConnectionServiceEventReceiver alloc] initWithDelegate:self];
    [connServiceReceiver start];
    
    //Initialize connection service
    [VSConnectionService sharedInstance];
    
    //Setup host
    VSAccountConfig *accCfg = [[VSConfiguration sharedInstance] accountConfig];
    if ([accCfg isDefined]) {
        [self setReachabilityHost:accCfg.pbxAddress];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)backgroundKeepAlive {
    NSLog(@"Executing background SIP keep alive");
    [[PJSipWrapper sharedInstance] keepAliveInBackground];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Entering in background mode...");
    /* Send keep alive manually at the beginning of background */
    //pjsip_endpt_send_raw(...)
    [[PJSipWrapper sharedInstance] sendKeepAlive];
    
    /* iOS requires that the minimum keep alive interval is 600s */
    [application setKeepAliveTimeout:600 handler: ^{
        [self performSelectorOnMainThread:@selector(backgroundKeepAlive)
                               withObject:nil waitUntilDone:YES];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (notification == nil || notification.userInfo == nil) return;
    
    //Check if notification has been received while the app was in background
    if (application.applicationState == UIApplicationStateInactive) {
        
        //Get notification name
        NSString *notificationName = (NSString *)[notification.userInfo valueForKey:VS_NOTIFICATION_NAME];
        
        //If it's an incoming call notification
        if ([notificationName isEqualToString:VS_NOTIFICATION_INCOMING_CALL]) {
            int callId = [(NSNumber *)[notification.userInfo valueForKey:VS_PARAM_CALL_ID] intValue];
            NSString *displayName = (NSString *)[notification.userInfo valueForKey:VS_PARAM_DISPLAY_NAME];
            NSString *sipURI = (NSString *)[notification.userInfo valueForKey:VS_PARAM_SIP_URI];
        
            [self showIncomingCallViewForCallId:callId displayName:displayName sipURI:sipURI];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[PJSipWrapper sharedInstance] shutdown];
    [sipNotifications unregisterObserver];
    [connServiceReceiver stop];
}

- (void)removeIncomingCallNotification
{
    if (incomingCallNotification != nil)
        [[UIApplication sharedApplication] cancelLocalNotification:incomingCallNotification];
    
    incomingCallNotification = nil;
}

-(void)showIncomingCallViewForCallId:(int)callId
                         displayName:(NSString *)displayName
                              sipURI:(NSString *)sipURI
{
    self.incomingCall.displayName = displayName;
    self.incomingCall.sipURI = sipURI;
    self.incomingCall.callId = callId;
    
    //Presenting must be done on the main UI Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window.rootViewController presentViewController:self.incomingCall animated:YES completion:nil];
    });
}

#pragma mark - SIP events

-(void)onAccountRegistered:(int)accountId
{
    //DO NOTHING
}

-(void)onAccountUnregistered:(int)accountId
{
    //DO NOTHING
}

- (void)onMissedIncomingCallFromDisplayName:(NSString *)displayName
                                  andSipURI:(NSString *)sipURI
{
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];

    [self removeIncomingCallNotification];
    
    [VSLocalNotifications missedIncomingCallNotificationWithDisplayName:displayName
                                                              andSipURI:sipURI];
}

- (void)onIncomingCallWithId:(int)callId
                     account:(int)accountId
             fromDisplayName:(NSString *)displayName
                   andSipURI:(NSString *)sipURI
{
    //Application is in foreground
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self showIncomingCallViewForCallId:callId displayName:displayName sipURI:sipURI];

    //Application is in background
    } else {
        incomingCallNotification = [VSLocalNotifications incomingCallNotificationWithID:callId
                                                                              accountId:accountId
                                                                            displayName:displayName
                                                                              andSipURI:sipURI];
    }
}

- (void)onCallInProgressWithId:(int)callId
                   displayName:(NSString *)displayName
                     andSipURI:(NSString *)sipURI
{
    self.inCall.displayName = displayName;
    self.inCall.sipURI = sipURI;
    self.inCall.callId = callId;
    
    //Presenting must be done on the main UI Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window.rootViewController presentViewController:self.inCall animated:YES completion:nil];
    });
}

- (void)onCallTerminatedWithId:(int)callId
{
    [self removeIncomingCallNotification];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)onIncomingDTMFdigit:(NSString *)dtmfDigit
            fromCallWithId:(int)callId
{
    //Do nothing
}

#pragma mark - Reachability

-(void)setReachabilityHost:(NSString *)host
{
    NSLog(@"Reachability host set to: %@", host);

    //Stop previous notifier, if exists
    if (self.reachability != nil) {
        [self.reachability stopNotifier];
    }
    
    if ([VSUtility isIPaddress:host]) {
        self.reachability = [Reachability reachabilityWithIPaddress:host];
    } else {
        self.reachability = [Reachability reachabilityWithHostName:host];
    }
    [self.reachability startNotifier];
}

-(NetworkStatus)currentNetworkStatus
{
    if (self.reachability == nil) return NotReachable;
    
    return [self.reachability currentReachabilityStatus];
}

#pragma mark - Connection service event receiver delegate -

- (void)onConnectionServiceLoginError
{
    [VSUtility showMessageDialogWithTitle:NSLocalizedString(@"WARNING", nil)
                               andMessage:NSLocalizedString(@"LOGIN_ERROR", nil)];
}

- (void)onConnectionServiceNoInternetConnection
{
    [VSUtility showMessageDialogWithTitle:NSLocalizedString(@"WARNING", nil)
                               andMessage:NSLocalizedString(@"PBX_UNREACHABLE", nil)];
}

- (void)onConnectionServiceNoLicense
{
    [VSUtility showMessageDialogWithTitle:NSLocalizedString(@"WARNING", nil)
                               andMessage:NSLocalizedString(@"INVALID_LICENSE", nil)];
}

- (void)onConnectionServiceNoSipAccounts
{
    [VSUtility showMessageDialogWithTitle:NSLocalizedString(@"WARNING", nil)
                               andMessage:NSLocalizedString(@"NO_SIP_ACCOUNT", nil)];
}

- (void)onConnectionServiceXmppLoginError
{
    [VSUtility showMessageDialogWithTitle:NSLocalizedString(@"WARNING", nil)
                               andMessage:NSLocalizedString(@"CHAT_LOGIN_ERROR", nil)];
}

@end
