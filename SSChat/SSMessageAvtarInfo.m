//
//  SSMessageAvtarInfo.m
//  ChatModule
//
//  Created by Ajay Ghodadra on 21/08/15.
//  Copyright (c) 2015 Ajay Ghodadra. All rights reserved.
//

#import "SSMessageAvtarInfo.h"
#import "SDWebImageDownloader.h"
#import "SSChatModule.h"
#import "SDWebImageManager.h"
#import "JSQMessagesAvatarImageFactory.h"

static NSMutableDictionary *__sharedStoreAvatar = nil;

@implementation SSMessageAvtarInfo
@synthesize username;

+ (NSMutableDictionary *)sharedStore
{
    if (!__sharedStoreAvatar)
    {
        __sharedStoreAvatar = [@{} mutableCopy];
    }
    return __sharedStoreAvatar;
}

+ (SSMessageAvtarInfo *)avatarObjectForUsername:(NSString *)username
{
    if ([[SSChatModule sharedInstance] avatarFormat])
    {
        if ([SSMessageAvtarInfo sharedStore][username])
        {
            UIImage *avatar = [JSQMessagesAvatarImageFactory circularAvatarImage:[SSMessageAvtarInfo sharedStore][username] withDiameter:40];
            SSMessageAvtarInfo *message = [[SSMessageAvtarInfo alloc] initWithAvatarImage:avatar highlightedImage:avatar placeholderImage:[JSQMessagesAvatarImageFactory circularAvatarImage:[[SSChatModule sharedInstance] avatarPlaceHolder] withDiameter:40]];
            return message;
        }
        else
        {
            SSMessageAvtarInfo *message = [[SSMessageAvtarInfo alloc] initWithAvatarImage:nil highlightedImage:nil placeholderImage:[JSQMessagesAvatarImageFactory circularAvatarImage:[[SSChatModule sharedInstance] avatarPlaceHolder] withDiameter:40]];
            NSString *path = [NSString stringWithFormat:[[SSChatModule sharedInstance] avatarFormat], username];
            [message loadPath:path];
            message.username = username;
            return message;
        }
    }
    return nil;
}

- (void)loadPath:(NSString *)path
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:path] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [self setAvatarImage:[JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:40]];
        [self setAvatarHighlightedImage:[JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:40]];
        [[SSMessageAvtarInfo sharedStore] setValue:[JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:40] forKey:self.username];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SSChatModuleNewAvatar" object:nil];
    }];
}
@end
