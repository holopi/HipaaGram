//
//  ProxyAPI.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

//#define MOCK

#import "ProxyAPI.h"
#import "ProxyHTTPManager.h"

@implementation ProxyAPI

+ (void)signUpWithUsername:(NSString *)username email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName usersId:(NSString *)usersId phoneNumber:(NSString *)phoneNumber password:(NSString *)password block:(ProxyResultBlock)block {
#ifdef MOCK
    block(nil, 200, nil);
#else
    [ProxyHTTPManager doPost:@"/user" withParams:@{@"username":username, @"email":@{@"primary":email}, @"name":@{@"firstName":firstName, @"lastName":lastName}, @"usersId":usersId, @"password":password} block:block];
#endif
}

+ (void)signInWithUsername:(NSString *)username usersId:(NSString *)usersId phoneNumber:(NSString *)phoneNumber password:(NSString *)password block:(ProxyResultBlock)block {
#ifdef MOCK
    NSMutableArray *response = [NSMutableArray array];
    [response addObject:@{@"username":@"123-456-7890",@"appId":@"05347671-d948-4c6e-97ed-51d04929b9ef",@"sessionToken":@"b116491b-05ea-41df-9c5b-b154e3d1dfaf", @"apiKey":@"ios hipaa.gram 0e3c577c-d2e9-43a4-9777-9233d4baf4ad"}];
    [response addObject:@{@"username":@"123-456-7890",@"appId":@"233ba2d6-dcfa-4e00-8e7c-682c6555ef57",@"sessionToken":@"88ea8e70-a6a0-475d-ae07-bb25bfac73e8",@"apiKey":@"ios hipaa.gram 2896dfe3-1dcd-4115-ac5e-09e6822d5341"}];
    block(response, 200, nil);
#else
    [ProxyHTTPManager doPost:@"/signin" withParams:@{@"username":username, @"usersId":usersId, @"phoneNumber":phoneNumber, @"password":password} block:block];
#endif
}

+ (void)startConversationWith:(NSString *)username block:(ProxyResultBlock)block {
#ifdef MOCK
    NSMutableDictionary *conversation = [NSMutableDictionary dictionary];
    [conversation setValue:@"05347671-d948-4c6e-97ed-51d04929b9ef" forKey:@"appId"];
    [conversation setValue:@"ios hipaa.gram 0e3c577c-d2e9-43a4-9777-9233d4baf4ad" forKey:@"apiKey"];
    block(conversation, 200, nil);
#else
    [ProxyHTTPManager doPost:[NSString stringWithFormat:@"/message/%@/%@",[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername], username] withParams:nil block:block];
#endif
}

+ (void)fetchConversations:(ProxyResultBlock)block {
#ifdef MOCK
    NSMutableArray *conversations = [NSMutableArray array];
    [conversations addObject:@{@"username":@"444-555-6666",@"appId":@"233ba2d6-dcfa-4e00-8e7c-682c6555ef57",@"usersId":@"444-555-6666", @"apiKey":@"ios hipaa.gram 2896dfe3-1dcd-4115-ac5e-09e6822d5341"}];
    [conversations addObject:@{@"username":@"987-654-3210",@"appId":@"05347671-d948-4c6e-97ed-51d04929b9ef",@"usersId":@"987-654-3210",@"apiKey":@"ios hipaa.gram 0e3c577c-d2e9-43a4-9777-9233d4baf4ad"}];
    block(conversations, 200, nil);
#else
    [ProxyHTTPManager doGet:[NSString stringWithFormat:@"/messages/%@",[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]] block:block];
#endif
}

+ (void)fetchContacts:(ProxyResultBlock)block {
#ifdef MOCK
    NSMutableArray *contacts = [NSMutableArray array];
    [contacts addObject:@{@"username":@"444-555-6666", @"userId":@"2eda12ec-d7d8-4fbe-aad6-14354363b32d"}];
    [contacts addObject:@{@"username":@"987-654-3210", @"userId":@"3dd4123f-3f3c-46a5-95b8-6aac55fbe496"}];
    block(contacts, 200, nil);
#else
    [ProxyHTTPManager doGet:@"/list" block:block];
#endif
}

@end
