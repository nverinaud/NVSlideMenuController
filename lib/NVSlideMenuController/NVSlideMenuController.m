//
//  NVSlideMenuViewController.m
//  NVSlideMenuViewController
//
//  Created by Nicolas Verinaud on 31/12/12.
//  Copyright (c) 2012 Nicolas Verinaud. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NVSlideMenuController.h"

#ifdef __has_feature
	#define OBJC_ARC_ENABLED __has_feature(objc_arc)
#else
	#define OBJC_ARC_ENABLED 0
#endif


#define ANIMATION_DURATION				0.3f

@interface NVSlideMenuController ()

@property (nonatomic, readwrite, strong) UIViewController *menuViewController;
@property (nonatomic, readwrite, strong) UIViewController *contentViewController;

- (void)setShadowOnContentViewControllerView;
- (CGSize)shadowOffsetAccordingToCurrentSlideDirection;

/**
 Load the menu view controller view and add its view as a subview
 to self.view with correct frame.
 */
- (void)loadMenuViewControllerViewIfNeeded;

/** Gesture recognizers */
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
- (void)tapGestureTriggered:(UITapGestureRecognizer *)tapGesture;

@property (nonatomic, assign) CGRect contentViewControllerFrame;
@property (nonatomic, assign) BOOL menuWasOpenAtPanBegin;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
- (void)panGestureTriggered:(UIPanGestureRecognizer *)panGesture;

/** Offset X when the menu is open */
- (CGFloat)offsetXWhenMenuIsOpen;
- (CGRect)menuViewFrameAccordingToCurrentSlideDirection;

@end


@implementation NVSlideMenuController

#pragma mark - Memory Management

#if !OBJC_ARC_ENABLED
- (void)dealloc
{
	[_menuViewController release];
	[_contentViewController release];
	
	[_tapGesture release];
	[_panGesture release];
	
	[super dealloc];
}
#endif


#pragma mark - Creation
#pragma mark Designated Initializer

- (id)initWithMenuViewController:(UIViewController *)menuViewController andContentViewController:(UIViewController *)contentViewController
{
	self = [super initWithNibName:nil bundle:nil];
	if (self)
	{
		self.menuViewController = menuViewController;
		self.contentViewController = contentViewController;
		self.panGestureEnabled = YES;
        self.slideDirection = NVSlideMenuControllerSlideFromLeftToRight;
		self.contentViewWidthWhenMenuIsOpen = 44.f;
	}
	
	return self;
}

#pragma mark Overriden Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		self.menuViewController = nil;
		self.contentViewController = nil;
		self.panGestureEnabled = YES;
        self.slideDirection = NVSlideMenuControllerSlideFromLeftToRight;
	}
	
	return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithMenuViewController:nil andContentViewController:nil];
}


#pragma mark - Children View Controllers

- (void)setMenuViewController:(UIViewController *)menuViewController
{
	if (menuViewController != _menuViewController)
	{
		[_menuViewController willMoveToParentViewController:nil];
		[_menuViewController removeFromParentViewController];
		
#if !OBJC_ARC_ENABLED
		[_menuViewController release];
		_menuViewController = [menuViewController retain];
#else
		_menuViewController = menuViewController;
#endif
		
		[self addChildViewController:_menuViewController];
		[_menuViewController didMoveToParentViewController:self];
	}
}


- (void)setContentViewController:(UIViewController *)contentViewController
{
	if (contentViewController != _contentViewController)
	{
		[_contentViewController willMoveToParentViewController:nil];
		[_contentViewController removeFromParentViewController];
		
#if !OBJC_ARC_ENABLED
		[_contentViewController release];
		_contentViewController = [contentViewController retain];
#else
		_contentViewController = contentViewController;
#endif
		
		[self addChildViewController:_contentViewController];
		[_contentViewController didMoveToParentViewController:self];
	}
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.view addSubview:self.contentViewController.view];
	[self setShadowOnContentViewControllerView];
	
	[self.contentViewController.view addGestureRecognizer:self.tapGesture];
	self.tapGesture.enabled = NO;
	[self.contentViewController.view addGestureRecognizer:self.panGesture];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (![self isMenuOpen])
		self.contentViewController.view.frame = self.view.bounds;
	
	[self.contentViewController beginAppearanceTransition:YES animated:animated];
	if ([self.menuViewController isViewLoaded] && self.menuViewController.view.superview)
		[self.menuViewController beginAppearanceTransition:YES animated:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.contentViewController endAppearanceTransition];
	if ([self.menuViewController isViewLoaded] && self.menuViewController.view.superview)
		[self.menuViewController endAppearanceTransition];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.contentViewController beginAppearanceTransition:NO animated:animated];
	if ([self.menuViewController isViewLoaded])
		[self.menuViewController beginAppearanceTransition:NO animated:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[self.contentViewController endAppearanceTransition];
	if ([self.menuViewController isViewLoaded])
		[self.menuViewController endAppearanceTransition];
}


