//
//  UsersViewController.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListCell.h"
#import "MyChatViewController.h"
#import "GroupChatViewController.h"

@interface UsersViewController : UIViewController
{
    IBOutlet UITableView *tblUsers;
    IBOutlet UITableView *tblGroups;
    NSString *userId;
    IBOutlet UISegmentedControl *mySegment;
}
@end
