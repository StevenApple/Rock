#import <Foundation/Foundation.h>

@protocol VSConnectionServiceEventReceiverDelegate <NSObject>

@optional
-(void)onConnectionServiceLoginError;
-(void)onConnectionServiceNoLicense;
-(void)onConnectionServiceLoginOk;
-(void)onConnectionServiceNoSipAccounts;
-(void)onConnectionServiceXmppLoginError;
-(void)onConnectionServiceNoInternetConnection;

@end

@interface VSConnectionServiceEventReceiver : NSObject

- (id) initWithDelegate:(id<VSConnectionServiceEventReceiverDelegate>)delegate;

// Start listening for events
- (void) start;

// Stop listening for events
- (void) stop;

@end
