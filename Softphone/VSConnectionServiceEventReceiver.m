#import "VSConnectionServiceEventReceiver.h"
#import "VSConnectionService.h"

@interface VSConnectionServiceEventReceiver()

@property (nonatomic, strong) id<VSConnectionServiceEventReceiverDelegate> delegate;
@property (nonatomic, assign) BOOL started;

@end

@implementation VSConnectionServiceEventReceiver

- (id) initWithDelegate:(id<VSConnectionServiceEventReceiverDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
        self.started = NO;
    }
    
    return self;
}

- (void) start
{
    if (self.started)  return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleConnectionServiceEvent:)
                                                 name:VS_CONNECTION_SERVICE_NOTIFICATION
                                               object:nil];
    self.started = YES;
}

- (void) stop
{
    if (!self.started) return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.started = NO;
}

- (void) dealloc
{
    [self stop];
}

- (void)handleConnectionServiceEvent:(NSNotification *)notification
{
    if (![VS_CONNECTION_SERVICE_NOTIFICATION isEqualToString:notification.name]) return;
    VSConnectionServiceStatus status =
        [(NSNumber *)[notification.userInfo objectForKey:VS_CONNECTION_SERVICE_NOTIFICATION_STATUS] integerValue];

    switch (status) {
        case VS_CONNECTION_SERVICE_LOGIN_ERROR:
            [self invokeDelegateSelector:@selector(onConnectionServiceLoginError)];
            break;

        case VS_CONNECTION_SERVICE_NO_LICENSE:
            [self invokeDelegateSelector:@selector(onConnectionServiceNoLicense)];
            break;

        case VS_CONNECTION_SERVICE_LOGIN_OK:
            [self invokeDelegateSelector:@selector(onConnectionServiceLoginOk)];
            break;

        case VS_CONNECTION_SERVICE_NO_SIP_ACCOUNTS:
            [self invokeDelegateSelector:@selector(onConnectionServiceNoSipAccounts)];
            break;

        case VS_CONNECTION_SERVICE_XMPP_LOGIN_ERROR:
            [self invokeDelegateSelector:@selector(onConnectionServiceXmppLoginError)];
            break;

        case VS_CONNECTION_SERVICE_NO_INTERNET_CONNECTION:
            [self invokeDelegateSelector:@selector(onConnectionServiceNoInternetConnection)];
            break;

        default:
            break;
    }
}

- (void)invokeDelegateSelector:(SEL)selector
{
    if ([self.delegate respondsToSelector:selector]) {
        //This generates a compile time warning and it's obvious
        //because the compiler doesn't know which selector gets passed at compile time
        //because it's dynamic at runtime.
        //We can safely ignore that warning, because we protect ourselves from
        //crashes by testing if the class responds to the selector prior to performing it
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [self.delegate performSelector:selector];
        
#pragma clang diagnostic pop
        
    } else {
        [self logThatDelegateDoesNotImplementMethod:NSStringFromSelector(selector)];
    }
}

- (void) logThatDelegateDoesNotImplementMethod:(NSString *)methodName
{
    NSLog(@"Delegate '%@' does not implement method '%@'",
          NSStringFromClass([self.delegate class]), methodName);
}

@end
