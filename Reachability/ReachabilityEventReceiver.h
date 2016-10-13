// This is a helper class to receive reachability events.
// Just initialize this class in yours and implement the delegate methods.
// Each delegate method is self-explanatory and gets called only when connection changes.
// Use start on load and stop when you don't need to be notified.
// You MUST call the stop method before your object gets deallocated.
//
// Bear in mind that somewhere in the application you got to initialize and
// start the reachability notifier, as follows:
//
// #import "Reachability.h"
//
// ...
// Reachability *reachability = [Reachability reachabilityForInternetConnection];
// [reachability startNotifier];

// Before the object in which you have initialized the Reachability
// is deallocated, you MUST call:
//
// [reachability stopNotifier];
//
// FURTHER NOTES:
// In your -Prefix.pch file add the following:
// #import <Availability.h>
// #ifndef __IPHONE_6_0
// #warning "This project uses features only available in iOS SDK 6.0 and later."
// #endif
//
// @author Alex Gotev

#import <Foundation/Foundation.h>

@protocol ReachabilityEventReceiverDelegate <NSObject>

@optional
- (void)onInternetReachableViaWiFi;
- (void)onInternetReachableVia3G;
- (void)onInternetUnreachable;

@end

@interface ReachabilityEventReceiver : NSObject

- (id) initWithDelegate:(id<ReachabilityEventReceiverDelegate>)delegate;

// Start listening for events
- (void) start;

// Stop listening for events
- (void) stop;

@end
