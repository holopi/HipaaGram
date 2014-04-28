//
//  ProxyHTTPManager.m
//  HipaaGram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "ProxyHTTPManager.h"
#import "AFNetworking.h"
#import "Catalyze.h"

@interface ProxyHTTPManager()

@property AFHTTPRequestOperation *operationHolder;
@property NSError *errorHolder;

@end

@implementation ProxyHTTPManager

+ (AFHTTPRequestOperationManager *)httpClient {
    static AFHTTPRequestOperationManager *proxyClient = nil;
    static dispatch_once_t proxyOncePredicate;
    dispatch_once(&proxyOncePredicate, ^{
        proxyClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kProxyBaseUrl]];
        proxyClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [proxyClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        proxyClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        [proxyClient.operationQueue setMaxConcurrentOperationCount:1];
    });
    return proxyClient;
}

+(void)doGet:(NSString *)urlString block:(ProxyResultBlock)block {
    NSLog(@"GET - %@",urlString);
    
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Authorization"]] forHTTPHeaderField:@"Authorization"];
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"%@", [Catalyze apiKey]] forHTTPHeaderField:@"X-Api-Key"];
    
    [[ProxyHTTPManager httpClient] GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, (int)[[operation response] statusCode], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error - %@ - %@", error, [error localizedDescription]);
        block(nil, (int)[[operation response] statusCode], error);
    }];
}

+ (void)doPost:(NSString *)urlString withParams:(NSDictionary *)params block:(ProxyResultBlock)block {
    NSLog(@"POST - %@ - %@",urlString,params);
    
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Authorization"]] forHTTPHeaderField:@"Authorization"];
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"%@", [Catalyze apiKey]] forHTTPHeaderField:@"X-Api-Key"];
    
    [[ProxyHTTPManager httpClient] POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, (int)[[operation response] statusCode], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error - %@ - %@", error, [error localizedDescription]);
        block(nil, (int)[[operation response] statusCode], error);
    }];
}

+ (void)doPut:(NSString *)urlString withParams:(NSDictionary *)params block:(ProxyResultBlock)block {
    NSLog(@"PUT - %@ - %@",urlString, params);
    
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Authorization"]] forHTTPHeaderField:@"Authorization"];
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"%@", [Catalyze apiKey]] forHTTPHeaderField:@"X-Api-Key"];
    
    [[ProxyHTTPManager httpClient] PUT:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, (int)[[operation response] statusCode], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error - %@ - %@", error, [error localizedDescription]);
        block(nil, (int)[[operation response] statusCode], error);
    }];
}

+ (void)doDelete:(NSString *)urlString block:(ProxyResultBlock)block {
    NSLog(@"DELETE - %@ - %@",urlString, [[NSUserDefaults standardUserDefaults] valueForKey:@"Authorization"]);
    
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"Authorization"]] forHTTPHeaderField:@"Authorization"];
    [[ProxyHTTPManager httpClient].requestSerializer setValue:[NSString stringWithFormat:@"%@", [Catalyze apiKey]] forHTTPHeaderField:@"X-Api-Key"];
    
    [[ProxyHTTPManager httpClient] DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, (int)[[operation response] statusCode], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error - %@ - %@", error, [error localizedDescription]);
        block(nil, (int)[[operation response] statusCode], error);
    }];
}

@end
