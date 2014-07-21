//
//  ConversationViewController.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HipaaGramViewController.h"
#import "JSMessagesViewController.h"

@protocol PushNotificationHandler <NSObject>

- (void)handleNotification:(NSString *)fromNumber;

@end

@interface ConversationViewController : JSMessagesViewController<JSMessagesViewDataSource, JSMessagesViewDelegate, UITableViewDataSource, UITableViewDelegate, PushNotificationHandler>
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *conversationsId;

- (void)queryMessages;

@end
