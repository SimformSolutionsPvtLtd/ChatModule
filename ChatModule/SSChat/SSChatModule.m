//
//  SSChatModule.m
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import "SSChatModule.h"
#import "GCDAsyncSocket.h"

static SSChatModule *__sharedSSChatModule = nil;
NSString *const XBChatEventConnected = @"SSChatEventConnected";
NSString *const XBChatEventReceiveMessage = @"SSChatEventReceiveMessage";

@interface SSChatModule ()
{
    
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRoom *xmppRoom;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
@property (nonatomic, strong, readonly) XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts;
- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

@implementation SSChatModule

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRoom;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppMessageArchivingStorage;
@synthesize xmppMessageDeliveryRecipts;

@synthesize username = _username;
@synthesize password = _password;
@synthesize host = _host;
@synthesize avatarFormat;
@synthesize avatarPlaceHolder;

+ (id)sharedInstance
{
    if (__sharedSSChatModule == nil)
    {
        __sharedSSChatModule = [[SSChatModule alloc] init];
        [__sharedSSChatModule setupStream];
    }
    return __sharedSSChatModule;
    
}

- (void)loadFromPlist:(NSString *)plistName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSDictionary *information = [NSDictionary dictionaryWithContentsOfFile:path];
    [self loadFromDictionary:information];
}

- (void)loadFromDictionary:(NSDictionary *)information
{
    self.host = information[@"host"];
    self.avatarFormat = information[@"avatarFormat"];
    self.avatarPlaceHolder = information[@"girl_9"];
}

- (void)setUsername:(NSString *)username
{
    NSString *s = username;
    if (_host)
    {
        s = [NSString stringWithFormat:@"%@@%@", username, _host];
    }
    [[NSUserDefaults standardUserDefaults] setValue:s forKey:@"kXMPPmyJID"];
    _username = username;
}

- (void)setHost:(NSString *)host
{
    NSString *s = host;
    if (_username)
    {
        s = [NSString stringWithFormat:@"%@@%@", _username, host];
    }
    [[NSUserDefaults standardUserDefaults] setValue:s forKey:@"kXMPPmyJID"];
    _host = host;
}

- (void)setPassword:(NSString *)__password
{
    [[NSUserDefaults standardUserDefaults] setValue:__password forKey:@"kXMPPmyPassword"];
    _password = __password;
}

