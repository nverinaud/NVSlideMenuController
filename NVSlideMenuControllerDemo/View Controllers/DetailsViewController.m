//
//  DetailsViewController.m
//  NVSlideMenuViewControllerDemo
//
//  Created by Nicolas Verinaud on 31/12/12.
//  Copyright (c) 2012 Nicolas Verinaud. All rights reserved.
//

#import "DetailsViewController.h"
#import "NVSlideMenuController.h"

@interface DetailsViewController ()
@property (retain, nonatomic) IBOutlet UITextView *textView;
- (IBAction)showMenu:(id)sender;

@end

@implementation DetailsViewController

#pragma mark - Memory Management

- (void)dealloc
{
	[_detailedObject release];
	[_textView release];
	[_onShowMenuButtonClicked release];
	
	[super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	if (![self isViewLoaded])
	{
		self.textView = nil;
	}
}


- (void)viewDidUnload
{
	[self setTextView:nil];
	[super viewDidUnload];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSLog(@"%@ - %@ - %@", self, NSStringFromSelector(_cmd), self.view);
	
	self.textView.text = [self.detailedObject description];
	
	if (self.slideMenuController)
	{
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self.slideMenuController action:@selector(toggleMenuAnimated:)];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"%@ - %@ - %@", self, NSStringFromSelector(_cmd), self.view);
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSLog(@"%@ - %@ - %@", self, NSStringFromSelector(_cmd), self.view);
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSLog(@"%@ - %@ - %@", self, NSStringFromSelector(_cmd), self.view);
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	NSLog(@"%@ - %@ - %@", self, NSStringFromSelector(_cmd), self.view);
}


#pragma mark - Show menu

- (IBAction)showMenu:(id)sender
{
	if (self.onShowMenuButtonClicked)
		self.onShowMenuButtonClicked();
	else
		[self.slideMenuController showMenuAnimated:YES completion:nil];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
