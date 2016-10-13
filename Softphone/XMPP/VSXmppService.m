//
//  VSXmppService.m
//  Softphone
//
//  Created by Alex on 20/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "VSXmppService.h"
#import "VSConfiguration.h"
#import "VSUtility.h"
#import "XMPPvCardTemp.h"
#import "NSData+XMPP.h"

static VSXmppService *_sharedInstance = nil;

@interface VSXmppService()

@property(strong, nonatomic) XMPPStream *xmppStream;
@property(strong, nonatomic) XMPPReconnect *xmppReconnect;
@property(strong, nonatomic) XMPPRoster *xmppRoster;
@property(strong, nonatomic) XMPPvCardTempModule *vCardTempModule;
@property(strong, nonatomic) XMPPvCardAvatarModule *vCardAvatarModule;

@property(strong, nonatomic) VSXmppStreamDelegate *streamDelegate;
@property(strong, nonatomic) id<XMPPRosterMemoryStorageDelegate> rosterDelegate;

@property (assign, nonatomic) SystemSoundID chatSoundID;
@property (assign, nonatomic) SystemSoundID msgReceivedSoundID;
@property (assign, nonatomic) SystemSoundID msgSentSoundID;

@property (nonatomic, strong) UIManagedDocument *xmppCoreDataDocument;
@property (nonatomic, strong) UIImage *defaultAvatar;

@end

@implementation VSXmppService

+ (VSXmppService *)sharedInstance
{
    @synchronized(self) {
        
        if (!_sharedInstance)
            _sharedInstance = [[VSXmppService alloc] init];
    }
    
    return _sharedInstance;
}

//Initialize the service by setting all the properties and configuring
//the modules
- (id)init
{
    self = [super init];
    
    if (self) {
        void (^successBlock)(UIManagedDocument *) = ^void (UIManagedDocument *document) {
            self.xmppCoreDataDocument = document;
            [self continueInitializationAfterThatCoreDataHasBeenSuccessfullyLoaded];
        };
        
        void (^errorBlock)(void) = ^void () {
            NSLog(@"Error while initializing XMPP Core Data database!");
        };
        
        [VSUtility initCoreDataDocumentWithName:@"IPcommXmppMessages.db"
                          onSuccessPerformBlock:successBlock
                            onErrorPerformBlock:errorBlock];
    }
    
    return self;
}

- (UIImage *)defaultAvatar
{
    if (_defaultAvatar == nil) {
        _defaultAvatar = [UIImage imageNamed:@"Icon-User.png"];
    }
    
    return _defaultAvatar;
}

- (NSManagedObjectContext *) getMessagesContext
{
    return ([self.xmppCoreDataDocument managedObjectContext]);
}

- (void) continueInitializationAfterThatCoreDataHasBeenSuccessfullyLoaded
{
    self.xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    self.xmppStream.enableBackgroundingOnSocket = YES;
#endif
    
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Roster
    XMPPRosterMemoryStorage *xmppRosterStorage = [[XMPPRosterMemoryStorage alloc] init];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    self.xmppRoster.autoFetchRoster = YES;
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Card Avatar
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    self.vCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    self.vCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.vCardTempModule];
    
    // Capabilities
    //XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    //self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    //self.xmppCapabilities.autoFetchHashedCapabilities = YES;
    //self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Modules activation
    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppRoster activate:self.xmppStream];
    [self.vCardTempModule activate:self.xmppStream];
    [self.vCardAvatarModule activate:self.xmppStream];
    //[self.xmppCapabilities activate:self.xmppStream];
    
    [self initDelegates];
    [self initSounds];
}

- (void) initDelegates
{
    self.streamDelegate = [[VSXmppStreamDelegate alloc] init];
}

