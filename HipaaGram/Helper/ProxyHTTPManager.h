//
//  ProxyHTTPManager.h
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProxyHTTPManager : NSObject

+ (void)doGet:(NSString *)urlString block:(ProxyResultBlock)block;

+ (void)doPost:(NSString *)urlString withParams:(NSDictionary *)params block:(ProxyResultBlock)block;

+ (void)doPut:(NSString *)urlString withParams:(NSDictionary *)params block:(ProxyResultBlock)block;

+ (void)doDelete:(NSString *)urlString block:(ProxyResultBlock)block;

@end
