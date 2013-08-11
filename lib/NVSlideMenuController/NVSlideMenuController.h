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
@property (nonatomic, assign) CGFloat menuWidth; // default is 276
@property (nonatomic, assign) BOOL autoAdjustMenuWidth; // default is YES. Set it to NO to keep the menu the same width as the SlideMenuController's view
@property (nonatomic, assign) BOOL bounceWhenNavigating; // default is NO. Determines whether the contentViewController will bounce offscreen when calling
                                                         // `-closeMenuBehindContentViewController:animated:completion:`
@property (nonatomic, assign) BOOL showShadowOnContentView; // default is YES. Set it to NO to remove shadow from content view

- (id)initWithMenuViewController:(UIViewController *)menuViewController andContentViewController:(UIViewController *)contentViewController;

/** @name Navigation */
- (IBAction)toggleMenuAnimated:(id)sender; // Convenience for use with target/action, always animate

- (void)openMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void)closeMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void)closeMenuBehindContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void)closeMenuBehindContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated bounce:(BOOL)bounce completion:(void(^)(BOOL finished))completion;

- (void)hideContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion; // hide the content view controller, the menu view controller will be resized
- (void)partiallyShowContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion; // show a part (equal to contentViewWidthWhenMenuIsOpen) of the content view controller, the menu view controller will be resized

/** @name Slide direction */
@property (nonatomic, assign) NVSlideMenuControllerSlideDirection slideDirection;
- (void)setSlideDirection:(NVSlideMenuControllerSlideDirection)slideDirection animated:(BOOL)animated;

/** @name Menu state information */
- (BOOL)isMenuOpen;
- (BOOL)isContentViewHidden;

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


#pragma mark - NVSlideMenuController (Deprecated)

@interface NVSlideMenuController (Deprecated)

@property (nonatomic, assign) CGFloat contentViewWidthWhenMenuIsOpen DEPRECATED_ATTRIBUTE; // default is 44.0, DEPRECATED use `menuWidth` property instead

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion DEPRECATED_ATTRIBUTE; // Use `-closeMenuBehindContentViewController:animated:completion:` instead
- (void)showContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion DEPRECATED_ATTRIBUTE; // Use `-closeMenuAnimated:completion:` instead
- (void)showMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion DEPRECATED_ATTRIBUTE; // Use `-openMenuAnimated:completion:` instead

@property (nonatomic, assign) BOOL panEnabledWhenSlideMenuIsHidden DEPRECATED_ATTRIBUTE; // Use `panGestureEnabled` property to control whether the pan gesture is enabled.

@end
