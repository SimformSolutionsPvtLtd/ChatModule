//
//  SSMessageAvtarInfo.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessagesAvatarImage.h"

@interface SSMessageAvtarInfo : JSQMessagesAvatarImage

@property (nonatomic, retain) NSString *username;

+ (NSMutableDictionary *)sharedStore;

+ (SSMessageAvtarInfo *)avatarObjectForUsername:(NSString *)username;

- (void)loadPath:(NSString *)path;

@end
