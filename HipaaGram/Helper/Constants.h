#define kProxyBaseUrl @"http://localhost:8080"//@"http://10.23.16.111:8080"

#define kUserUsername @"user_username"
#define kUserEmail @"user_email"
#define kUserPassword @"user_password"

#define kConversations @"conversations"
#define kTokens @"tokens"

typedef void (^ProxyResultBlock)(id response, int status, NSError *error);