//
//  VSXmppAccountConfig.h
//  Softphone
//
//  Created by Alex on 23/10/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSXmppUser.h"

#define VS_MAX_XMPP_PRIORITY 127
#define VS_MIN_XMPP_PRIORITY 0

@interface VSXmppAccountConfig : NSObject

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) VSPresenceStatus onlineStatus;
@property (nonatomic, strong) NSString *resourceName;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, assign) BOOL loadAvatars;
@property (nonatomic, assign) BOOL usePriorityByStatus;
@property (nonatomic, assign) NSInteger priority;

- (NSString *)realm;
- (void) setAvailablePriority:(NSInteger)availablePriority;
- (void) setChatPriority:(NSInteger)chatPriority;
- (void) setAwayPriority:(NSInteger)awayPriority;
- (void) setExtendedAwayPriority:(NSInteger)extendedAwayPriority;
- (void) setDoNotDisturbPriority:(NSInteger)doNotDisturbPriority;
- (NSInteger) getPriority;
- (NSInteger) getPriorityByStatus:(VSPresenceStatus)status;
- (void) reload;
- (BOOL) isDefined;
- (BOOL) save;
- (BOOL) reset;

@end
