//
//  PJSipWrapper.m
//  Softphone
//
//  Created by Alex Gotev on 01/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "PJSipWrapper.h"

//5 is reasonable. 0 is disabled
#define SIP_LOG_LEVEL 0

@implementation PJSipWrapper

//Instance to monitor GSM call state
CTCallCenter *callCenter;

//Pointer to the instance of this class.
//Needed to send messages from the C code
static PJSipWrapper *objClassPointer;

//Indicate if PJSip has been correctly initialized
static BOOL initialized = NO;

//Indicate if the user is currently busy in a SIP call
static BOOL sipCallInProgress = NO;

//Indicate the ID of the last incoming call
static int incomingCallId = -1;

//Contains the currently set SIP settings
static NSString *sip_user = @"";
static NSString *sip_password = @"";
static NSString *realm = @"";
static NSString *sip_host = @"";
static int sip_port = 5060;
static BOOL tcp_transport = YES;

//PJSIP internal status variables
pj_status_t status;
pjsua_config ua_cfg;
pjsua_logging_config log_cfg;
pjsua_media_config media_cfg;
pjsua_acc_id account_id = -1;
pjsua_acc_config acc_cfg;

static BOOL is_registered_account(int accountId)
{
    if (!initialized) return NO;
    if (accountId < 0) return NO;

    //As suggested here: http://lists.pjsip.org/pipermail/pjsip_lists.pjsip.org/2008-October/005134.html
    pjsua_acc_info acc_info;
    pjsua_acc_get_info(accountId, &acc_info);
    
    return (acc_info.status/100 == 2 && acc_info.expires > 0);
}

//PJSIP Callbacks: http://www.pjsip.org/pjsip/docs/html/structpjsua__callback.htm#a53fe2794154ad8b1f18d23ea6bbfd037

/*
 Notify application on incoming call.
 
 Parameters
    acc_id	The account which match the incoming call.
    call_id	The call id that has just been created for the call.
    rdata	The incoming INVITE request.
 */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    
    //Retrieve call info
    pj_status_t status;
    pjsua_call_info callInfo;
    
    status = pjsua_call_get_info(call_id, &callInfo);
    
    BOOL userIsBusy = (sipCallInProgress || [[PJSipWrapper sharedInstance] isGSMCallInProgress]);
    
    if (userIsBusy) {
        //Answer with 486 Busy here
        pjsua_call_answer(call_id, 486, NULL, NULL);
        
    } else {
        //Start playing the ring tone
        [[PJSipUtils sharedInstance] startRingTone];
        
        //Answer with 180 Ringing
        pjsua_call_answer(call_id, 180, NULL, NULL);
        
        incomingCallId = call_id;
    }
    
    if (status == PJ_SUCCESS) {
        PJSipRemoteContactInfo *remoteInfo = [PJSipUtils getSipRemoteContactInfo:&callInfo.remote_info];
        NSLog(@"PJSipWrapper on_incoming_call - Successfully retrieved call info. From: %@ at %@", remoteInfo.displayName, remoteInfo.sipURI);
        
        if (userIsBusy) {
            [[PJSipNotifications sharedInstance] onMissedIncomingCallFromDisplayName:remoteInfo.displayName
                                                                           andSipURI:remoteInfo.sipURI];
        } else {
            [[PJSipNotifications sharedInstance] onIncomingCallWithId:call_id
                                                              account:acc_id
                                                      fromDisplayName:remoteInfo.displayName
                                                            andSipURI:remoteInfo.sipURI];
        }
    
    } else {
        NSLog(@"PJSipWrapper on_incoming_call - Error while retrieving call info. From: Unknown at ''");
        
        if (!userIsBusy)
            [[PJSipNotifications sharedInstance] onIncomingCallWithId:call_id
                                                              account:acc_id
                                                      fromDisplayName:@"Unknown"
                                                            andSipURI:@""];
    }
}

