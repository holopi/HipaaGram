//
//  ProxyAPI.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProxyAPI : NSObject

+ (void)signUpWithUsername:(NSString *)username email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName usersId:(NSString *)usersId phoneNumber:(NSString *)phoneNumber password:(NSString *)password block:(ProxyResultBlock)block;

+ (void)signInWithUsername:(NSString *)username usersId:(NSString *)usersId phoneNumber:(NSString *)phoneNumber password:(NSString *)password block:(ProxyResultBlock)block;

+ (void)startConversationWith:(NSString *)username block:(ProxyResultBlock)block;

+ (void)fetchConversations:(ProxyResultBlock)block;

+ (void)fetchContacts:(ProxyResultBlock)block;

@end
