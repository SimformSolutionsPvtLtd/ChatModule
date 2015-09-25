//
//  AppDelegate.m
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize arrFriends;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self createEditableCopyOfDatabaseIfNeeded];
    
    // Override point for customization after application launch.
    arrFriends = [[NSMutableArray alloc]init];
    [[SSChatModule sharedInstance] setUsername:@"sanjay"];
    [[SSChatModule sharedInstance] setPassword:@"123456"];
    [[SSChatModule sharedInstance] setHost:@"192.168.1.77"];
    //[[SSChatModule sharedInstance] setPort:[NSNumber numberWithInt:5222]];
    [[SSChatModule sharedInstance] connect];
    
    [[SSChatModule sharedInstance] setAvatarFormat:@"https://cloud.canadastays.com/assets/images/user-placeholder.png"];
    [[SSChatModule sharedInstance] setAvatarPlaceHolder:[UIImage imageNamed:@"chat_person_pic_holder"]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    
    NSLog(@"Creating editable copy of database");
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"ChatDB.sqlite"];
    NSLog(@"%@",writableDBPath);
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    
    NSString *query1 = @"CREATE TABLE ofmessagearchive (messageID bigint(20) DEFAULT NULL, conversationID bigint(20) NOT NULL, fromJID varchar(255) NOT NULL, fromJIDResource varchar(100) DEFAULT NULL,toJID varchar(255) NOT NULL, toJIDResource varchar(100) DEFAULT NULL, sentDate bigint(20) NOT NULL,stanza text,body text)";
    [Database executeScalarQuery:query1];
    
    NSString *query2 = @"CREATE TABLE conversation(subject TEXT,isGroup INTEGER DEFAULT 0,unreadCount INTEGER DEFAULT 0,lastMessage TEXT, timestamp INTEGER)";
    [Database executeScalarQuery:query2];
    
    NSString *query3 = @"CREATE TABLE ofgroup (groupName varchar(50) NOT NULL,description varchar(255) DEFAULT NULL,PRIMARY KEY (groupName))";
    success =  [Database executeScalarQuery:query3];
    
    NSLog(@"%hhd",success);
    
    //NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ChatDB.sqlite"];
    //success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

@end
