//
//  SSChatModule.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPReconnect.h"

#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"

#import "XMPPvCardTempModule.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"

#import "XMPPMUC.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoomHybridStorage.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPRoomMessageHybridCoreDataStorageObject.h"
#import "XMPPMessageDeliveryReceipts.h"

extern NSString *const XBChatEventConnected;
extern NSString *const XBChatEventReceiveMessage;

@interface SSChatModule : NSObject<XMPPRoomDelegate>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPMUC *xmppMUC;
    XMPPRoom *xmppRoom;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPRoomCoreDataStorage *xmppRoomStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
    XMPPMessageArchiving *xmppMessageArchivingModule;
    
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts;
    
    NSString *password;
    
    BOOL customCertEvaluation;
    
    BOOL isXmppConnected;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *avatarFormat;
@property (nonatomic, retain) UIImage *avatarPlaceHolder;

- (void)loadFromPlist:(NSString *)plistName;
- (void)loadFromDictionary:(NSDictionary *)information;

+ (id)sharedInstance;

- (BOOL)connect;
- (void)disconnect;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
- (void)sendMessage:(NSString *)message toID:(NSString *)jid;
- (void)joinMultiUserChatRoom:(NSString *) newRoomName;

-(void)createGroup:(NSString*)groupName;
-(void)sendmessage :(NSString *)message :(NSString *)tojid;
- (void)getListOfGroups;

@end
