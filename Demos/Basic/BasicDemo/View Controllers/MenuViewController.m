//
//  MenuViewController.m
//  BasicDemo
//
//  Created by Nicolas Verinaud on 31/12/12.
//  Copyright (c) 2012 Nicolas Verinaud. All rights reserved.
//

#import "MenuViewController.h"
#import "DetailsViewController.h"
#import "NVSlideMenuController.h"

#define NUMBER_OF_SECTIONS	3
#define NUMBER_OF_ROWS		10

@interface MenuViewController ()

- (void)togglePanGestureEnabled:(UIBarButtonItem *)sender;
- (void)toggleSlideDirection:(UIBarButtonItem *)sender;

@end



@implementation MenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.clearsSelectionOnViewWillAppear = NO;
	self.title = NSLocalizedString(@"Menu", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Pan Enabled", nil)
																			   style:UIBarButtonItemStyleBordered
																			  target:self
																			  action:@selector(togglePanGestureEnabled:)];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"L->R", nil)
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(toggleSlideDirection:)];
	
	NSLog(@"%@ - %@ - View Frame: %@", self, NSStringFromSelector(_cmd), NSStringFromCGRect(self.view.frame));
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
	
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:animated];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUMBER_OF_ROWS;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
#if !__has_feature(objc_arc)
		[cell autorelease];
#endif
	}
    
	// First row of first section toggle menu full screen
	if (indexPath.section == 0 && indexPath.row == 0)
		cell.textLabel.text = NSLocalizedString(@"Toggle Content View", nil);
	// Second row of first section shows a modal view controller
	else if (indexPath.section == 0 && indexPath.row == 1)
		cell.textLabel.text = NSLocalizedString(@"Show modal", nil);
	else
		cell.textLabel.text = [NSString stringWithFormat:@"Section: %d - Row: %d", indexPath.section, indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.slideMenuController)
	{
		DetailsViewController *detailsVC = [DetailsViewController new];
		detailsVC.detailedObject = indexPath;
		
		if (indexPath.section == 0 && indexPath.row == 0)
		{
			if ([self.slideMenuController isContentViewHidden])
				[self.slideMenuController partiallyShowContentViewControllerAnimated:YES completion:nil];
			else
				[self.slideMenuController hideContentViewControllerAnimated:YES completion:nil];
			
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		else if (indexPath.section == 0 && indexPath.row == 1)
		{
			[detailsVC setOnShowMenuButtonClicked:^{
				[self dismissViewControllerAnimated:YES completion:nil];
			}];
			[self presentViewController:detailsVC animated:YES completion:nil];
		}
		else
		{
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
			[self.slideMenuController closeMenuBehindContentViewController:navController animated:YES completion:nil];
#if !__has_feature(objc_arc)
			[navController release];
#endif
		}
		
#if !__has_feature(objc_arc)
		[detailsVC release];
#endif
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - Toggle pan gesture enabled

- (void)togglePanGestureEnabled:(UIBarButtonItem *)sender
{
	self.slideMenuController.panGestureEnabled = !self.slideMenuController.panGestureEnabled;
	sender.title = self.slideMenuController.panGestureEnabled ? NSLocalizedString(@"Pan Enabled", nil) : NSLocalizedString(@"Pan Disabled", nil);
}


#pragma mark - Toggle slide direction

- (void)toggleSlideDirection:(UIBarButtonItem *)sender
{
	if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
	{
		[self.slideMenuController setSlideDirection:NVSlideMenuControllerSlideFromRightToLeft animated:YES];
		sender.title = NSLocalizedString(@"R->L", nil);
	}
	else if (self.slideMenuController.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
	{
		[self.slideMenuController setSlideDirection:NVSlideMenuControllerSlideFromLeftToRight animated:YES];
		sender.title = NSLocalizedString(@"L->R", nil);
	}
}


@end
