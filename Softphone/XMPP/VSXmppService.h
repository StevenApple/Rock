//
//  VSXmppService.h
//  Softphone
//
//  Created by Alex on 20/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "XMPPFramework.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardCoreDataStorageObject.h"
#import "VSAccountConfig.h"
#import "VSXmppAccountConfig.h"
#import "VSXmppStreamDelegate.h"

@interface VSXmppService : NSObject

+ (VSXmppService *) sharedInstance;

- (void) playChatTone;
- (void) playReceivedMessageTone;
- (void) playSentMessageTone;
- (BOOL) registerXmppAccount:(VSXmppAccountConfig *)xmppAccount
                  forAccount:(VSAccountConfig *)account;
- (void) sendPresence:(XMPPPresence *)presence;
- (void)sendPresenceStatus:(VSPresenceStatus)presenceStatus
               withMessage:(NSString *)statusMessage;
- (void) sendMessage:(NSString *)text to:(NSString *)jabberId;
- (void) updateAvatar:(UIImage *)avatar;
- (BOOL) authenticate;
- (void) unregister;
- (BOOL) isConnected;
- (void) addContactWithJabberId:(NSString *)jabberId
                          alias:(NSString *)alias
                       andGroup:(NSString *)group;
- (void) deleteContactWithJabberId:(XMPPJID *)jabberId;

- (id <XMPPRosterStorage>)rosterStorage;
- (NSManagedObjectContext *) getMessagesContext;
- (void) setRosterMemoryStorageDelegate:(id<XMPPRosterMemoryStorageDelegate>)delegate;
- (void) removeRosterMemoryStorageDelegate:(id<XMPPRosterMemoryStorageDelegate>)delegate;
- (UIImage *) getAvatarForJabberID:(XMPPJID *)jabberID;

@end