#pragma mark - Appearance & rotation callbacks

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
	return NO;
}


- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}


- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
	return NO;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
	return [self.menuViewController shouldAutorotate] && [self.contentViewController shouldAutorotate];
}


- (NSUInteger)supportedInterfaceOrientations
{
	return [self.menuViewController supportedInterfaceOrientations] & [self.contentViewController supportedInterfaceOrientations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return	[self.menuViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] &&
			[self.contentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if ([self isMenuOpen])
	{
		CGRect frame = self.contentViewController.view.frame;
		frame.origin.x = [self offsetXWhenMenuIsOpen];
		[UIView animateWithDuration:duration animations:^{
			self.contentViewController.view.frame = frame;
		}];
	}
}


#pragma mark - Shadow

- (void)setShadowOnContentViewControllerView
{
	UIView *contentView = self.contentViewController.view;
	CALayer *layer = contentView.layer;
	layer.masksToBounds = NO;
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowOpacity = 1.f;
	layer.shadowRadius = 5.f;
	layer.shadowPath = [[UIBezierPath bezierPathWithRect:contentView.bounds] CGPath];
	layer.shadowOffset = [self shadowOffsetAccordingToCurrentSlideDirection];
}


- (CGSize)shadowOffsetAccordingToCurrentSlideDirection
{
	if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
		return CGSizeMake(-2.5f, 0.f);
	else if (self.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
		return CGSizeMake(2.5f, 0.f);
	
	return CGSizeZero;
}


#pragma mark - Slide Direction

- (void)setSlideDirection:(NVSlideMenuControllerSlideDirection)slideDirection
{
	[self setSlideDirection:slideDirection animated:NO];
}


- (void)setSlideDirection:(NVSlideMenuControllerSlideDirection)slideDirection animated:(BOOL)animated
{
	if (slideDirection != _slideDirection)
	{
		_slideDirection = slideDirection;
		
		if ([self.menuViewController isViewLoaded] && [self.contentViewController isViewLoaded])
		{
			BOOL menuIsOpen = [self isMenuOpen];
			NSTimeInterval duration = (animated && menuIsOpen) ? ANIMATION_DURATION*1.5 : 0;
			CGRect targetedContentViewFrame = self.view.bounds;
			if (menuIsOpen)
				targetedContentViewFrame.origin.x = [self offsetXWhenMenuIsOpen];
			
			UIView *contentView = self.contentViewController.view;
			CALayer *layer = contentView.layer;
			
			[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				
				self.menuViewController.view.frame = [self menuViewFrameAccordingToCurrentSlideDirection];
				self.contentViewController.view.frame = targetedContentViewFrame;
				layer.shadowOffset = [self shadowOffsetAccordingToCurrentSlideDirection];
				
			} completion:nil];
		}
	}
}


#pragma mark - Menu view lazy load

- (void)loadMenuViewControllerViewIfNeeded
{
	if (!self.menuViewController.view.window)
	{
		self.menuViewController.view.frame = [self menuViewFrameAccordingToCurrentSlideDirection];
		[self.view insertSubview:self.menuViewController.view atIndex:0];
	}
}


#pragma mark - Navigation

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	NSAssert(contentViewController != nil, @"Can't show a nil content view controller.");
	
	if (contentViewController != self.contentViewController)
	{
		// Preserve the frame
		CGRect frame = self.contentViewController.view.frame;
		
		// Remove old content view
		[self.contentViewController.view removeGestureRecognizer:self.tapGesture];
		[self.contentViewController.view removeGestureRecognizer:self.panGesture];
		[self.contentViewController beginAppearanceTransition:NO animated:NO];
		[self.contentViewController.view removeFromSuperview];
		[self.contentViewController endAppearanceTransition];
		
		// Add the new content view
		self.contentViewController = contentViewController;
		self.contentViewController.view.frame = frame;
		[self.contentViewController.view addGestureRecognizer:self.tapGesture];
		[self.contentViewController.view addGestureRecognizer:self.panGesture];
		[self setShadowOnContentViewControllerView];
		[self.contentViewController beginAppearanceTransition:YES animated:NO];
		[self.view addSubview:self.contentViewController.view];
		[self.contentViewController endAppearanceTransition];
	}
	
	// Perform the show animation
	[self showContentViewControllerAnimated:animated completion:completion];
}


- (void)showContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	// Remove gestures
	self.tapGesture.enabled = NO;
	
	self.menuViewController.view.userInteractionEnabled = NO;
	
	NSTimeInterval duration = animated ? ANIMATION_DURATION : 0;
	
	UIView *contentView = self.contentViewController.view;
	CGRect contentViewFrame = contentView.frame;
	contentViewFrame.origin.x = 0;
	
	[self.menuViewController beginAppearanceTransition:NO animated:animated];
	[self.contentViewController viewWillSlideIn:animated inSlideMenuController:self];
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		contentView.frame = contentViewFrame;
	} completion:^(BOOL finished) {
		[self.menuViewController endAppearanceTransition];
		[self.contentViewController viewDidSlideIn:animated inSlideMenuController:self];
		
		self.menuViewController.view.userInteractionEnabled = YES;
	
		if (completion)
			completion(finished);
	}];
}


