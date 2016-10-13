#import <Foundation/Foundation.h>
#import "VoiSmartWebService.h"

@protocol VSLoadContactsPageDelegate <NSObject>

- (void)receivedContacts:(NSArray *)contacts;
- (void)loadingOfContactsEncounteredAnError:(NSError *)error;

@end

@interface VSLoadContactsPage : NSObject

- (id)initWithWebServices:(id<VoiSmartWebServices>) services;

- (void)loadContactsPageWithSearchTerm:(NSString *)searchTerm
                            pageToLoad:(NSInteger)page
                        entriesPerPage:(NSInteger)entriesPerPage
                              delegate:(id<VSLoadContactsPageDelegate>)delegate;

@end
