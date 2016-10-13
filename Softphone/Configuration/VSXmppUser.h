//
//  VSXmppUser.h
//  Softphone
//
//  Created by Alex on 23/10/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VSPresenceStatus) {
    AVAILABLE,
    CHAT,
    AWAY,
    EXTENDED_AWAY,
    DO_NOT_DISTURB,
    OFFLINE
};

@interface VSXmppUser : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) VSPresenceStatus presenceStatus;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) UIImage *avatar;

@end
