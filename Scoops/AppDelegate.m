//
//  AppDelegate.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import "AppDelegate.h"
#import "Scoop.h"
#import "MyScoopViewController.h"
#import "MyScoopsTableViewController.h"
#import "MyScoopsViewController.h"
#import "NewScoopViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    
    //MyScoopViewController *myScoopVC = [[MyScoopViewController alloc] initWithScoop:scoop];
    //NewScoopViewController *newScoopVC = [[NewScoopViewController alloc] init];
    //MyScoopsTableViewController *tVC = [[MyScoopsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    MyScoopsViewController *myScoopsVC = [[MyScoopsViewController alloc] initWithScoops:[self populateLocalScoops]];
    UINavigationController *myScoopsNavC = [[UINavigationController alloc] initWithRootViewController:myScoopsVC];
    
    UITabBarController *tb = [[UITabBarController alloc] init];
    [tb setViewControllers:@[/*myScoopVC, */myScoopsNavC]];
    
    self.window.rootViewController = tb;
    
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (NSArray *) populateLocalScoops {
    
    Scoop *scoop1 = [[Scoop alloc] initWithTitle:@"Título 1"
                                       andPhoto:nil
                                          aText:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet."
                                       anAuthor:@"Mixi"
                                          aCoor:CLLocationCoordinate2DMake(0, 0)
                                       published: YES];
    
    Scoop *scoop2 = [[Scoop alloc] initWithTitle:@"Título 2"
                                        andPhoto:nil
                                           aText:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet."
                                        anAuthor:@"Mixi"
                                           aCoor:CLLocationCoordinate2DMake(0, 0)
                                       published: YES];
    
    Scoop *scoop3 = [[Scoop alloc] initWithTitle:@"Título 3"
                                        andPhoto:nil
                                           aText:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet."
                                        anAuthor:@"Mixi"
                                           aCoor:CLLocationCoordinate2DMake(0, 0)
                                       published: YES];
    
    Scoop *scoop4 = [[Scoop alloc] initWithTitle:@"Título 4"
                                        andPhoto:nil
                                           aText:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet."
                                        anAuthor:@"Mixi"
                                           aCoor:CLLocationCoordinate2DMake(0, 0)
                                       published: NO];
    
    Scoop *scoop5 = [[Scoop alloc] initWithTitle:@"Título 5"
                                        andPhoto:nil
                                           aText:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet."
                                        anAuthor:@"Mixi"
                                           aCoor:CLLocationCoordinate2DMake(0, 0)
                                       published: NO];
    
    return @[scoop1, scoop2, scoop3, scoop4, scoop5];
}

@end
