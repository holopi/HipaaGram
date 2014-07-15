//
//  ContactsViewController.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactTableViewCell.h"
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
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:@"contacts"];
    [query setPageNumber:1];
    [query setPageSize:100];
    //[query setQueryField:@""];
    //[query setQueryValue:@""];
    [query retrieveInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not fetch the contacts: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            for (NSDictionary *dict in objects) {
                if (![[[dict objectForKey:@"content"] valueForKey:@"username"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]]) {
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
    [cell setCellData:[[[_contacts objectAtIndex:indexPath.row] objectForKey:@"content"] valueForKey:@"username"]];
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
    /*CatalyzeObject *object = [CatalyzeObject objectWithClassName:@"conversations"];
    [object setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] forKey:@"sender"];
    [object setValue:[[[_contacts objectAtIndex:indexPath.row] objectForKey:@"content"] valueForKey:@"username"] forKey:@"recipient"];
    [object createInBackgroundWithBlock:^(BOOL succeeded, int status, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not start conversation: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            CatalyzeObject *object = [CatalyzeObject objectWithClassName:@"conversations"];
            [object setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] forKey:@"recipient"];
            [object setValue:[[[_contacts objectAtIndex:indexPath.row] objectForKey:@"content"] valueForKey:@"username"] forKey:@"sender"];
            [object createInBackgroundWithBlock:^(BOOL succeeded, int status, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not start conversation part 2: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Activation" message:@"Please check your email to activate this conversation" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];*/
    
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionary];
    [sendDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] forKey:@"sender"];
    [sendDict setValue:[[[_contacts objectAtIndex:indexPath.row] objectForKey:@"content"] valueForKey:@"username"] forKey:@"recipient"];
    [sendDict setValue:[[CatalyzeUser currentUser] usersId] forKey:@"sender_id"];
    [sendDict setValue:[[[_contacts objectAtIndex:indexPath.row] objectForKey:@"content"] valueForKey:@"usersId"] forKey:@"recipient_id"];
    
    NSMutableDictionary *outerSendDict = [NSMutableDictionary dictionary];
    [outerSendDict setObject:sendDict forKey:@"content"];
    
    [CatalyzeHTTPManager doPost:[NSString stringWithFormat:@"/classes/conversations/entry/%@", [sendDict valueForKey:@"recipient_id"]] withParams:outerSendDict block:^(int status, NSString *response, NSError *error) {
        NSLog(@"created");
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not start conversation: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
}

@end