/*
 Notify application when call state has changed. 
 Application may then query the call info to get the detail call states by calling pjsua_call_get_info() function.
 
 Parameters
    call_id	The call index.
    e       Event which causes the call state to change.
 */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(e);
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        [[PJSipUtils sharedInstance] stopRingTone];
        sipCallInProgress = NO;
        
        if (call_id == incomingCallId) {
            //Retrieve call info
            pj_status_t status;
            pjsua_call_info callInfo;
            
            status = pjsua_call_get_info(call_id, &callInfo);
            
            if (status == PJ_SUCCESS) {
                PJSipRemoteContactInfo *remoteInfo = [PJSipUtils getSipRemoteContactInfo:&callInfo.remote_info];
                NSLog(@"PJSipWrapper on_call_state - Missed incoming call from %@ at %@", remoteInfo.displayName, remoteInfo.sipURI);
                [[PJSipNotifications sharedInstance] onMissedIncomingCallFromDisplayName:remoteInfo.displayName
                                                                               andSipURI:remoteInfo.sipURI];
            }
            incomingCallId = -1;
        }
        
        [[PJSipNotifications sharedInstance] onCallTerminatedWithId:call_id];
    }
    
    NSLog(@"PJSipWrapper on_call_state - State is %@ for call with id = %d", [PJSipUtils fromPJString:&ci.state_text], call_id);
}

/*
 Notify application when media state in the call has changed. 
 Normal application would need to implement this callback, e.g. to connect the call's media to sound device. 
 When ICE is used, this callback will also be called to report ICE negotiation failure.
 
 Parameters
    call_id	The call index.
 */
static void on_call_media_state(pjsua_call_id call_id) {
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);

    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
        sipCallInProgress = YES;
    }
}

/*
 Notify application when registration status has changed. 
 Application may inspect the registration info to get the registration status details.
 
 Parameters
    acc_id	The account ID.
    info	The registration info.
 */
static void on_registration_state_change(pjsua_acc_id acc_id, pjsua_reg_info *info) {
    BOOL registered = is_registered_account(acc_id);
    
    if (registered) {
        [[PJSipNotifications sharedInstance] onAccountRegistered:acc_id];
    } else {
        [[PJSipNotifications sharedInstance] onAccountUnregistered:acc_id];
    }
    
    NSLog(@"PJSipWrapper on_registration_state_change - Registration status changed. Now %@",
          (registered ? @"registered" : @"unregistered"));
}

/* 
 Notify application upon incoming DTMF digits.
 
 Parameters
    call_id	The call index.
    digit	DTMF ASCII digit.
*/
static void on_dtmf_digit(pjsua_call_id call_id, int digit) {
    NSLog(@"PJSipWrapper on_dtmf_digit - Received DTMF: %d from call with id = %d", digit, call_id);
    
    NSString *dtmfStr = nil;
    
    if (digit >=48 && digit <= 57) {
        dtmfStr = [NSString stringWithFormat:@"%c", digit];
    } else if (digit == 42) {
        dtmfStr = @"*";
    } else if (digit == 35){
        dtmfStr = @"#";
    }
    
    [[PJSipNotifications sharedInstance] onIncomingDTMFdigit:dtmfStr
                                              fromCallWithId:call_id];
}

+(PJSipWrapper *)sharedInstance {
    static dispatch_once_t once;
    static PJSipWrapper *instance;
    dispatch_once(&once, ^{
        instance = [[PJSipWrapper alloc] init];
    });
    return instance;
}

-(BOOL)isGSMCallInProgress
{
    return (callCenter.currentCalls != nil);
}

-(BOOL)isInitialized
{
    return initialized;
}

-(id)init {
    self = [super init];
    
    if (self) {
        objClassPointer = self;
        callCenter = [[CTCallCenter alloc] init];
        [self start];
    }
    
    return self;
}

