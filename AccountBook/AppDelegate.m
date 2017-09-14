//
//  AppDelegate.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AppDelegate.h"
#import "AccountBook-Swift.h"
#import "Grouper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    Grouper *grouper;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    //Register Remote Notification, support iOS version after 8.0
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    grouper = [Grouper sharedInstance];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [grouper setupWithAppId:@"accountbook"
                  dataStack:[self dataStack]
             mainStoryboard:storyboard];

    if (DEBUG) {
        GroupManager *group = grouper.group;
        NSLog(@"Number of group members is %ld, threshold is %ld, deletion interval time is %ldm", (long)group.members, (long)group.defaults.threshold, (long)group.defaults.interval);
        NSLog(@"Group id is %@, group name is %@, group owner is %@", group.defaults.groupId, group.defaults.groupName, group.defaults.owner);
        for (NSString *address in group.defaults.servers) {
            NSLog(@"Untrusted server %@", address);
        }
    }
    
    // Indicate to the system that your app wishes to perform background fetch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1800];

    // Use storyboard by init state.
    if (![grouper.group isInitialized]) {
        storyboard = grouper.ui.groupInit;
    }
    // Set root view controller and make windows visible
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *token = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                            stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (DEBUG) {
        NSLog(@"Device token from APNs server is %@", token);
    }
    [grouper.group sendDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Register remote notification failed with error: %@", error.localizedDescription);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"didReceiveRemoteNotification, userInfo = %@", userInfo);
    }
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *category = [aps valueForKey:@"category"];
    if ([category isEqualToString:@"message"]) {
        [self sync];
        [BannerTool showWithTitle:nil
                         subtitle:[aps valueForKey:@"alert"]
                            image:nil];
    }
}

// Background fetch.
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Background fetch started...");
    }
    [self sync];
}


#pragma mark - DataStack
@synthesize dataStack = _dataStack;

- (DataStack *)dataStack {
    if (_dataStack) {
        return _dataStack;
    }
    _dataStack = [[DataStack alloc] initWithModelName:@"Model"];
    return _dataStack;
}

#pragma mark - Service
- (void)setRootViewControllerWithIdentifer:(NSString *)identifer {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:identifer];
    [self.window makeKeyAndVisible];
}

- (void)sync {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [grouper.group checkServerState:^(NSDictionary *serverStates, BOOL sync) {
        if (sync) { 
            [grouper.receiver receiveWithCompletion:^(int success, Processing *processing) {
                if (DEBUG) {
                    NSLog(@"Sync ended...");
                }
            }];
        }
    }];
}

@end
