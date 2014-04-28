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

@interface ConversationViewController : JSMessagesViewController<JSMessagesViewDataSource, JSMessagesViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *apiKey;
@property (weak, nonatomic) IBOutlet UITableView *tblMessages;

@end