- (void)sendMessage:(NSString *)message toID:(NSString *)jid
{
    NSString *messageID=[self.xmppStream generateUUID];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    NSXMLElement *_message = [NSXMLElement elementWithName:@"message"];
    [_message addAttributeWithName:@"id" stringValue:messageID];
    [_message addAttributeWithName:@"type" stringValue:@"chat"];
    [_message addAttributeWithName:@"to" stringValue:jid];
    [_message addChild:body];
    
    NSXMLElement * thread = [NSXMLElement elementWithName:@"thread" stringValue:@"SomeThreadName"];
    [_message addChild:thread];
    
    [[self xmppStream] sendElement:_message];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    xmppMessageArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingStorage];
    xmppMessageArchivingModule.clientSideMessageArchivingOnly = NO;
    
    [xmppMessageArchivingModule activate:xmppStream];
    
    [xmppMessageArchivingModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    [xmppMessageDeliveryRecipts activate:xmppStream];
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    [xmppMUC               activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMessageDeliveryRecipts addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
    
    
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    [xmppMUC removeDelegate:self];
    [xmppRoom removeDelegate:self];
    [xmppMessageDeliveryRecipts removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    [xmppMUC      deactivate];
    [xmppRoom      deactivate];
    [xmppMessageDeliveryRecipts      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppMUC = nil;
    xmppRoom = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppRoomStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
    xmppMessageDeliveryRecipts = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyJID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyPassword"];
    
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
    
    //    if (customCertEvaluation)
    //    {
    //        [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
    //    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"connected");
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    if (queryElement)
    {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        for (int i=0; i<[itemElements count]; i++)
        {
            NSLog(@"Friend: %@",[[itemElements[i] attributeForName:@"jid"]stringValue]);
            NSLog(@"Friendname: %@",[[itemElements[i] attributeForName:@"name"]stringValue]);
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setValue:[[itemElements[i] attributeForName:@"jid"]stringValue] forKey:@"userId"];
            [dict setValue:@"offline" forKey:@"status"];
//            if (![[[itemElements[i] attributeForName:@"name"] stringValue]isEqualToString:@"(null)"]) {
//                [dict setValue:[[itemElements[i] attributeForName:@"name"]stringValue] forKey:@"userName"];
//            }else{
//                [dict setValue:[[itemElements[i] attributeForName:@"jid"]stringValue] forKey:@"userName"];
//            }
            
            [appDelegate.arrFriends addObject:dict];
        }
    }
    NSLog(@"receive IQ %@", iq);
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    if ([message isChatMessageWithBody])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:XBChatEventReceiveMessage object:nil userInfo:nil];
     }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // A simple example of inbound message handling.
    NSLog(@"%@",[[message elementForName:@"body"] stringValue]);
    NSLog(@"%@",message);
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XBChatEventReceiveMessage object:nil userInfo:@{@"user": message.from.user}];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            
        }
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
     //NSLog(@"IQ: %@",presence);
    NSString *type = [presence attributeStringValueForName:@"type"];
    NSLog(@"type: %@",type);
    //NSLog(@"presence%@",[presence fromStr]);
    
    for (int i=0; i<[appDelegate.arrFriends count]; i++)
    {
        NSMutableDictionary *dict = [appDelegate.arrFriends objectAtIndex:i];
        if ([[dict valueForKey:@"userId"] isEqualToString:[presence fromStr]]) {
            [dict setValue:@"online" forKey:@"status"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XBChatEventConnected object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (!isXmppConnected)
    {
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoomDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) getListOfGroups
{
    XMPPJID *servrJID = [XMPPJID jidWithString: @"conference.192.168.1.77"];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[[self xmppStream] myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
}

-(void)createGroup:(NSString*)groupName
{
//    if (xmppRoom) {
//        [xmppRoom leaveRoom];
//    }
//    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removeGrpChatMsg" object:nil];
    
    //NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyJID"];
    
    xmppRoomStorage = [[XMPPRoomCoreDataStorage alloc] init];
    xmppRoomStorage = [[XMPPRoomCoreDataStorage alloc] initWithInMemoryStore];
    
    NSString *strRoomName= groupName;
    
    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:[XMPPJID jidWithString:strRoomName] dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:[self xmppStream]];
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];

    [xmppRoom joinRoomUsingNickname:@"sanjay" history:history];
    [xmppRoom fetchModeratorsList];
    [xmppRoom fetchMembersList];
    //[xmppRoom fetchConfigurationForm];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //[xmppRoom configureRoomUsingOptions:nil];
    
}

- (void)handleDidJoinRoom:(XMPPRoom *)room withNickname:(NSString *)nickname
{
    NSLog(@"room joined");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSMutableString *memberList = [[NSMutableString alloc]init];
    
    for (NSXMLElement *listItem in items)
    {
        
        NSString *name = [listItem attributeStringValueForName:@"jid"];
        if (name!=nil) {
            
//            NSArray *arramemberfetch=[name componentsSeparatedByString:@"/"];
//            if ([arramemberfetch count]>1) {
//                NSString *strmember=[NSString stringWithFormat:@"%@",[arramemberfetch objectAtIndex:1]];
//                NSRange replaceRange = [strmember rangeOfString:xmpp_domain];
//                NSString* result;
//                if (replaceRange.location != NSNotFound){
//                    result = [strmember stringByReplacingCharactersInRange:replaceRange withString:@""];
//                }
//                else
//                    result=strmember;
//                [objappdelegate.strmemberlist appendFormat:@"%@,",(NSMutableString*)result];
//            }
            
        }
        
        
    }
    
//    if ([objappdelegate.strmemberlist length] > 0)
//    {
//        objappdelegate.strmemberlist = [objappdelegate.strmemberlist substringToIndex:[objappdelegate.strmemberlist length] - 1];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"listFetch" object:nil];
//    }
//    else
//    {
//        //no characters to delete... attempting to do so will result in a crash
//    }
    //NSLog(@"total member %@",objappdelegate.strmemberlist);
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    //NSLog(@"not fetch member list:%@",iqError);
}

-(void)sendmessage :(NSString *)message :(NSString *)tojid
{
    [xmppRoom sendMessageWithBody:message];
    
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:message];
//    
//    NSXMLElement *_message = [NSXMLElement elementWithName:@"message"];
//    [_message addAttributeWithName:@"type" stringValue:@"groupchat"];
//    [_message addAttributeWithName:@"to" stringValue:tojid];
//    [_message addChild:body];
//    
//    NSXMLElement * thread = [NSXMLElement elementWithName:@"thread" stringValue:@"SomeThreadName"];
//    [_message addChild:thread];
//    
//    [[self xmppStream] sendElement:_message];
}

-(void)xmppRoomDidJoin:(XMPPRoom *)sender
{
//    
//    if (objappdelegate.strLastRoomName.length>0)
//    {
//        
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"removeObjs" object:nil];
//        
//    }
//    
//    objappdelegate.strLastRoomName=sender.roomJID.user;
    
    
    //NSLog(@"I did join with name:%@",objappdelegate.strLastRoomName);
    
    //[sender fetchConfigurationForm];
    
}



- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    NSLog(@"%@",sender.roomJID.user);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    
}

-(void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    
}

- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room{
    
}

@end