-(BOOL)start
{
    if (initialized) return YES;

    //Create PjSua
    status = pjsua_create();
    
    if (status == PJ_SUCCESS) {
        // Initialize configs with default settings.
        pjsua_config_default(&ua_cfg);
        pjsua_logging_config_default(&log_cfg);
        pjsua_media_config_default(&media_cfg);
        
        log_cfg.level = SIP_LOG_LEVEL;
        
        //Setup callbacks
        ua_cfg.cb.on_incoming_call = &on_incoming_call;
        ua_cfg.cb.on_reg_state2 = &on_registration_state_change;
        ua_cfg.cb.on_dtmf_digit = &on_dtmf_digit;
        ua_cfg.cb.on_call_state = &on_call_state;
        ua_cfg.cb.on_call_media_state = &on_call_media_state;
        
        //Initialize pjsua
        status = pjsua_init(&ua_cfg, &log_cfg, &media_cfg);
        
        if (status == PJ_SUCCESS) {
            //Add UDP Transport
            pjsua_transport_config transport_cfg_udp;
            pjsua_transport_config_default(&transport_cfg_udp);
            status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transport_cfg_udp, NULL);
            
            //Add TCP Transport
            pjsua_transport_config transport_cfg;
            pjsua_transport_config_default(&transport_cfg);
            status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transport_cfg, NULL);
            
            if (status == PJ_SUCCESS) {
                status = pjsua_start();
                
                if (status == PJ_SUCCESS) {
                    initialized = YES;
                    NSLog(@"PJSipWrapper - PJSip correctly initialized!");
                } else {
                    NSLog(@"PJSipWrapper - Error while starting PJSua. Status =  %d", status);
                }
                
            } else {
                NSLog(@"PJSipWrapper - Error while adding TCP transport to PJSua. Status = %d", status);
            }
            
        } else {
            NSLog(@"PJSipWrapper - Error while initializing PJSua. Status =  %d", status);
        }
        
    } else {
        NSLog(@"PJSipWrapper - Error while creating PJSua. Status = %d", status);
    }
    
    return initialized;
}

-(void)keepAliveInBackground {
    /* Register this thread if not yet */
    if (!pj_thread_is_registered()) {
        static pj_thread_desc   thread_desc;
        static pj_thread_t     *thread;
        pj_thread_register("mainthread", thread_desc, &thread);
    }
    
    /* Simply sleep for 5s, give the time for library to send transport
     * keepalive packet, and wait for server response if any. Don't sleep
     * too short, to avoid too many wakeups, because when there is any
     * response from server, app will be woken up again (see also #1482).
     */
    pj_thread_sleep(5000);
}

- (void)sendKeepAlive
{
    //FIXME: trovare destip da nome host sip
    /*pj_status_t status;
    pjsip_endpoint *endpoint = pjsua_get_pjsip_endpt();
    pj_sockaddr_in destination;
    pj_str_t destip = pj_str("192.168.1.50");
    destination.sin_addr = pj_inet_addr(&destip);
    destination.sin_family = PJ_AF_INET;
    destination.sin_port = pj_htons((pj_uint16_t)5060);
    

    status = pjsip_endpt_send_raw(endpoint, PJSIP_TRANSPORT_TCP, NULL,
                                  "\r\n\r\n", 4,
                                  &destination, sizeof(destination),
                                  NULL, NULL);
    
    if (status == PJ_SUCCESS) {
        NSLog(@"KeepAlive packet sent successfully!");
    }*/
}

