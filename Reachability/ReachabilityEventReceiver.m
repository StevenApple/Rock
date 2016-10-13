#import "ReachabilityEventReceiver.h"
#import "Reachability.h"

@interface ReachabilityEventReceiver()

@property (nonatomic, strong) id<ReachabilityEventReceiverDelegate> delegate;
@property (nonatomic, assign) BOOL started;

@end

@implementation ReachabilityEventReceiver

- (id) initWithDelegate:(id<ReachabilityEventReceiverDelegate>)delegate
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
                                             selector:@selector(handleReachabilityEvent:)
                                                 name:kReachabilityChangedNotification
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

- (void)handleReachabilityEvent:(NSNotification *)notification
{
    Reachability *reachability = [notification object];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    switch (status) {
        case ReachableViaWiFi:
            [self invokeDelegateSelector:@selector(onInternetReachableViaWiFi)];
            break;
            
        case ReachableViaWWAN:
            [self invokeDelegateSelector:@selector(onInternetReachableVia3G)];
            break;
            
        case NotReachable:
            [self invokeDelegateSelector:@selector(onInternetUnreachable)];
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
