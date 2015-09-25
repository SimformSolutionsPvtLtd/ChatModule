//
//  SSMessageViewController.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessage.h"
#import "JSQMessagesViewController.h"

@interface SSMessageViewController : JSQMessagesViewController

@property (nonatomic, retain) NSString *jidStr;
@property (nonatomic, retain) NSMutableArray *avatarInformation;

@end
