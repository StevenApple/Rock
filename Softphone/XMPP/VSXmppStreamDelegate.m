//
//  VSXmppStreamDelegate.m
//  Softphone
//
//  Created by Alex on 20/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "VSXmppStreamDelegate.h"
#import "VSXmppService.h"
#import "VSConfiguration.h"
#import "VSChatNotifications.h"
#import "Message+Persistence.h"

#define XMPP_LOGGING 0

@implementation VSXmppStreamDelegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
#if XMPP_LOGGING == 1
	NSLog(@"XMPP socket is now connected");
#endif
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
#if XMPP_LOGGING == 1
    NSLog(@"XMPP stream will secure");
#endif
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
#if XMPP_LOGGING == 1
    NSLog(@"XMPP stream is now secured");
#endif
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
#if XMPP_LOGGING == 1
    NSLog(@"XMPP stream is now connected");
#endif
	
	if (![[VSXmppService sharedInstance] authenticate]) {
        
        // TODO: lanciare una notifica?
        #if XMPP_LOGGING == 1
        NSLog(@"Cannot authenticate to the XMPP server");
        #endif
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
#if XMPP_LOGGING == 1
    NSLog(@"XMPP stream is now authenticated");
#endif
    
    VSXmppAccountConfig *xmppConfig = [[VSConfiguration sharedInstance] xmppConfig];

    [[VSXmppService sharedInstance] sendPresenceStatus:xmppConfig.onlineStatus
                                           withMessage:xmppConfig.statusMessage];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
#if XMPP_LOGGING == 1
    NSLog(@"XMPP stream did not authenticate.");
#endif
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
#if XMPP_LOGGING == 1
    NSLog(@"XMPP stream did receive IQ.\n* * * * *\n%@\n* * * * *", iq);
#endif

    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *messageBody;
    
    if (![message isChatMessageWithBody] || !(messageBody = [message body])) {
        #if XMPP_LOGGING == 1
        NSLog(@"Received XMPP message without body.");
        #endif

        return;
    }
    
    [Message insertIncomingMessage:messageBody
                      fromJabberId:message.from.bare
                       withContext:[[VSXmppService sharedInstance] getMessagesContext]];
    
    [[VSXmppService sharedInstance] playReceivedMessageTone];
    
    [[VSChatNotifications sharedInstance] addUnreadMessage:messageBody
                                                  fromUser:message.from.bare
                                                 withAlias:message.from.bare];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if ([presence.from.bare isEqualToString:sender.myJID.bare]) return; //Ignore my own presence
    
#if XMPP_LOGGING == 1
    NSLog(@"Received XMPP presence %@ from %@", presence.type, presence.from.bare);
#endif
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
#if XMPP_LOGGING == 1
    NSLog(@"XMPP stream received an error");
#endif
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
#if XMPP_LOGGING == 1
	NSLog(@"XMPP stream is now disconnected");
#endif
}

@end
