//
//  Message.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSMessageData.h"
#import "Catalyze.h"

@interface Message : CatalyzeObject<JSMessageData>

- (id)initWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary;

@end
