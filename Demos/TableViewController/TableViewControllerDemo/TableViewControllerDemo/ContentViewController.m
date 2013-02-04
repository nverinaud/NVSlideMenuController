//
//  ContentViewController.m
//  TableViewControllerDemo
//
//  Created by Nicolas Verinaud on 04/02/13.
//  Copyright (c) 2013 Nicolas Verinaud. All rights reserved.
//

#import "ContentViewController.h"
#import "NVSlideMenuController.h"

@interface ContentViewController ()
@property (nonatomic, strong) NSMutableArray *elements;
@end


@implementation ContentViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self.slideMenuController action:@selector(toggleMenuAnimated:)];
	[navBar pushNavigationItem:self.navigationItem animated:NO];
	
	[self.tableView setTableHeaderView:navBar];
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
}


#pragma mark - Elements

#define NUMBER_OF_ELEMENTS 100

- (NSMutableArray *)elements
{
	if (!_elements)
	{
		_elements = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < NUMBER_OF_ELEMENTS; i++)
			[_elements addObject:@( i )];
	}
	
	return _elements;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"Elements %@", [self.elements objectAtIndex:indexPath.row]];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        [self.elements removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
	{
		[self.elements addObject:@( indexPath.row )];
		[tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }   
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	id element = [self.elements objectAtIndex:fromIndexPath.row];
	[self.elements removeObject:element];
	[self.elements insertObject:element atIndex:toIndexPath.row];
	
	[tableView reloadData];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Edit mode

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	self.slideMenuController.panGestureEnabled = !editing;
}


//#pragma mark - Slide callbacks
//
//- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
//{
//	[super viewDidSlideIn:animated inSlideMenuController:slideMenuController];
//	
//	slideMenuController.panGestureEnabled = NO;
//}
//
//
//- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
//{
//	[super viewWillSlideOut:animated inSlideMenuController:slideMenuController];
//	
//	slideMenuController.panGestureEnabled = YES;
//}

@end
