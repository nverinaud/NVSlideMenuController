//
//  VideosViewController.m
//  MoviePlayer
//
//  Created by Nicolas VERINAUD on 11/08/13.
//  Copyright (c) 2013 Nicolas VERINAUD. All rights reserved.
//

#import "VideosViewController.h"
#import "NVSlideMenuController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideosViewController ()

@end


@implementation VideosViewController

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"Launch Video" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(launchVideo:) forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(0, 0, 120, 44);
	button.center = self.view.center;
	button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
	[self.view addSubview:button];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
																						  target:self.slideMenuController
																						  action:@selector(toggleMenuAnimated:)];
}


- (void)launchVideo:(id)sender
{
	NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"];
	NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
	MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
	playerVC.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
	[self presentMoviePlayerViewControllerAnimated:playerVC];
}

@end
