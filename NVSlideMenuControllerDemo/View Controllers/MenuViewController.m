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
    
    cell.textLabel.text = [indexPath description];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.slideMenuController)
	{
		DetailsViewController *detailsVC = [DetailsViewController new];
		detailsVC.detailedObject = indexPath;
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
		[detailsVC release];
		
		[self.slideMenuController setContentViewController:navController animated:YES completion:nil];
		[navController release];
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


@end
