//
//  SSMessage.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessageData.h"

@interface SSMessage : NSObject <JSQMessageData>

@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *senderDisplayName;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) BOOL isMediaMessage;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) id <JSQMessageMediaData> media;
@property (nonatomic, assign) BOOL isOutgoing;

@end
