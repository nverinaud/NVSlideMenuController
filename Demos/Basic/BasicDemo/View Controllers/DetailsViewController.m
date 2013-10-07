//
//  DetailsViewController.m
//  BasicDemo
//
//  Created by Nicolas Verinaud on 31/12/12.
//  Copyright (c) 2012 Nicolas Verinaud. All rights reserved.
//

#import "DetailsViewController.h"
#import "NVSlideMenuController.h"

@interface DetailsViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UISwitch *bounceSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *menuWidthSwitch;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
- (void)updateTextViewAccordingToSlideMenuControllerDirection;

// Lazy buttons
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *rightBarButtonItem;
- (void)updateBarButtonsAccordingToSlideMenuControllerDirectionAnimated:(BOOL)animated;

// Actions
- (IBAction)showMenu:(id)sender;
- (IBAction)changeSlideDirection:(id)sender;
- (IBAction)bounceSwitchValueChanged:(id)sender;
- (IBAction)menuWidthSwitchValueChanged:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end

@implementation DetailsViewController

#if !__has_feature(objc_arc)
- (void)dealloc
{
	NSLog(@"%p dealloc'ed", self);
	
	[_detailedObject release];
	[_onShowMenuButtonClicked release];
	
	[_textView release];
	[_bounceSwitch release];
	[_menuWidthSwitch release];
	[_toolbar release];
	
	[_leftBarButtonItem release];
	[_rightBarButtonItem release];
	
	[super dealloc];
}
#endif


#pragma mark - Creation
#pragma mark - Overriden Designated Initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
		{
			self.edgesForExtendedLayout = UIRectEdgeNone;
		}
	}
	
	return self;
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	if (![self isViewLoaded])
	{
		self.textView = nil;
		self.toolbar = nil;
	}
}


- (void)viewDidUnload
{
	[self setTextView:nil];
    [self setBounceSwitch:nil];
    [self setMenuWidthSwitch:nil];
	self.toolbar = nil;
	[super viewDidUnload];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
	
	self.title = NSLocalizedString(@"Details", nil);
	
	[self updateTextViewAccordingToSlideMenuControllerDirection];
	[self updateBarButtonsAccordingToSlideMenuControllerDirectionAnimated:NO];
    
    self.bounceSwitch.on = self.slideMenuController.bounceWhenNavigating;
    self.menuWidthSwitch.on = self.slideMenuController.autoAdjustMenuWidth;
	self.textView.inputAccessoryView = self.toolbar;
}


- (void)updateTextViewAccordingToSlideMenuControllerDirection
{
	NSString *slideDirectionAsString = nil;
	if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
		slideDirectionAsString = @"From left to right";
	else if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
		slideDirectionAsString = @"From right to left";
	
	self.textView.text = [NSString stringWithFormat:@"Direction: %@", slideDirectionAsString];
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
		[self.slideMenuController openMenuAnimated:YES completion:nil];
}


#pragma mark - Change slide direction

- (IBAction)changeSlideDirection:(id)sender
{
	if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
		self.slideMenuController.slideDirection = NVSlideMenuControllerSlideFromRightToLeft;
	else if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
		self.slideMenuController.slideDirection = NVSlideMenuControllerSlideFromLeftToRight;
	
	[self updateBarButtonsAccordingToSlideMenuControllerDirectionAnimated:YES];
	[self updateTextViewAccordingToSlideMenuControllerDirection];
}


- (IBAction)bounceSwitchValueChanged:(id)sender
{
    UISwitch *theSwitch = sender;
    self.slideMenuController.bounceWhenNavigating = theSwitch.isOn;
}


- (IBAction)menuWidthSwitchValueChanged:(id)sender
{
    UISwitch *theSwitch = sender;
    self.slideMenuController.autoAdjustMenuWidth = theSwitch.isOn;
}


- (IBAction)hideKeyboard:(id)sender
{
	[self.view endEditing:YES];
}


#pragma mark - Lazy buttons

- (UIBarButtonItem *)leftBarButtonItem
{
	if (!_leftBarButtonItem)
	{
		_leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
																		   target:self.slideMenuController
																		   action:@selector(toggleMenuAnimated:)];
	}
	return _leftBarButtonItem;
}


- (UIBarButtonItem *)rightBarButtonItem
{
	if (!_rightBarButtonItem)
	{
		_rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
																		   target:self.slideMenuController
																		   action:@selector(toggleMenuAnimated:)];
	}
	
	return _rightBarButtonItem;
}


- (void)updateBarButtonsAccordingToSlideMenuControllerDirectionAnimated:(BOOL)animated
{
	if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
	{
		[self.navigationItem setLeftBarButtonItem:self.leftBarButtonItem animated:animated];
		[self.navigationItem setRightBarButtonItem:nil animated:animated];
	}
	else if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
	{
		[self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:animated];
		[self.navigationItem setLeftBarButtonItem:nil animated:animated];
	}
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
