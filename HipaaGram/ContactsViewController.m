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
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *apiKey;

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

- (void)signIntoClassWithAppId:(NSString *)appId apiKey:(NSString *)apiKey {
    [ProxyAPI signInWithUsername:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] usersId:[[NSUserDefaults standardUserDefaults] valueForKey:@"usersId"] phoneNumber:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] password:[[NSUserDefaults standardUserDefaults] valueForKey:kUserPassword] block:^(id response, int status, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not sign in to conversation: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"tokens: %@", [responseDict objectForKey:@"auth"]);
            [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"auth"] forKey:kTokens];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *sessionToken = @"";
            for (NSDictionary *dict in [responseDict objectForKey:@"auth"]) {
                if ([[dict valueForKey:@"appId"] isEqualToString:appId]) {
                    sessionToken = [dict valueForKey:@"sessionToken"];
                    break;
                }
            }
            
            [self createCustomClassWithAppId:appId apiKey:apiKey sessionToken:sessionToken];
        }
    }];
}

- (void)createCustomClassWithAppId:(NSString *)appId apiKey:(NSString *)apiKey sessionToken:(NSString *)sessionToken {
    AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kCatalyzeBaseURL]];
    client.requestSerializer = [AFJSONRequestSerializer serializer];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    client.responseSerializer = [AFHTTPResponseSerializer serializer];
    [client.operationQueue setMaxConcurrentOperationCount:1];
    [client.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",sessionToken] forHTTPHeaderField:@"Authorization"];
    [client.requestSerializer setValue:[NSString stringWithFormat:@"%@", apiKey] forHTTPHeaderField:@"X-Api-Key"];
    
    NSMutableDictionary *customClass = [NSMutableDictionary dictionary];
    [customClass setValue:@"messages" forKey:@"name"];
    [customClass setValue:[NSNumber numberWithBool:YES] forKey:@"phi"];
    
    NSMutableDictionary *schema = [NSMutableDictionary dictionary];
    [schema setValue:@"string" forKey:@"toPhone"];
    [schema setValue:@"string" forKey:@"fromPhone"];
    [schema setValue:@"string" forKey:@"timestamp"];
    [schema setValue:@"string" forKey:@"msgContent"];
    [schema setValue:@"boolean" forKey:@"isPhi"];
    [schema setValue:@"string" forKey:@"fileId"];
    
    [customClass setValue:schema forKey:@"schema"];
    
    [client POST:[NSString stringWithFormat:@"/%@/classes",appId] parameters:customClass success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error creating custom class %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not initialize the conversation: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self signIntoClassWithAppId:_appId apiKey:_apiKey];
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
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            [[[UIAlertView alloc] initWithTitle:@"Activation" message:@"Please check your email to activate this conversation" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            _appId = [responseDict valueForKey:@"appId"];
            _apiKey = [responseDict valueForKey:@"apiKey"];
            //[self signIntoClassWithAppId:[responseDict valueForKey:@"appId"] apiKey:[responseDict valueForKey:@"apiKey"]];
        }
    }];
}

@end
