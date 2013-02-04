//
//  AppDelegate.m
//  TableViewControllerDemo
//
//  Created by Nicolas Verinaud on 04/02/13.
//  Copyright (c) 2013 Nicolas Verinaud. All rights reserved.
//

#import "AppDelegate.h"
#import "ContentViewController.h"
#import "ViewController.h"
#import "NVSlideMenuController.h"

@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NVSlideMenuController *slideMenu = [[NVSlideMenuController alloc] initWithMenuViewController:[ViewController new] andContentViewController:[ContentViewController new]];
	self.window.rootViewController = slideMenu;
	
    [self.window makeKeyAndVisible];
    return YES;
}

@end
