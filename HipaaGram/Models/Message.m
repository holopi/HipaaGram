//
//  Message.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "Message.h"

@implementation Message

-(NSString *)text {
    return [self valueForKey:@"msgContent"];
}

- (NSString *)sender {
    return @"Me";
}

- (NSDate *)date {
    return [NSDate date];
}

@end
