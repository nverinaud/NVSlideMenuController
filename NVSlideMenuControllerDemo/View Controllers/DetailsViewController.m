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
	
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
	
	self.title = NSLocalizedString(@"Details", nil);
	self.textView.text = [self.detailedObject description];
	
	if (self.slideMenuController)
	{
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self.slideMenuController action:@selector(toggleMenuAnimated:)];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
}


#pragma mark - Slide callbacks

/**
 Here is an example of how you can best use these callbacks !
 */
- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
	
	[self.textView setEditable:YES];
	[self.textView setScrollEnabled:YES];
}


- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
	
	[self.textView becomeFirstResponder];
}


- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
	
	[self.textView resignFirstResponder];
}


- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
	
	[self.textView setEditable:NO];
	[self.textView setScrollEnabled:NO];
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
