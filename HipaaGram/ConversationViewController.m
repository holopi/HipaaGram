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
    
    for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:kTokens]) {
        if ([[dict valueForKey:@"appId"] isEqualToString:_appId]) {
            [[NSUserDefaults standardUserDefaults] setValue:[dict valueForKey:@"sessionToken"] forKey:@"Authorization"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
    }
    
    [Catalyze setApiKey:_apiKey applicationId:_appId];
    [CatalyzeUser logInWithUsernameInBackground:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] password:[[NSUserDefaults standardUserDefaults] valueForKey:kUserPassword] block:^(int status, NSString *response, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not open the conversation" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            [self queryMessages];
        }
    }];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryMessages {
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:@"messages"];
    query.queryField = @"fromPhone";
    query.queryValue = @"";
    query.pageNumber = 1;
    query.pageSize = 50;
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
            [self.tableView reloadData];
        }
    }];
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
    NSLog(@"send the text to Catalyze here");
    Message *msg = [[Message alloc] initWithClassName:@"messages"];
    [msg setValue:text forKey:@"msgContent"];
    [msg setValue:_username forKey:@"toPhone"];
    [msg setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] forKey:@"fromPhone"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterShortStyle];
    
    [msg setValue:[format stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [msg setValue:text forKey:@"msgContent"];
    [msg setValue:[NSNumber numberWithBool:NO] forKey:@"isPhi"];
    [msg setValue:@"" forKey:@"fileId"];
    
    [_messages addObject:msg];
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    [msg createInBackgroundWithBlock:^(BOOL succeeded, int status, NSError *error) {
        if (!succeeded) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not send the message: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            NSLog(@"successfully saved msg");
        }
    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[_messages objectAtIndex:indexPath.row] valueForKey:@"fromPhone"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
    //return indexPath.row%2 == 0 ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
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
