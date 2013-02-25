//
//  NVSlideMenuViewController.h
//  NVSlideMenuViewController
//
//  Created by Nicolas Verinaud on 31/12/12.
//  Copyright (c) 2012 Nicolas Verinaud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NVSlideMenuControllerSlideDirection)
{
    NVSlideMenuControllerSlideFromLeftToRight = 0, // default, slide from left to right to open the menu
    NVSlideMenuControllerSlideFromRightToLeft // slide from right to left to open the menu
};


@interface NVSlideMenuController : UIViewController

@property (nonatomic, readonly, strong) UIViewController *menuViewController;
@property (nonatomic, readonly, strong) UIViewController *contentViewController;
@property (nonatomic, assign) BOOL panGestureEnabled; // default is YES. Set it to NO to disable the pan gesture
@property (nonatomic, assign) CGFloat contentViewWidthWhenMenuIsOpen; // default is 44.0

- (id)initWithMenuViewController:(UIViewController *)menuViewController andContentViewController:(UIViewController *)contentViewController;

/** @name Navigation */
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void)showContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (IBAction)toggleMenuAnimated:(id)sender; // Convenience for use with target/action, always animate
- (void)showMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion;

/** @name Slide Direction */
@property (nonatomic, assign) NVSlideMenuControllerSlideDirection slideDirection;
- (void)setSlideDirection:(NVSlideMenuControllerSlideDirection)slideDirection animated:(BOOL)animated;

/** @name Menu state information */
- (BOOL)isMenuOpen;

#pragma mark Deprecations
@property (nonatomic, assign) BOOL panEnabledWhenSlideMenuIsHidden DEPRECATED_ATTRIBUTE; // Use `panGestureEnabled` property to control whether the pan gesture is enabled.

@end


#pragma mark - UIViewController (NVSlideMenuController)

@interface UIViewController (NVSlideMenuController)

@property (nonatomic, readonly) NVSlideMenuController *slideMenuController;

@end


#pragma mark - UIViewController (NVSlideMenuControllerCallbacks)

/**
 Subclasses may override these methods to perform custom actions (such as disable interaction with a web view or a table view)
 when they slide in our out.
 These callbacks are only called on the contentViewController of the slideMenuController.
 */
@interface UIViewController (NVSlideMenuControllerCallbacks)

- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController; // default implementation does nothing
- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController; // default implementation does nothing
- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController; // default implementation does nothing
- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController; // default implementation does nothing

@end
