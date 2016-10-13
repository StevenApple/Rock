#import "VSLoadContactsPage.h"
#import "VoiSmartWebServicesFactory.h"

@interface VSLoadContactsPage() <VoiSmartWebServiceDelegate>

@property (strong, nonatomic) id<VSLoadContactsPageDelegate> delegate;
@property (weak, nonatomic) id<VoiSmartWebServices> webServices;
@property (strong, nonatomic) NSString *searchTerm;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger entriesPerPage;

@end

@implementation VSLoadContactsPage

-(id)initWithWebServices:(id<VoiSmartWebServices>)services
{
    self = [super init];
    
    if (self) {
        self.webServices =  services;
    }
    
    return self;
}

- (void)loadContactsPageWithSearchTerm:(NSString *)searchTerm
                            pageToLoad:(NSInteger)page
                        entriesPerPage:(NSInteger)entriesPerPage
                              delegate:(id<VSLoadContactsPageDelegate>)delegate
{
    self.searchTerm = searchTerm;
    self.page = page;
    self.entriesPerPage = entriesPerPage;
    self.delegate = delegate;
    
    [self.webServices getLicenseAndSendResponseToDelegate:self];
    //async response sent to receivedLicenseIsValid:withWebServiceToken:error:
}

- (void) receivedLicenseIsValid:(BOOL)valid
            withWebServiceToken:(NSString *)webServiceToken
                          error:(NSError *)error
{
    if (valid && webServiceToken != nil && !error) {
        [self.webServices getContactsWithToken:webServiceToken
                                     searchFor:self.searchTerm
                                          page:(int)self.page
                                entriesPerPage:(int)self.entriesPerPage
                                      delegate:self];
        //async response sent to receivedContacts:error:
    } else {
        if ([self.delegate respondsToSelector:@selector(loadingOfContactsEncounteredAnError:)]) {
            [self.delegate performSelector:@selector(loadingOfContactsEncounteredAnError:)
                                withObject:error];
        }
    }
}

- (void)receivedContacts:(NSArray *)contacts error:(NSError *)error
{
    if (!error && contacts) {
        if ([self.delegate respondsToSelector:@selector(receivedContacts:)]) {
            [self.delegate performSelector:@selector(receivedContacts:)
                                withObject:contacts];
        }
        
    } else {
        if ([self.delegate respondsToSelector:@selector(loadingOfContactsEncounteredAnError:)]) {
            [self.delegate performSelector:@selector(loadingOfContactsEncounteredAnError:)
                                withObject:error];
        }
    }
}

@end
