//
//  VSChatViewController.h
//  Softphone
//
//  Created by Alex Gotev on 22/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAMessagesTableViewController.h"
#import "XMPPFramework.h"

@interface VSChatViewController : TAMessagesTableViewController

@property (nonatomic, strong) XMPPUserMemoryStorageObject *otherUser;

@end
