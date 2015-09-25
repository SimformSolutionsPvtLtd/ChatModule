//
//  ChatCell.h
//  ChatModule
//
//  Created by Ajay Ghodadra on 16/09/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UILabel *lblSender;
@property(nonatomic,retain) IBOutlet UILabel *lblReceiver;
@property(nonatomic,retain) IBOutlet UIImageView *imgSender;
@property(nonatomic,retain) IBOutlet UIImageView *imgReceiver;

@property(nonatomic,retain) IBOutlet NSLayoutConstraint *lblSender_Width;
@property(nonatomic,retain) IBOutlet NSLayoutConstraint *lblSender_Height;
@property(nonatomic,retain) IBOutlet NSLayoutConstraint *lblReceiver_Width;
@property(nonatomic,retain) IBOutlet NSLayoutConstraint *lblReceiver_Height;
@property(nonatomic,retain) IBOutlet NSLayoutConstraint *imgSender_Width;
@property(nonatomic,retain) IBOutlet NSLayoutConstraint *imgSender_Height;
@property(nonatomic,retain) IBOutlet NSLayoutConstraint *imgReceiver_Width;
@property(nonatomic,retain) IBOutlet NSLayoutConstraint *imgReceiver_Height;

@end