- (void) initSounds
{
    // Init chat notifications sound
    NSURL *chatSoundURL = [[NSBundle mainBundle] URLForResource:@"chat" withExtension: @"wav"];
    SystemSoundID chatSoundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)chatSoundURL, &chatSoundID);
    self.chatSoundID = chatSoundID;
    
    // Init received messages sound
    NSURL *msgReceivedSoundURL = [[NSBundle mainBundle] URLForResource:@"msg-received" withExtension: @"mp3"];
    SystemSoundID msgReceivedSoundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)msgReceivedSoundURL, &msgReceivedSoundID);
    self.msgReceivedSoundID = msgReceivedSoundID;
    
    // Init sent messages sound
    NSURL *msgSentSoundURL = [[NSBundle mainBundle] URLForResource:@"msg-sent" withExtension: @"mp3"];
    SystemSoundID msgSentSoundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)msgSentSoundURL, &msgSentSoundID);
    self.msgSentSoundID = msgSentSoundID;
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(self.chatSoundID);
    AudioServicesDisposeSystemSoundID(self.msgReceivedSoundID);
    AudioServicesDisposeSystemSoundID(self.msgSentSoundID);
}

- (void)playChatTone
{
    AudioServicesPlayAlertSound(self.chatSoundID);
}

- (void)playReceivedMessageTone
{
    AudioServicesPlayAlertSound(self.msgReceivedSoundID);
}

- (void)playSentMessageTone
{
    AudioServicesPlayAlertSound(self.msgSentSoundID);
}

- (BOOL) registerXmppAccount:(VSXmppAccountConfig *)xmppAccount
                  forAccount:(VSAccountConfig *)account
{
    if (![xmppAccount isDefined]) {
        if ([account.username rangeOfString:@"@"].location == NSNotFound) {
            xmppAccount.account = [NSString stringWithFormat:@"%@@%@", account.username, account.pbxAddress];
        } else {
            xmppAccount.account = account.username;
        }
        
        xmppAccount.password = account.password;
        
        [xmppAccount save];
    }
    
    if ([self.xmppStream isConnected] && [self.xmppStream.myJID.bare isEqualToString:xmppAccount.account]) {
        NSLog(@"XMPP is already connected, nothing to do");
        return YES;
    }
    
    // Register stream and roster delegates (remove them first to handle a new registration)
    [self.xmppStream removeDelegate:self.streamDelegate delegateQueue:dispatch_get_main_queue()];
    [self.xmppStream addDelegate:self.streamDelegate delegateQueue:dispatch_get_main_queue()];

    if (self.rosterDelegate != nil) {
        [self.xmppRoster removeDelegate:self.rosterDelegate delegateQueue:dispatch_get_main_queue()];
        [self.xmppRoster addDelegate:self.rosterDelegate delegateQueue:dispatch_get_main_queue()];
    }
    
    // Set JabberID
    NSString *jidString = [NSString stringWithFormat:@"%@/%@", xmppAccount.account, xmppAccount.resourceName];
    [self.xmppStream setMyJID:[XMPPJID jidWithString:jidString]];
    
    NSLog(@"Starting registration process for XMPP account '%@'.", xmppAccount.account);
    
    NSError *error = nil;
    
    if (xmppAccount.server != nil && [xmppAccount.server length] > 0) {
        self.xmppStream.hostName = xmppAccount.server;
        self.xmppStream.hostPort = xmppAccount.port;
    } else {
        self.xmppStream.hostName = nil;
        self.xmppStream.hostPort = 0;
    }
    
    // Send the connection request
    return [self.xmppStream connectWithTimeout:10.0 error:&error];
}

- (void) sendPresence:(XMPPPresence *)presence
{
    [self.xmppStream sendElement:presence];
}

