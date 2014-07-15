//
//  ConversationListViewController.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "ConversationListViewController.h"
#import "ConversationListTableViewCell.h"
#import "ConversationViewController.h"
#import "ContactsViewController.h"
#import "Catalyze.h"

@interface ConversationListViewController ()

@property (strong, nonatomic) NSMutableArray *conversations;

@end

@implementation ConversationListViewController

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
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Conversations";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addConversation)];
    
    _conversations = [NSMutableArray array];
    
    [_tblConversationList registerNib:[UINib nibWithNibName:@"ConversationListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationListCellIdentifier"];
    [_tblConversationList reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchConversationList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchConversationList {
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:@"conversations"];
    [query setPageNumber:1];
    [query setPageSize:20];
    //[query setQueryField:@"sender"];
    //[query setQueryValue:[[CatalyzeUser currentUser] usersId]];
    [query retrieveInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not fetch the list of conversations: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            NSLog(@"received conversations: %@", objects);
            _conversations = [NSMutableArray arrayWithArray:objects];
            [[NSUserDefaults standardUserDefaults] setObject:objects forKey:kConversations];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tblConversationList reloadData];
        }
    }];
}

- (void)addConversation {
    ContactsViewController *contactsViewController = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:contactsViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationListCellIdentifier"];
    [cell setCellData:[[[_conversations objectAtIndex:indexPath.row] objectForKey:@"content"] valueForKey:@"recipient"]];
    [cell setHighlighted:NO animated:NO];
    [cell setSelected:NO animated:NO];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _conversations.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    ConversationViewController *conversationViewController = [[ConversationViewController alloc] initWithNibName:nil bundle:nil];
    
    NSString *usersId;
    NSString *username;
    if (![[[_conversations objectAtIndex:indexPath.row] valueForKey:@"recipient_id"] isEqualToString:[[CatalyzeUser currentUser] usersId]]) {
        usersId = [[_conversations objectAtIndex:indexPath.row] valueForKey:@"recipient_id"];
        username = [[_conversations objectAtIndex:indexPath.row] valueForKey:@"recipient"];
    } else {
        usersId = [[_conversations objectAtIndex:indexPath.row] valueForKey:@"sender_id"];
        username = [[_conversations objectAtIndex:indexPath.row] valueForKey:@"sender"];
    }
    conversationViewController.username = username;
    conversationViewController.userId = usersId;
    [self.navigationController pushViewController:conversationViewController animated:YES];
}

@end
