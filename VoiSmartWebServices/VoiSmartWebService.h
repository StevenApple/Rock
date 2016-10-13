//
//  VoiSmartWebService.h
//  VoiSmart Web Services
//
//  Created by Alex Gotev
//

#import <Foundation/Foundation.h>
#import "VoiSmartWebServiceDelegate.h"

@protocol VoiSmartWebServices <NSObject>

/**
 * Initializes this instance with the PBX url.
 *
 * @param pbxUrl root url of the PBX to which to connect to
 */
//- (id) initWithPbxUrl:(NSString *)pbxUrl;

/**
 * Configures the web services instance.
 *
 * @param username username to use to login
 * @param password login password
 * @param pbxUrl URL of the pbx to connect to (without http:// or https://)
 */
- (void) setUsername:(NSString *)username
           password:(NSString *)password
              pbxUrl:(NSString *)pbxUrl;

/**
 * Method used to login to the PBX.
 * The delegate has to implement the method:
 * - (void) loginResponseReceivedWithSuccess:(BOOL)success
 *                                     token:(NSString *)token
 *                         validityInSeconds:(long)validityInSeconds;
 */
- (void) loginAndSendResponseToDelegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Gets the UUID of the softphone's license.
 * The delegate has to implement the method:
 * - (void) receivedLicenseIsValid:(BOOL)valid
 *             withWebServiceToken:(NSString *)webServiceToken
 *                           error:(NSError *)error;
 */
- (void) getLicenseAndSendResponseToDelegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Retrieves user's SIP accounts.
 * The delegate has to implement the method:
 * - (void) receivedSipAccounts:(NSArray *)sipAccounts;
 * in which sipAccounts is an array of VSSipAccountConfig objects or an empty array
 *
 * @param token token returned by the login method
 * @param username user's username
 */
- (void) getSipAccountWithToken:(NSString *)token
                    forUsername:(NSString *)username
                       delegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Retrieves received and made calls (from the last one to the first one).
 * The delegate has to implement the method:
 * - (void) receivedCalls:(NSArray *)calls;
 * in which calls is an array of VSCallRegistryItem objects or an empty array
 *
 * @param token token returned by the login method
 * @param username user's username
 * @param page page to fetch
 * @param entriesPerPage number of records per page
 */
- (void) getCallsWithToken:(NSString *)token
                  username:(NSString *)username
                      page:(int)page
            entriesPerPage:(int)entriesPerPage
                  delegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Retrieves the contacts from the phonebook.
 * The delegate has to implement the method:
 * - (void) receivedContacts:(NSArray *)contacts;
 * in which contacts is an array of VSContact objects or an empty array
 *
 * @param token token returned by the login method
 * @param searchFor string to search for in all the fields of the phonebook
 * @param page page to fetch
 * @param entriesPerPage number of records per page
 */
- (void) getContactsWithToken:(NSString *)token
                    searchFor:(NSString *)searchFor
                         page:(int)page
               entriesPerPage:(int)entriesPerPage
                     delegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Retrieves all the SIP numbers associated to an username.
 * The delegate has to implement the method:
 * - (void) receivedUserExtensions:(NSArray *)extensions error:(NSError *)error;
 * in which extensions is an array of NSString or an empty array
 *
 *
 * @param token token returned by the login method
 * @param username username of the user for which you want to get SIP numbers
 */
- (void) getExtensionsByUserWithToken:(NSString *)token
                             username:(NSString *)username
                             delegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Retrieves all the FAX numbers associated to the currently logged in user.
 * The delegate has to implement the method:
 * - (void) receivedFaxNumbers:(NSArray *)faxNumbers;
 * in which faxNumbers is an array of NSString or an empty array
 *
 * @param token token associated to the currently logged in user
 */
- (void) getFaxNumbersWithToken:(NSString *)token
                       delegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Sends a Fax to remote recipients.
 * The delegate has to implement the following methods:
 * - (void) faxProgressChanged:(NSNumber *)percent;
 *
 * - (void) faxSendingCompletedWithResponseCode:(NSNumber *)code
 *                                   andMessage:(NSString *)message;
 * - (void) faxSendingError:(NSError *)error;
 *
 * @param token token returned by the login method
 * @param pdfPath full path of the PDF file to send
 * @param senderNumber number from which to send the FAX
 * @param notes notes to add to the FAX
 * @param recipientNumbers list of recipients to which to send the FAX
 */
- (void) sendFaxWithToken:(NSString *)token
                  pdfPath:(NSString *)pdfPath
             senderNumber:(NSString *)senderNumber
                    notes:(NSString *)notes
         recipientNumbers:(NSArray *)recipientNumbers
                 delegate:(id<VoiSmartWebServiceDelegate>)delegate;

/**
 * Performs a callback call.
 * @param token token returned by the login method
 * @param numberToCall number to call
 * @param numberToConnect number to connect via GSM
 */
- (void) makeCallWithToken:(NSString *)token
                  toNumber:(NSString *)numberToCall
        andConnectToNumber:(NSString *)numberToConnect
                 delegate:(id<VoiSmartWebServiceDelegate>)delegate;

@end