-(BOOL)setSipUser:(NSString *)sipUser
     withPassword:(NSString *)sipPassword
         andRealm:(NSString *)sipRealm
           onHost:(NSString *)sipHost
       andSipPort:(int)sipPort
 withTCPTransport:(BOOL)tcpTransport
{
    if (!initialized) return NO;
    
    NSLog(@"PJSipWrapper setSipUser:%@ withPassword:* andRealm:%@ onHost:%@ andSipPort:%d withTCPTransport:%@",
          sipUser, sipRealm, sipHost, sipPort, (tcpTransport ? @"YES" : @"NO"));

    if (account_id > 0)
        pjsua_acc_del(account_id);
    
    //save status variables
    sip_user = sipUser;
    sip_password = sipPassword;
    realm = sipRealm;
    sip_host = sipHost;
    sip_port = sipPort;
    tcp_transport = tcpTransport;
    
    NSString *userId = [NSString stringWithFormat:@"sip:%@@%@", sipUser, sipRealm];
    NSString *host = [NSString stringWithFormat:@"sip:%@:%d", sipHost, sipPort];
    
    pjsua_acc_config_default(&acc_cfg);

    // Set TCP Transport for the proxy, so I don't have to set it on each request
    // https://trac.pjsip.org/repos/wiki/Using_SIP_TCP
    // FIXME: https://trac.pjsip.org/repos/wiki/Using_SIP_TCP#nextreq <- subsequent requests may be sent in UDP!
    if (tcpTransport) {
        NSString *proxyString = [NSString stringWithFormat:@"sip:%@:%d;transport=tcp", sipHost, sipPort];
        acc_cfg.proxy_cnt = 1;
        acc_cfg.proxy[0] = [PJSipUtils fromNSString:proxyString];
    } else {
        NSString *proxyString = [NSString stringWithFormat:@"sip:%@:%d", sipHost, sipPort];
        acc_cfg.proxy_cnt = 1;
        acc_cfg.proxy[0] = [PJSipUtils fromNSString:proxyString];
    }

    acc_cfg.id = [PJSipUtils fromNSString:userId];
    acc_cfg.reg_uri = [PJSipUtils fromNSString:host];
    acc_cfg.cred_count = 1;
    //set realm to * when not using tcp transport.
    //This happens only on orchestra 5. I do this cause it's the only way it registers to asterisk
    pj_str_t realmStr = (tcpTransport ? [PJSipUtils fromNSString:sipRealm] : pj_str("*"));
    acc_cfg.cred_info[0].realm = realmStr;
    acc_cfg.cred_info[0].scheme = pj_str("digest");
    acc_cfg.cred_info[0].username = [PJSipUtils fromNSString:sipUser];
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = [PJSipUtils fromNSString:sipPassword];
    
    status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &account_id);
    
    return (status == PJ_SUCCESS);
}

-(pj_str_t)getSipURIforExtension:(NSString *)extension
                         atRealm:(NSString *)realm
{
    NSString *uri = [NSString stringWithFormat:@"sip:%@@%@", extension, realm];
    return [PJSipUtils fromNSString:uri];
}

-(int)makeCallTo:(NSString *)number
{
    if (!initialized) return NO;
    
    pjsua_call_id callid;
    
    pjsua_call_setting callSetting;
    pjsua_call_setting_default(&callSetting);

    pj_str_t destination = [self getSipURIforExtension:number atRealm:realm];
    
    status = pjsua_call_make_call(account_id, &destination, &callSetting, NULL, NULL, &callid);
    
    if (status == PJ_SUCCESS) {
        NSLog(@"PJSipWrapper - makeCallTo:%@ atRealm:%@ in progress...", number, realm);
        [[PJSipNotifications sharedInstance] onCallInProgressWithId:callid
                                                        displayName:number
                                                          andSipURI:[NSString stringWithFormat:@"%@@%@", number, realm]];
        return callid;
    }
    return -1;
}

- (BOOL)sendDTMF:(NSString *)dtmfTone
    toCallWithId:(int)callId
{
    if (!initialized) return NO;

    pj_str_t dtmf = [PJSipUtils fromNSString:dtmfTone];
    status = pjsua_call_dial_dtmf(callId, &dtmf);
    
    return (status == PJ_SUCCESS);
}

- (BOOL)acceptCallWithId:(int)callId
{
    if (!initialized) return NO;
    
    [[PJSipUtils sharedInstance] stopRingTone];
    incomingCallId = -1;
    
    //Retrieve call info
    pj_status_t status;
    pjsua_call_info callInfo;
    
    NSString *displayName = NSLocalizedString(@"UNKNOWN", nil);
    NSString *sipURI = @"unknown";
    
    status = pjsua_call_get_info(callId, &callInfo);
    if (status == PJ_SUCCESS) {
        PJSipRemoteContactInfo *remoteInfo = [PJSipUtils getSipRemoteContactInfo:&callInfo.remote_info];
        displayName = remoteInfo.displayName;
        sipURI = remoteInfo.sipURI;
    }
    
    status = pjsua_call_answer(callId, 200, NULL, NULL);
    
    [[PJSipNotifications sharedInstance] onCallInProgressWithId:callId
                                                    displayName:displayName
                                                      andSipURI:sipURI];
    
    return (status == PJ_SUCCESS);
}

