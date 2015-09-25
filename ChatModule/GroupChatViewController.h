//
//  GroupChatViewController.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 22/09/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTextView.h"
#import "ChatCell.h"

@interface GroupChatViewController : UIViewController<UIGestureRecognizerDelegate,UITextViewDelegate>{
    
    IBOutlet UITableView *tblMessages;
    IBOutlet UIView *bottomView;
    
    IBOutlet UIButton *btnSend;
    
    IBOutlet SAMTextView *txtMessage;
    NSMutableArray *arrMessages;
    int countTotal;
    
    IBOutlet NSLayoutConstraint *bottomView_Bottom;
    IBOutlet NSLayoutConstraint *tblMessages_Bottom;
}

@property(nonatomic,retain)NSString *groupId;

@end