- (void)sendPresenceStatus:(VSPresenceStatus)presenceStatus
               withMessage:(NSString *)statusMessage
{
    XMPPPresence *presence = [XMPPPresence presence];
    NSXMLElement *show = [NSXMLElement elementWithName:@"show"];
    
    switch (presenceStatus) {
        case AVAILABLE:
            [show setStringValue:@"available"];
            break;
            
        case CHAT:
            [show setStringValue:@"chat"];
            break;
            
        case AWAY:
            [show setStringValue:@"away"];
            break;
            
        case EXTENDED_AWAY:
            [show setStringValue:@"xa"];
            break;
            
        case DO_NOT_DISTURB:
        default:
            [show setStringValue:@"dnd"];
            break;
    }
    
    [presence addChild:show];
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue:statusMessage];
    
    [presence addChild:status];
    
    [self sendPresence:presence];
}

- (void) sendMessage:(NSString *)text to:(NSString *)jabberId;
{
    NSXMLElement *body = [[NSXMLElement alloc] initWithName:@"body" stringValue:text];
    
    NSXMLElement *message = [[NSXMLElement alloc] initWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:jabberId];
    [message addChild:body];

    [self.xmppStream sendElement:message];
}

//Authenticates the stored XMPP Account
- (BOOL) authenticate
{
    NSError *error = nil;

    return ([self.xmppStream authenticateWithPassword:[VSConfiguration sharedInstance].xmppConfig.password
                                                error:&error]);
}

//Un-registers the currently connected XMPP stream (only if it's connected)
- (void) unregister
{
    NSLog(@"Unregistering XMPP...");

    [self.xmppStream disconnect];
}

- (BOOL)isConnected
{
    return [self.xmppStream isConnected];
}


- (void) addContactWithJabberId:(NSString *)jabberId
                          alias:(NSString *)alias
                       andGroup:(NSString *)group
{
    [self.xmppRoster addUser:[XMPPJID jidWithString:jabberId] withNickname:alias];
    //TODO: aggiungere l'utente al gruppo
}

- (void) deleteContactWithJabberId:(XMPPJID *)jabberId
{
    [self.xmppRoster removeUser:jabberId];
}

- (id <XMPPRosterStorage>)rosterStorage
{
    return [self.xmppRoster xmppRosterStorage];
}

- (void)setRosterMemoryStorageDelegate:(id<XMPPRosterMemoryStorageDelegate>)delegate
{
    if (delegate == nil) return;
    
    self.rosterDelegate = delegate;
    [self.xmppRoster removeDelegate:delegate];
    [self.xmppRoster addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeRosterMemoryStorageDelegate:(id<XMPPRosterMemoryStorageDelegate>)delegate
{
    if (delegate == nil) return;
    
    self.rosterDelegate = nil;
    [self.xmppRoster removeDelegate:delegate];
}

- (UIImage *) getAvatarForJabberID:(XMPPJID *)jabberID
{
    NSData *photoData = [self.vCardAvatarModule photoDataForJID:jabberID];
    
    UIImage *image;
    
    if (photoData != nil) {
        image = [UIImage imageWithData:photoData];
    } else {
        image = self.defaultAvatar;
    }
    
    return image;
}

- (void)updateAvatar:(UIImage *)avatar
{
    NSData *imageData = UIImageJPEGRepresentation(avatar, 0.5);
    
    dispatch_queue_t queue = dispatch_queue_create("updateAvatarQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    dispatch_async(queue, ^{
        XMPPvCardTemp *vCard = [self.vCardTempModule myvCardTemp];
        
        if (vCard) { //The user already has a vCard
            [vCard setPhoto:imageData];
            [self.vCardTempModule updateMyvCardTemp:vCard];
        
        } else { //The user does not have a vCard, so a new one has to be created
            NSXMLElement *newvCard = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
            NSXMLElement *photoXml = [NSXMLElement elementWithName:@"PHOTO"];
            NSXMLElement *typeXml = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];
            NSXMLElement *binValXml = [NSXMLElement elementWithName:@"BINVAL"
                                                        stringValue:[imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
            
            [photoXml addChild:typeXml];
            [photoXml addChild:binValXml];
            
            [newvCard addChild:photoXml];
            
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:newvCard];
            [self.vCardTempModule updateMyvCardTemp:newvCardTemp];
            
        }
        
    });
}

@end