- (IBAction)toggleMenuAnimated:(id)sender
{
	if ([self isMenuOpen])
		[self showContentViewControllerAnimated:YES completion:nil];
	else
		[self showMenuAnimated:YES completion:nil];
}


- (void)showMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{	
	NSTimeInterval duration = animated ? ANIMATION_DURATION : 0;
	
	UIView *contentView = self.contentViewController.view;
	CGRect contentViewFrame = contentView.frame;
	contentViewFrame.origin.x = [self offsetXWhenMenuIsOpen];
	
	[self loadMenuViewControllerViewIfNeeded];
	[self.menuViewController beginAppearanceTransition:YES animated:animated];
	[self.contentViewController viewWillSlideOut:animated inSlideMenuController:self];
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		contentView.frame = contentViewFrame;
	} completion:^(BOOL finished) {
		[self.menuViewController endAppearanceTransition];
		[self.contentViewController viewDidSlideOut:animated inSlideMenuController:self];
		
		self.tapGesture.enabled = YES;
		self.panGesture.enabled = YES;
		
		if (completion)
			completion(finished);
	}];
}


#pragma mark - Gestures

- (UITapGestureRecognizer *)tapGesture
{
	if (!_tapGesture)
		_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTriggered:)];
	
	return _tapGesture;
}


- (void)tapGestureTriggered:(UITapGestureRecognizer *)tapGesture
{
	if (tapGesture.state == UIGestureRecognizerStateEnded)
		[self showContentViewControllerAnimated:YES completion:nil];
}


- (UIPanGestureRecognizer *)panGesture
{
	if (!_panGesture)
	{
		_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureTriggered:)];
		[_panGesture requireGestureRecognizerToFail:self.tapGesture];
	}
	
	return _panGesture;
}


- (void)setPanGestureEnabled:(BOOL)panGestureEnabled
{
	self.panGesture.enabled = panGestureEnabled;
}


- (BOOL)panGestureEnabled
{
	return self.panGesture.enabled;
}


