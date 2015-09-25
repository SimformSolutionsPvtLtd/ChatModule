//
//  MyChatViewController.m
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import "MyChatViewController.h"

@interface MyChatViewController ()

@end

@implementation MyChatViewController
@synthesize userId;

- (void)viewDidLoad
{
    self.title = self.userId;
    arrMessages = [[NSMutableArray alloc]init];
    [self loadChatHistoryWithUserName:self.userId];
    
    //[[SSChatModule sharedInstance] getListOfGroups];
    
    //[[SSChatModule sharedInstance] createGroup:self.userId];
    
    countTotal = 0;
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    tapGesture.delegate=self;
    [self.view addGestureRecognizer:tapGesture];
    
    txtMessage.placeholder = @"Type a message...";
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [super viewDidLoad];
}

#pragma mark METHODS

-(void)reloadMessageTable{
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
}

-(void)reloadData{
    [self loadChatHistoryWithUserName:self.userId];
}

- (void)loadChatHistoryWithUserName:(NSString *)userName
{
    NSString *userJid = [NSString stringWithFormat:@"%@%@",userName,@""];
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage=[XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.sortDescriptors = @[sortDescriptor];
    [request setEntity:entityDescription];
    NSError *error;
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, userJid];
    request.predicate = predicate;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    arrMessages = [[NSMutableArray alloc]initWithArray:messages];
    [tblMessages reloadData];
    [self gotoLastRow];
}

-(CGFloat)heightForView:(NSMutableAttributedString *)text{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screenSize.size.width-120, CGFLOAT_MAX)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    label.attributedText = text;
    [label sizeToFit];
    return label.frame.size.height;
}

-(void) gotoLastRow{
    if (arrMessages.count != 0) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:arrMessages.count - 1 inSection:0];
        [tblMessages scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:true];
    }
}

- (void)tapAction
{
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessageTable) name:XBChatEventReceiveMessage object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TABLEVIEW DELEAGTE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrMessages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *obj = [arrMessages objectAtIndex:indexPath.row];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 5;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@: %@",obj.body,[formatter stringFromDate:obj.timestamp]]];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrString.length)];
    CGFloat height = [self heightForView:attrString];
    return height + 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    XMPPMessageArchiving_Message_CoreDataObject *obj = [arrMessages objectAtIndex:indexPath.row];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 5;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@: %@",obj.body,[formatter stringFromDate:obj.timestamp]]];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrString.length)];
    CGFloat height = [self heightForView:attrString];

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    if (obj.isOutgoing == FALSE){
        
        cell.lblSender.hidden = false;
        cell.imgSender.hidden = false;
        
        cell.lblReceiver.hidden = true;
        cell.imgReceiver.hidden = true;
        
        cell.lblSender.numberOfLines = 0;
        [cell.lblSender sizeToFit];
        
        cell.lblSender_Width.constant = screenSize.size.width-120;
        cell.imgSender_Width.constant = screenSize.size.width-100;
        
        cell.lblSender_Height.constant = height;
        cell.imgSender_Height.constant = height + 17;
        cell.lblSender.attributedText = attrString;
        
    }else{
        
        cell.lblSender.hidden = true;
        cell.imgSender.hidden = true;
        
        cell.lblReceiver.hidden = false;
        cell.imgReceiver.hidden = false;
        
        cell.lblReceiver.numberOfLines = 0;
        [cell.lblReceiver sizeToFit];
        
        cell.lblReceiver_Width.constant = screenSize.size.width-120;
        cell.imgReceiver_Width.constant = screenSize.size.width-100;
        
        cell.lblReceiver_Height.constant = height;
        cell.imgReceiver_Height.constant = height + 17;
        cell.lblReceiver.attributedText = attrString;
    }
    return cell;
}

#pragma mark EVENTS

-(IBAction)sendEvent:(id)sender{
    if (txtMessage.text.length > 0) {
        //[[SSChatModule sharedInstance] sendmessage:txtMessage.text :self.userId];
        [[SSChatModule sharedInstance] sendMessage:txtMessage.text toID:self.userId];
    }
}

#pragma mark KEYBOARD DELEGATE

- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *dict = notification.userInfo;
    CGSize keyboardSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    bottomView_Bottom.constant = keyboardSize.height;
    tblMessages_Bottom.constant = keyboardSize.height + 50;
    [self gotoLastRow];
}

- (void)keyboardShown:(NSNotification *)notification{
    NSDictionary *dict = notification.userInfo;
    CGSize keyboardSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    bottomView_Bottom.constant = keyboardSize.height;
    tblMessages_Bottom.constant = keyboardSize.height + 50;
    [self gotoLastRow];
}

#pragma mark TEXTVIEW DELEGATE

- (void)textViewDidEndEditing:(UITextView *)textView{
    tblMessages_Bottom.constant = 50.00;
    bottomView_Bottom.constant = 0.00;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return true;
}

#pragma mark SCROLLVIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y == 0){
        //self.getAllMessages()
        //Get older messages
    }
}

@end
