//
//  AppDelegate.m
//  MoviePlayer
//
//  Created by Nicolas VERINAUD on 11/08/13.
//  Copyright (c) 2013 Nicolas VERINAUD. All rights reserved.
//

#import "AppDelegate.h"
#import "NVSlideMenuController.h"
#import "MenuViewController.h"
#import "VideosViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	MenuViewController *menuVC = [MenuViewController new];
	VideosViewController *videoVC = [VideosViewController new];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:videoVC];
	NVSlideMenuController *slide = [[NVSlideMenuController alloc] initWithMenuViewController:menuVC andContentViewController:nav];
	
	self.window.rootViewController = slide;
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
