//
//  Message+Persistence.m
//  Softphone
//
//  Created by Alex on 26/11/13.
//  Copyright (c) 2013 VoiSmart. All rights reserved.
//

#import "Message+Persistence.h"
#import "VSUtility.h"

typedef NS_ENUM(NSInteger, VS_XMPP_MESSAGE_TYPE) {
    VS_MESSAGE_INCOMING = 1,
    VS_MESSAGE_OUTGOING = 2
};

static NSString *const VS_MESSAGE_PERSISTENCE_LOG_TAG = @"Message+Persistence";

@implementation Message (Persistence)

+ (BOOL) saveContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    BOOL success = [context save:&error];
    if (!success) {
        NSLog(@"Error while saving CoreData. Reason: %@", error.localizedFailureReason);
    }
    
    return success;
}

+ (BOOL) insertMessage:(NSString *)message
             recipient:(NSString *)jabberID
                ofType:(VS_XMPP_MESSAGE_TYPE)msgType
           withContext:(NSManagedObjectContext *)context
{
    Message *xmppMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                         inManagedObjectContext:context];
    
    xmppMessage.message = message;
    xmppMessage.timestamp = [VSUtility getNowTimestamp];
    xmppMessage.recipient = jabberID;
    xmppMessage.type = [NSNumber numberWithInt:msgType];
    
    return ([self saveContext:context]);
}

+ (BOOL)insertIncomingMessage:(NSString *)message
                 fromJabberId:(NSString *)jabberID
                  withContext:(NSManagedObjectContext *)context
{
    return [self insertMessage:message
                     recipient:jabberID
                        ofType:VS_MESSAGE_INCOMING
                   withContext:context];
}

+ (BOOL) insertOutgoingMessage:(NSString *)message
                    toJabberId:(NSString *)jabberID
                   withContext:(NSManagedObjectContext *)context
{
    return [self insertMessage:message
                     recipient:jabberID
                        ofType:VS_MESSAGE_OUTGOING
                   withContext:context];
}

+ (NSFetchRequest *)getFetchRequestForMessagesExchangedWith:(NSString *)jabberID
                                                withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recipient LIKE %@", jabberID];
    request.predicate = predicate;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    return request;
}

+ (BOOL) deleteMessagesExchangedWith:(NSString *)jabberID
                         withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self getFetchRequestForMessagesExchangedWith:jabberID
                                                                withContext:context];
    
    NSError *error = nil;
    NSArray *messages = [context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error while executing messages fetch request. Reason: %@", error.localizedFailureReason);
    }
    
    if (messages != nil && [messages count] > 0) {
        for (Message *message in messages) {
            [context deleteObject:message];
        }
    }
    
    return ([self saveContext:context]);
}

- (BOOL) deleteWithContext:(NSManagedObjectContext *)context
{
    [context deleteObject:self];
    
    return ([Message saveContext:context]);
}

- (NSString *) getDateString
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.timestamp doubleValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    if ([date compare:[NSDate dateWithTimeIntervalSinceNow:-86400]] == NSOrderedDescending) {
        [formatter setDateFormat:@"HH:mm"];
    } else {
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    }
    
    return [formatter stringFromDate:date];
}

- (BOOL) isIncomingMessage
{
    return ([self.type integerValue] == VS_MESSAGE_INCOMING);
}

@end
