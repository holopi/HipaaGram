//
//  ConversationListTableViewCell.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conversation.h"

@interface ConversationListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblRecipient;

- (void)setCellData:(NSString *)recipient;

@end
