//
//  MyChatViewController.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTextView.h"
#import "ChatCell.h"

@interface MyChatViewController : UIViewController<UIGestureRecognizerDelegate,UITextViewDelegate>{
    
    IBOutlet UITableView *tblMessages;
    IBOutlet UIView *bottomView;
    IBOutlet UIButton *btnSend;
    IBOutlet SAMTextView *txtMessage;
    NSMutableArray *arrMessages;
    int countTotal;
    
    IBOutlet NSLayoutConstraint *tblMessages_Bottom;
    IBOutlet NSLayoutConstraint *bottomView_Bottom;

}

@property(nonatomic,retain)NSString *userId;


@end
