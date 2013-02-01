//
//  MenuViewController.m
//  NVSlideMenuViewControllerDemo
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
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Pan Enabled", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(togglePanGestureEnabled:)] autorelease];
	
	NSLog(@"%@ - %@ - %@", self, NSStringFromSelector(_cmd), self.view);
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
	
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:animated];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
	// Second row of first section shows a modal view controller
	if (indexPath.section == 0 && indexPath.row == 1)
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
		
		if (indexPath.section == 0 && indexPath.row == 1)
		{
			[detailsVC setOnShowMenuButtonClicked:^{
				[self dismissModalViewControllerAnimated:YES];
			}];
			[self presentViewController:detailsVC animated:YES completion:nil];
		}
		else
		{
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
			[self.slideMenuController setContentViewController:navController animated:YES completion:nil];
			[navController release];
		}
		
		[detailsVC release];
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


@end
