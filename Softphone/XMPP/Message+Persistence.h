//
//  Contains all the read/write methods for XMPP Messages in CoreData.
//
//
//  Created by Alex on 26/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "Message.h"

@interface Message (Persistence)

//Insert a new message incoming from a JabberID
+ (BOOL) insertIncomingMessage:(NSString *)message
                  fromJabberId:(NSString *)jabberID
                   withContext:(NSManagedObjectContext *)context;

//Insert a new message sent to a JabberID
+ (BOOL) insertOutgoingMessage:(NSString *)message
                    toJabberId:(NSString *)jabberID
                   withContext:(NSManagedObjectContext *)context;

//Deletes all the messages sent or received to/from a specifica JabberID
+ (BOOL) deleteMessagesExchangedWith:(NSString *)jabberID
                         withContext:(NSManagedObjectContext *)context;

//Deletes the current object from CoreData
- (BOOL) deleteWithContext:(NSManagedObjectContext *)context;

//Gets the fetch request needed to get all the messages exchanged with
//a specific jabberID
+ (NSFetchRequest *)getFetchRequestForMessagesExchangedWith:(NSString *)jabberID
                                                withContext:(NSManagedObjectContext *)context;

//Gets the string representing the date in which the message was sent/received
- (NSString *) getDateString;

//If this is an incoming message, this message will return YES
- (BOOL) isIncomingMessage;

@end
