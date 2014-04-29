//
//  ContactsViewController.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HipaaGramViewController.h"

@interface ContactsViewController : HipaaGramViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblContacts;

@end
