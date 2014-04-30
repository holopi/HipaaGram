//
//  AppDelegate.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignInViewController.h"
#import "ConversationListViewController.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import "ConversationViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SignInDelegate, UAPushNotificationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<PushNotificationHandler> handler;

@end
