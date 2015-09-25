//
//  UsersViewController.m
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import "UsersViewController.h"

@interface UsersViewController ()

@end

@implementation UsersViewController

- (void)viewDidLoad {
    
    NSLog(@"%@",appDelegate.arrFriends);
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerCalled) userInfo:nil repeats:YES];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark EVENTS

- (IBAction)segmentSwitch:(UISegmentedControl *)sender {
    if (mySegment.selectedSegmentIndex == 0) {
        tblUsers.hidden = NO;
        tblGroups.hidden = YES;
    }else{
        tblUsers.hidden = YES;
        tblGroups.hidden = NO;
    }
}

#pragma mark METHODS

-(void)timerCalled{
    [tblUsers reloadData];
    [tblGroups reloadData];
}

#pragma mark TABLEVIEW DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [appDelegate.arrFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblUsers) {
        NSDictionary *dict = [appDelegate.arrFriends objectAtIndex:indexPath.row];
        UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserListCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lblUserName.text =[dict valueForKey:@"userId"];
        cell.lblStatus.text =[dict valueForKey:@"status"];
        return cell;
    }else{
        NSDictionary *dict = [appDelegate.arrFriends objectAtIndex:indexPath.row];
        UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserListCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lblUserName.text =[dict valueForKey:@"userId"];
        cell.lblStatus.text =[dict valueForKey:@"status"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tblUsers) {
        NSDictionary *dict = [appDelegate.arrFriends objectAtIndex:indexPath.row];
        userId = [dict valueForKey:@"userId"];
        [self performSegueWithIdentifier:@"ChatSegue" sender:nil];
    }else{
        NSDictionary *dict = [appDelegate.arrFriends objectAtIndex:indexPath.row];
        userId = [dict valueForKey:@"userId"];
        [self performSegueWithIdentifier:@"GroupChatSegue" sender:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ChatSegue"])
    {
        MyChatViewController *mView = segue.destinationViewController;
        mView.userId = userId;
    }
    
    if ([segue.identifier isEqualToString:@"GroupChatSegue"])
    {
        GroupChatViewController *mView = segue.destinationViewController;
        mView.groupId = userId;
    }
}

@end