- (BOOL)hangUpCallWithId:(int)callId
{
    if (!initialized) return NO;
    
    sipCallInProgress = NO;
    incomingCallId = -1;
    status = pjsua_call_hangup(callId, 0, NULL, NULL);
    
    return (status == PJ_SUCCESS);
}

- (BOOL)holdCallWithId:(int)callId
{
    if (!initialized) return NO;
    
    status = pjsua_call_set_hold(callId, NULL);
    
    BOOL result = (status == PJ_SUCCESS);
    if (!result) {
        NSLog(@"PJSipWrapper holdCallWithId: Failed to set hold on callId=%d. Status = %d", callId, status);
    }

    return result;
}

- (BOOL)unholdCallWithId:(int)callId
{
    if (!initialized) return NO;
    
    status = pjsua_call_reinvite(callId, PJSUA_CALL_UNHOLD, NULL);
    
    return (status == PJ_SUCCESS);
}

-(BOOL)muteCallWithId:(int)callId
{
    if (!initialized) return NO;
    
    int audioPortId = [self getAudioPortIdForCallWithId:callId];
    
    @try {
        if(audioPortId != 0) {
            pjsua_conf_disconnect(0, audioPortId);
            return YES;
        }
        return NO;
    }
    @catch (NSException *exception) {
        NSLog(@"PJSipWrapper unmuteCallWithId: Unable to mute microphone because audioPortId = 0");
        return NO;
    }
}

-(BOOL)unmuteCallWithId:(int)callId
{
    if (!initialized) return NO;
    
    int audioPortId = [self getAudioPortIdForCallWithId:callId];
    
    @try {
        if(audioPortId != 0) {
            pjsua_conf_connect(0, audioPortId);
            return YES;
        }
        NSLog(@"PJSipWrapper unmuteCallWithId: Unable to unmute microphone because audioPortId = 0");
        return NO;
    }
    @catch (NSException *exception) {
        NSLog(@"PJSipWrapper unmuteCallWithId: Unable to mute microphone: %@", exception);
        return NO;
    }
}

-(int)getAudioPortIdForCallWithId:(int)callId
{
    pjsua_call_info info;
    pjsua_call_get_info(callId, &info);
    
    return info.conf_slot;
}

-(BOOL)transferCallWithId:(int)callId
              toExtension:(NSString *)extension
{
    if (!initialized) return NO;

    pj_str_t destination = [self getSipURIforExtension:extension atRealm:realm];
    
    status = pjsua_call_xfer(callId, &destination, NULL);   
    
    return (status == PJ_SUCCESS);
}

-(NSString *)getSipUser
{
    if (!initialized) return @"";

    return sip_user;
}

-(BOOL)registerAccount
{
    if (!initialized || account_id < 0) return NO;
    
    status = pjsua_acc_set_registration(account_id, 300);
    
    return (status == PJ_SUCCESS);
}

-(BOOL)unregisterAccount
{
    if (!initialized || account_id < 0) return NO;
    
    status = pjsua_acc_set_registration(account_id, 0);
    
    return (status == PJ_SUCCESS);
}

-(BOOL)isRegistered
{
    return is_registered_account(account_id);
}

- (BOOL)shutdown
{
    [[PJSipUtils sharedInstance] stopRingTone];

    if (!initialized) return NO;

    pjsua_call_hangup_all();
    [self unregisterAccount];
    status = pjsua_destroy();
    sipCallInProgress = NO;
    initialized = NO;
    
    return (status == PJ_SUCCESS);
}

-(BOOL)restartWithCurrentSettings
{
    NSLog(@"\n\nRestarting Sip Stack with current settings\n\n");
    [self shutdown];
    [self start];
    return [self setSipUser:sip_user
               withPassword:sip_password
                   andRealm:realm
                     onHost:sip_host
                 andSipPort:sip_port
            withTCPTransport:tcp_transport];
}

@end
