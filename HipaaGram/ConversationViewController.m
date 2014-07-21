//
//  ConversationViewController.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "ConversationViewController.h"
#import "MessageTableViewCell.h"
#import "Message.h"
#import "JSBubbleView.h"
#import "JSBubbleImageViewFactory.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

@interface ConversationViewController ()

@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation ConversationViewController

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
    
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:14.0f]];
    
    self.title = _username;
    
    self.messageInputView.textView.placeHolder = @"message";
    
    self.sender = @"The Sender";
    
    _messages = [NSMutableArray array];
    
    [self queryMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setHandler:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setHandler:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryMessages {
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:@"messages"];
    query.queryField = @"conversationsId";
    query.queryValue = _conversationsId;
    query.pageNumber = 1;
    query.pageSize = 100;
    [query retrieveInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not fetch previous messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            NSLog(@"successfully queried class: %@", objects);
            [_messages removeAllObjects];
            for (id obj in objects) {
                Message *msg = [[Message alloc] initWithClassName:@"messages" dictionary:[obj objectForKey:@"content"]];
                [_messages addObject:msg];
            }
            [_messages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[((Message*)obj1) valueForKey:@"timestamp"] compare:[((Message*)obj2) valueForKey:@"timestamp"]];
            }];
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        }
    }];
}

- (void)sendNotification {
    AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://go.urbanairship.com"]];
    client.requestSerializer = [AFJSONRequestSerializer serializer];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    client.responseSerializer = [AFHTTPResponseSerializer serializer];
    [client.operationQueue setMaxConcurrentOperationCount:1];
    
    NSDictionary *ua = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AirshipConfig" ofType:@"plist"]];
    [client.requestSerializer setAuthorizationHeaderFieldWithUsername:[ua valueForKey:@"developmentAppKey"] password:[ua valueForKey:@"developmentMasterSecret"]];
    
    NSMutableDictionary *notification = [NSMutableDictionary dictionary];
    [notification setValue:@"all" forKey:@"device_types"];
    [notification setValue:@{@"alert":[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]} forKey:@"notification"];
    [notification setValue:@[_username] forKey:@"aliases"];
    
    [client POST:@"/api/push/" parameters:notification success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"successfully sent push notification");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not notify the recipient, they must refresh manually" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

#pragma mark - PushNotificationHandler

- (void)handleNotification:(NSString *)fromNumber {
    NSLog(@"handling notification...");
    //if ([fromNumber isEqualToString:_username]) {
        NSLog(@"I got a msg, querying for it...");
        [self queryMessages];
    //}
}

#pragma mark - JSMessagesDataSource

- (Message *)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_messages objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    return nil;
}

#pragma mark - JSMessagesDelegate

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    Message *msg = [[Message alloc] initWithClassName:@"messages"];
    [msg setValue:text forKey:@"msgContent"];
    [msg setValue:_username forKey:@"toPhone"];
    [msg setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] forKey:@"fromPhone"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy HH:mm:ss.SSSSSS"];
    
    [msg setValue:[format stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [msg setValue:text forKey:@"msgContent"];
    [msg setValue:[NSNumber numberWithBool:NO] forKey:@"isPhi"];
    [msg setValue:@"" forKey:@"fileId"];
    [msg setValue:_conversationsId forKey:@"conversationsId"];
    
    [_messages addObject:msg];
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionary];
    [sendDict setValue:text forKey:@"msgContent"];
    [sendDict setValue:_username forKey:@"toPhone"];
    [sendDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] forKey:@"fromPhone"];
    
    [sendDict setValue:[format stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [sendDict setValue:text forKey:@"msgContent"];
    [sendDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPhi"];
    [sendDict setValue:@"" forKey:@"fileId"];
    [sendDict setValue:_conversationsId forKey:@"conversationsId"];
    NSMutableDictionary *outerSendDict = [NSMutableDictionary dictionary];
    [outerSendDict setObject:sendDict forKey:@"content"];
    
    [CatalyzeHTTPManager doPost:[NSString stringWithFormat:@"/classes/messages/entry/%@", _userId] withParams:outerSendDict block:^(int status, NSString *response, NSError *error) {
        NSLog(@"created");
        if (!error) {
            NSLog(@"successfully saved msg");
            [self sendNotification];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not send the message: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[_messages objectAtIndex:indexPath.row] valueForKey:@"fromPhone"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIColor *)colorForMessageType:(JSBubbleMessageType)type {
    if (type == JSBubbleMessageTypeOutgoing) {
        return [UIColor colorWithRed:51.0/255.0f green:181.0/255.0f blue:229.0/255.0f alpha:1.0f];
    } else {
        return [UIColor colorWithRed:225.0/255.0f green:225.0/255.0f blue:225.0/255.0f alpha:1.0f];
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {
    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[self colorForMessageType:type]];
}

- (JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        
        // Customize any UITextView properties
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    // Customize any UILabel properties for timestamps or subtitles
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
    
    // Enable data detectors
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

- (BOOL)allowsPanToDismissKeyboard {
    return YES;
}

/*- (UIButton *)sendButtonForInputView {
    
}

- (NSString *)customCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath {
    
}*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

@end