- (void)panGestureTriggered:(UIPanGestureRecognizer *)panGesture
{
	if (panGesture.state == UIGestureRecognizerStateBegan)
	{
		self.contentViewControllerFrame = self.contentViewController.view.frame;
		self.menuWasOpenAtPanBegin = [self isMenuOpen];
		
		if (!self.menuWasOpenAtPanBegin)
		{
			[self loadMenuViewControllerViewIfNeeded]; // Menu is closed, load it if needed
			[self.menuViewController beginAppearanceTransition:YES animated:YES]; // Menu is appearing
			[self.contentViewController viewWillSlideOut:YES inSlideMenuController:self]; // Content view controller is sliding out
		}
		else
		{
			[self.contentViewController viewWillSlideIn:YES inSlideMenuController:self];
		}
	}
	
	CGPoint translation = [panGesture translationInView:panGesture.view];
	
	CGRect frame = self.contentViewControllerFrame;
    CGFloat offsetXWhenMenuIsOpen = [self offsetXWhenMenuIsOpen];
    
    if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
	{
        frame.origin.x += translation.x;
        
        if (frame.origin.x > offsetXWhenMenuIsOpen)
            frame.origin.x = offsetXWhenMenuIsOpen;
        else if (frame.origin.x < 0)
            frame.origin.x = 0;
    }
	else
	{
		frame.origin.x += translation.x;
        
        if (frame.origin.x < offsetXWhenMenuIsOpen)
            frame.origin.x = offsetXWhenMenuIsOpen;
        else if (frame.origin.x > 0)
            frame.origin.x = 0;
    }
	
	panGesture.view.frame = frame;
	
	if (panGesture.state == UIGestureRecognizerStateEnded)
	{
		CGPoint velocity = [panGesture velocityInView:panGesture.view];
		CGFloat distance = 0;
		NSTimeInterval animationDuration = 0;
        
        BOOL close = NO;
        if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
            close = (velocity.x < 0);
        else
            close = (velocity.x > 0);
				
		if (close) // Close
		{
			// Compute animation duration
			distance = frame.origin.x;
			animationDuration = fabs(distance / velocity.x);
			if (animationDuration > ANIMATION_DURATION)
				animationDuration = ANIMATION_DURATION;
			
			// Remove gestures
			self.tapGesture.enabled = NO;
			
			frame.origin.x = 0;
			
			if (!self.menuWasOpenAtPanBegin)
			{
				[self.menuViewController endAppearanceTransition];
				[self.contentViewController viewDidSlideOut:YES inSlideMenuController:self];
				[self.contentViewController viewWillSlideIn:YES inSlideMenuController:self];
			}
			
			[self.menuViewController beginAppearanceTransition:NO animated:YES];
			
			[UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				self.contentViewController.view.frame = frame;
			} completion:^(BOOL finished) {
				[self.menuViewController endAppearanceTransition];
				[self.contentViewController viewDidSlideIn:YES inSlideMenuController:self];
			}];
		}
		else // Open
		{
			distance = fabsf(offsetXWhenMenuIsOpen - frame.origin.x);
			animationDuration = fabs(distance / velocity.x);
			if (animationDuration > ANIMATION_DURATION)
				animationDuration = ANIMATION_DURATION;
			
			frame.origin.x = offsetXWhenMenuIsOpen;
			
			if (self.menuWasOpenAtPanBegin)
			{
				[self.contentViewController viewDidSlideIn:YES inSlideMenuController:self];
				[self.contentViewController viewWillSlideOut:YES inSlideMenuController:self];
			}
			
			[UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				self.contentViewController.view.frame = frame;
			} completion:^(BOOL finished) {
				self.tapGesture.enabled = YES;
				
				if (!self.menuWasOpenAtPanBegin)
					[self.menuViewController endAppearanceTransition];
				
				[self.contentViewController viewDidSlideOut:YES inSlideMenuController:self];
			}];
		}
		
		self.contentViewControllerFrame = frame;
	}
}


#pragma mark - Utils

- (BOOL)isMenuOpen
{
	if ([self.contentViewController isViewLoaded])
		return self.contentViewController.view.frame.origin.x != 0;
	
	return NO;
}


- (CGFloat)offsetXWhenMenuIsOpen
{
    if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
        return		CGRectGetWidth(self.view.bounds) - self.contentViewWidthWhenMenuIsOpen;
    else
		return   - (CGRectGetWidth(self.view.bounds) - self.contentViewWidthWhenMenuIsOpen);
}


