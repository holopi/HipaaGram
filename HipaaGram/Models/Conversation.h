//
//  Conversation.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conversation : NSObject

@property (strong, nonatomic) NSMutableArray *participants; //array of CatalyzeUsers
@property (strong, nonatomic) NSMutableArray *messages; //array of CatalyzeObjects

@end
