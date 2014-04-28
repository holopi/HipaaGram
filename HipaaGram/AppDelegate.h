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

@interface AppDelegate : UIResponder <UIApplicationDelegate, SignInDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