- (CGRect)menuViewFrameAccordingToCurrentSlideDirection
{
	CGRect menuFrame = self.view.bounds;
	
	menuFrame.size.width -= self.contentViewWidthWhenMenuIsOpen;
	
	if (self.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
		menuFrame.origin.x = self.contentViewWidthWhenMenuIsOpen;
	
	return menuFrame;
}


#pragma mark - Deprecations

- (void)setPanEnabledWhenSlideMenuIsHidden:(BOOL)panEnabledWhenSlideMenuIsHidden
{
	self.panGestureEnabled = panEnabledWhenSlideMenuIsHidden;
}


- (BOOL)panEnabledWhenSlideMenuIsHidden
{
	return self.panGestureEnabled;
}

@end


#pragma mark -
#pragma mark - UIViewController (NVSlideMenuController)

@implementation UIViewController (NVSlideMenuController)

- (NVSlideMenuController *)slideMenuController
{
	NVSlideMenuController *slideMenuController = nil;
	UIViewController *parentViewController = self.parentViewController;
	
	while (!slideMenuController && parentViewController)
	{
		if ([parentViewController isKindOfClass:NVSlideMenuController.class])
			slideMenuController = (NVSlideMenuController *) parentViewController;
		else
			parentViewController = parentViewController.parentViewController;
	}
	
	return slideMenuController;
}

@end

#pragma mark - UIViewController (NVSlideMenuControllerCallbacks)

@implementation UIViewController (NVSlideMenuControllerCallbacks)

- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	// default implementation does nothing
}


- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	// default implementation does nothing
}


- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	// default implementation does nothing
}


- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	// default implementation does nothing
}

@end



#pragma mark - 
#pragma mark Private Categories

#pragma mark UINavigationController (NVSlideMenuControllerCallbacks)

@interface UINavigationController (NVSlideMenuControllerCallbacks)
// Forward callbacks to the topViewController
@end

@implementation UINavigationController (NVSlideMenuControllerCallbacks)

- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.topViewController viewWillSlideIn:animated inSlideMenuController:slideMenuController];
}


- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.topViewController viewDidSlideIn:animated inSlideMenuController:slideMenuController];
}


- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.topViewController viewWillSlideOut:animated inSlideMenuController:slideMenuController];
}


- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.topViewController viewDidSlideOut:animated inSlideMenuController:slideMenuController];
}

@end


#pragma mark UISplitViewController (NVSlideMenuControllerCallbacks)

@interface UISplitViewController (NVSlideMenuControllerCallbacks)
// Forward callbacks to the viewControllers
@end

@implementation UISplitViewController (NVSlideMenuControllerCallbacks)

- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewWillSlideIn:animated inSlideMenuController:slideMenuController];
	}];
}


- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewDidSlideIn:animated inSlideMenuController:slideMenuController];
	}];
}


- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewWillSlideOut:animated inSlideMenuController:slideMenuController];
	}];
}


- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewDidSlideOut:animated inSlideMenuController:slideMenuController];
	}];
}

@end


#pragma mark UITabBarController (NVSlideMenuControllerCallbacks)

@interface UITabBarController (NVSlideMenuControllerCallbacks)
// Forward callbacks to the selectedViewController
@end

@implementation UITabBarController (NVSlideMenuControllerCallbacks)

- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.selectedViewController viewWillSlideIn:animated inSlideMenuController:slideMenuController];
}


- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.selectedViewController viewDidSlideIn:animated inSlideMenuController:slideMenuController];
}


- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.selectedViewController viewWillSlideOut:animated inSlideMenuController:slideMenuController];
}


- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.selectedViewController viewDidSlideOut:animated inSlideMenuController:slideMenuController];
}

@end


#pragma mark UIPageViewController (NVSlideMenuControllerCallbacks)

@interface UIPageViewController (NVSlideMenuControllerCallbacks)
// Forward callbacks to the viewControllers
@end

@implementation UIPageViewController (NVSlideMenuControllerCallbacks)

- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewWillSlideIn:animated inSlideMenuController:slideMenuController];
	}];
}


- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewDidSlideIn:animated inSlideMenuController:slideMenuController];
	}];
}


- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewWillSlideOut:animated inSlideMenuController:slideMenuController];
	}];
}


- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController
{
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		[vc viewDidSlideOut:animated inSlideMenuController:slideMenuController];
	}];
}

@end
