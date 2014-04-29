//
//  ContactsViewController.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactTableViewCell.h"
#import "ProxyAPI.h"
#import "AFNetworking.h"
#import "Catalyze.h"

@interface ContactsViewController ()

@property (strong, nonatomic) NSMutableArray *contacts;

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Contacts";
    
    _contacts = [NSMutableArray array];
    [_tblContacts registerNib:[UINib nibWithNibName:@"ContactTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ContactCellIdentifier"];
    [_tblContacts reloadData];
    
    [self fetchContacts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchContacts {
    [ProxyAPI fetchContacts:^(id response, int status, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not fetch the contacts: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            for (NSDictionary *dict in [responseDict objectForKey:@"users"]) {
                if (![[dict valueForKey:@"username"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]]) {
                    [_contacts addObject:dict];
                }
            }
            [_tblContacts reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCellIdentifier"];
    [cell setSelected:NO animated:NO];
    [cell setHighlighted:NO animated:NO];
    [cell setCellData:[[_contacts objectAtIndex:indexPath.row] valueForKey:@"username"]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contacts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected contact %@", [_contacts objectAtIndex:indexPath.row]);
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
    [ProxyAPI startConversationWith:[[_contacts objectAtIndex:indexPath.row] valueForKey:@"username"] block:^(id response, int status, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not start conversation: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Activation" message:@"Please check your email to activate this conversation" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
