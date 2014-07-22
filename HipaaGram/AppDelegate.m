/*
 * Copyright (C) 2014 Catalyze, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "AppDelegate.h"
#import "Catalyze.h"

@interface AppDelegate()

@property (strong, nonatomic) UINavigationController *controller;
@property (strong, nonatomic) SignInViewController *signInViewController;
@property (strong, nonatomic) ConversationListViewController *conversationListViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    _signInViewController = [[SignInViewController alloc] initWithNibName:nil bundle:nil];
    _signInViewController.delegate = self;
    _controller = [[UINavigationController alloc] initWithRootViewController:_signInViewController];
    self.window.rootViewController = _controller;
    
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    [UAPush shared].pushNotificationDelegate = self;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [Catalyze setApiKey:@"" applicationId:@""];
    [Catalyze setLoggingLevel:kLoggingLevelDebug];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (_handler) {
        [_handler handleNotification:[[userInfo objectForKey:@"notification"] valueForKey:@"alert"]];
    }
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - SignInDelegate

- (void)signInSuccessful {
    [UAPush shared].alias = [[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername];
    [[UAPush shared] updateRegistration];
    _conversationListViewController = [[ConversationListViewController alloc] initWithNibName:nil bundle:nil];
    [_controller popViewControllerAnimated:NO];
    [_controller pushViewController:_conversationListViewController animated:YES];
}

#pragma mark - UAPushNotificationDelegate

- (void)displayNotificationAlert:(NSString *)alertMessage {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [[[UIAlertView alloc] initWithTitle:@"New Message" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else if (_handler) {
        [_handler handleNotification:alertMessage];
    }
}

- (void)receivedForegroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)launchedFromNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    completionHandler(UIBackgroundFetchResultNoData);
}

@end
