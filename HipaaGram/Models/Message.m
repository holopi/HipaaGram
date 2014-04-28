//
//  Message.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "Message.h"

@implementation Message

- (id)initWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary {
    self = [super initWithClassName:className];
    if (self) {
        for (NSString *s in [dictionary allKeys]) {
            [self setObject:[dictionary objectForKey:s] forKey:s];
        }
    }
    return self;
}

- (NSString *)text {
    return [self valueForKey:@"msgContent"];
}

- (NSString *)sender {
    return [self valueForKey:@"fromPhone"];
}

- (NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterNoStyle];
    return [format dateFromString:[self valueForKey:@"timestamp"]];
}

@end
