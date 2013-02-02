//
//  AppDelegate.m
//  NVSlideMenuViewControllerDemo
//
//  Created by Nicolas Verinaud on 31/12/12.
//  Copyright (c) 2012 Nicolas Verinaud. All rights reserved.
//

#import "AppDelegate.h"
#import "NVSlideMenuController.h"
#import "MenuViewController.h"
#import "DetailsViewController.h"

void uncaughtExceptionHandler(NSException*);

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	MenuViewController *menuVC = [[MenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:menuVC];
	
	DetailsViewController *detailsVC = [[DetailsViewController alloc] init];
	detailsVC.detailedObject = @"Welcome Slide Menu !";
	
	NVSlideMenuController *slideMenuVC = [[NVSlideMenuController alloc] initWithMenuViewController:menuNavigationController andContentViewController:detailsVC];
	
	self.window.rootViewController = slideMenuVC;
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}
