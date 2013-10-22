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
#define BOUNCE_DURATION                 0.3f

@interface NVSlideMenuController ()
{
	CGFloat _contentViewWidthWhenMenuIsOpen;
}

/** Children view controllers */
@property (nonatomic, readwrite, strong) UIViewController *menuViewController;
@property (nonatomic, readwrite, strong) UIViewController *contentViewController;

/** Shadow */
- (void)setShadowOnContentView;
- (void)removeShadowOnContentView;
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

/** Utils */
- (CGFloat)contentViewMinX;
- (CGRect)menuViewFrameAccordingToCurrentSlideDirection;
- (UIViewAutoresizing)menuViewAutoresizingMaskAccordingToCurrentSlideDirection;


/** State */
@property (nonatomic, assign, getter = isContentViewHidden) BOOL contentViewHidden;

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
		_contentViewWidthWhenMenuIsOpen = -1;
		self.menuWidth = 276;
        self.autoAdjustMenuWidth = YES;
		self.showShadowOnContentView = YES;
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
        self.autoAdjustMenuWidth = YES;
		self.showShadowOnContentView = YES;
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
	}
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (_contentViewWidthWhenMenuIsOpen >= 0)
		self.menuWidth = CGRectGetWidth(self.view.bounds) - _contentViewWidthWhenMenuIsOpen;
	
	[self addChildViewController:self.contentViewController];
	self.contentViewController.view.frame = self.view.bounds;
	[self.view addSubview:self.contentViewController.view];
	[self.contentViewController didMoveToParentViewController:self];
	
	[self setShadowOnContentView];
	
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


- (UIStatusBarStyle)preferredStatusBarStyle
{
	UIViewController *vc = self.contentViewController;
	
	if ([self isMenuOpen])
		vc = self.menuViewController;
	
	return [vc preferredStatusBarStyle];
}


- (UIViewController *)childViewControllerForStatusBarStyle
{
	UIViewController *vc = self.contentViewController;
	
	if ([self isMenuOpen])
		vc = self.menuViewController;
	
	return vc;
}


- (UIViewController *)childViewControllerForStatusBarHidden
{
	UIViewController *vc = self.contentViewController;
	
	if ([self isMenuOpen])
		vc = self.menuViewController;
	
	return vc;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
	return	[self.menuViewController shouldAutorotate] &&
			[self.contentViewController shouldAutorotate] &&
			self.panGesture.state != UIGestureRecognizerStateChanged;
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
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if ([self isMenuOpen])
	{
		CGRect frame = self.contentViewController.view.frame;
		frame.origin.x = [self contentViewMinX];
		self.contentViewController.view.frame = frame;
		
		if (![self isContentViewHidden])
		{
			// Fix weird shadow behavior according to this post : http://blog.radi.ws/post/8348898129/calayers-shadowpath-and-uiview-autoresizing
			CALayer *layer = self.contentViewController.view.layer;
			CGPathRef oldShadowPath = layer.shadowPath;
			
			if (oldShadowPath)
				CFRetain(oldShadowPath);
			
			[self setShadowOnContentView];
			
			if (oldShadowPath)
			{
				CABasicAnimation *transition = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
#if !OBJC_ARC_ENABLED
				transition.fromValue = (id)oldShadowPath;
#else
				transition.fromValue = (__bridge id)oldShadowPath;
#endif

				transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
				transition.duration = duration;
				[layer addAnimation:transition forKey:@"transition"];
				
				CFRelease(oldShadowPath);
			}
		}
	}
}


#pragma mark - Shadow

- (void)setShowShadowOnContentView:(BOOL)showShadowOnContentView
{
	if (showShadowOnContentView != _showShadowOnContentView)
	{
		_showShadowOnContentView = showShadowOnContentView;
		
		if ([self.contentViewController isViewLoaded])
		{
			if (_showShadowOnContentView)
				[self setShadowOnContentView];
			else if (!_showShadowOnContentView)
				[self removeShadowOnContentView];
		}
	}
}


- (void)setShadowOnContentView
{
	if ([self showShadowOnContentView])
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
}


- (void)removeShadowOnContentView
{
	UIView *contentView = self.contentViewController.view;
	CALayer *layer = contentView.layer;
	layer.masksToBounds = YES;
}


- (CGSize)shadowOffsetAccordingToCurrentSlideDirection
{
	if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
		return CGSizeMake(-2.5f, 3.f);
	else if (self.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
		return CGSizeMake(2.5f, 3.f);
	
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
			self.menuViewController.view.autoresizingMask = [self menuViewAutoresizingMaskAccordingToCurrentSlideDirection];
			
			BOOL menuIsOpen = [self isMenuOpen];
			NSTimeInterval duration = (animated && menuIsOpen) ? ANIMATION_DURATION*1.5 : 0;
			CGRect targetedContentViewFrame = self.view.bounds;
			if (menuIsOpen)
				targetedContentViewFrame.origin.x = [self contentViewMinX];
						
			[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				
				self.menuViewController.view.frame = [self menuViewFrameAccordingToCurrentSlideDirection];
				self.contentViewController.view.frame = targetedContentViewFrame;
				
				if (![self isContentViewHidden])
					[self setShadowOnContentView];
				
			} completion:nil];
		}
	}
}


#pragma mark - Menu view lazy load

- (void)loadMenuViewControllerViewIfNeeded
{
	if (!self.menuViewController.view.window)
	{
		[self addChildViewController:self.menuViewController];
		self.menuViewController.view.frame = [self menuViewFrameAccordingToCurrentSlideDirection];
		self.menuViewController.view.autoresizingMask = [self menuViewAutoresizingMaskAccordingToCurrentSlideDirection];
		[self.view insertSubview:self.menuViewController.view atIndex:0];
		[self.menuViewController didMoveToParentViewController:self];
	}
}


#pragma mark - Navigation

- (IBAction)toggleMenuAnimated:(id)sender
{
	if ([self isMenuOpen])
		[self closeMenuAnimated:YES completion:nil];
	else
		[self openMenuAnimated:YES completion:nil];
}


- (void)openMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	NSTimeInterval duration = animated ? ANIMATION_DURATION : 0;
	
	UIView *contentView = self.contentViewController.view;
	CGRect contentViewFrame = contentView.frame;
	contentViewFrame.origin.x = [self contentViewMinX];
	
	[self loadMenuViewControllerViewIfNeeded];
	[self.menuViewController beginAppearanceTransition:YES animated:animated];
	[self.contentViewController viewWillSlideOut:animated inSlideMenuController:self];
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		contentView.frame = contentViewFrame;
		[self setShadowOnContentView];
		self.menuViewController.view.frame = [self menuViewFrameAccordingToCurrentSlideDirection];
	} completion:^(BOOL finished) {
		[self.menuViewController endAppearanceTransition];
		
		if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
			[self setNeedsStatusBarAppearanceUpdate];
		
		[self.contentViewController viewDidSlideOut:animated inSlideMenuController:self];
		
		self.tapGesture.enabled = YES;
		
		if (completion)
			completion(finished);
	}];
}


- (void)closeMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
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
		
		if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
			[self setNeedsStatusBarAppearanceUpdate];
		
		[self.contentViewController viewDidSlideIn:animated inSlideMenuController:self];
		self.contentViewHidden = NO;
		
		self.menuViewController.view.userInteractionEnabled = YES;
		
		if (completion)
			completion(finished);
	}];
}


- (void)closeMenuBehindContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{	
	[self closeMenuBehindContentViewController:contentViewController animated:animated bounce:self.bounceWhenNavigating completion:completion];
}


- (void)closeMenuBehindContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated bounce:(BOOL)bounce completion:(void(^)(BOOL finished))completion {
    NSAssert(contentViewController != nil, @"Can't show a nil content view controller.");
    
	void (^swapContentViewController)() = nil;
    
	if (contentViewController != self.contentViewController)
	{
        swapContentViewController = ^{
            // Preserve the frame
            CGRect frame = self.contentViewController.view.frame;
            
            // Remove old content view
            [self.contentViewController.view removeGestureRecognizer:self.tapGesture];
            [self.contentViewController.view removeGestureRecognizer:self.panGesture];
            
            BOOL contentViewWasAlreadyHidden = [self isContentViewHidden];
            if (!contentViewWasAlreadyHidden)
                [self.contentViewController beginAppearanceTransition:NO animated:NO];

            [self.contentViewController willMoveToParentViewController:nil];
            [self.contentViewController.view removeFromSuperview];
            [self.contentViewController removeFromParentViewController];

            if (!contentViewWasAlreadyHidden)
                [self.contentViewController endAppearanceTransition];
            
            // Add the new content view
            self.contentViewController = contentViewController;
            self.contentViewController.view.frame = frame;
            [self.contentViewController.view addGestureRecognizer:self.tapGesture];
            [self.contentViewController.view addGestureRecognizer:self.panGesture];
            [self setShadowOnContentView];
            [self.contentViewController beginAppearanceTransition:YES animated:NO];
            [self addChildViewController:self.contentViewController];
            [self.view addSubview:self.contentViewController.view];
            [self.contentViewController didMoveToParentViewController:self];
            [self.contentViewController endAppearanceTransition];
        };
	}
	
    if (bounce && animated && ![self isContentViewHidden])
	{
        CGFloat offScreenDistance = 10.0f;
        CGFloat bounceDistance = offScreenDistance + CGRectGetWidth(self.contentViewController.view.bounds) - self.menuWidth;
		
        //Invert the bounce distance if needed for the slide direction
        if (self.slideDirection == NVSlideMenuControllerSlideFromRightToLeft)
			bounceDistance *= -1;
        
        UIView *contentView = self.contentViewController.view;
        CGRect contentBounceFrame = contentView.frame;
        contentBounceFrame.origin.x += bounceDistance;
        
        [UIView animateWithDuration:BOUNCE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            contentView.frame = contentBounceFrame;
        } completion:^(BOOL finished) {
            if (swapContentViewController)
				swapContentViewController();
			
            [self closeMenuAnimated:animated completion:completion];
        }];
        
    }
	else
	{
        if (swapContentViewController)
			swapContentViewController();
		
        // Perform the close animation
        [self closeMenuAnimated:animated completion:completion];
    }
}


- (void)hideContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	if (![self isContentViewHidden])
	{
		NSTimeInterval duration = animated ? ANIMATION_DURATION/2 : 0;
		BOOL menuIsOpen = [self isMenuOpen];
		UIView *contentView = self.contentViewController.view;
		CGRect contentViewFrame = contentView.frame;
		
		self.contentViewHidden = YES;
		contentViewFrame.origin.x = [self contentViewMinX];
		
		if (!menuIsOpen)
			[self.menuViewController beginAppearanceTransition:YES animated:animated];
		
		[self.contentViewController beginAppearanceTransition:NO animated:animated];
		
		[UIView animateWithDuration:duration animations:^{
			contentView.frame = contentViewFrame;
			[self removeShadowOnContentView];
			self.menuViewController.view.frame = self.view.bounds;
		} completion:^(BOOL finished) {
			if (!menuIsOpen)
				[self.menuViewController endAppearanceTransition];
			
			[self.contentViewController endAppearanceTransition];
			
			if (completion)
				completion(finished);
		}];
	}
}


- (void)partiallyShowContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	if ([self isContentViewHidden])
	{
		NSTimeInterval duration = animated ? ANIMATION_DURATION/2 : 0;
		UIView *contentView = self.contentViewController.view;
		CGRect contentViewFrame = contentView.frame;
		
		self.contentViewHidden = NO;
		contentViewFrame.origin.x = [self contentViewMinX];
		
		[self.contentViewController beginAppearanceTransition:YES animated:animated];
		
		[UIView animateWithDuration:duration animations:^{
			contentView.frame = contentViewFrame;
			[self setShadowOnContentView];
			self.menuViewController.view.frame = [self menuViewFrameAccordingToCurrentSlideDirection];
		} completion:^(BOOL finished) {
			[self.contentViewController endAppearanceTransition];
			
			if (completion)
				completion(finished);
		}];
	}
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
		[self closeMenuAnimated:YES completion:nil];
}


- (UIPanGestureRecognizer *)panGesture
{
	if (!_panGesture)
		_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureTriggered:)];
	
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
    CGFloat contentViewMinX = [self contentViewMinX];
    
    if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
	{
        frame.origin.x += translation.x;
        
        if (frame.origin.x > contentViewMinX)
            frame.origin.x = contentViewMinX;
        else if (frame.origin.x < 0)
            frame.origin.x = 0;
    }
	else
	{
		frame.origin.x += translation.x;
        
        if (frame.origin.x < contentViewMinX)
            frame.origin.x = contentViewMinX;
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
				
				if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
					[self setNeedsStatusBarAppearanceUpdate];
				
				[self.contentViewController viewDidSlideIn:YES inSlideMenuController:self];
			}];
		}
		else // Open
		{
			distance = fabsf(contentViewMinX - frame.origin.x);
			animationDuration = fabs(distance / velocity.x);
			if (animationDuration > ANIMATION_DURATION)
				animationDuration = ANIMATION_DURATION;
			
			frame.origin.x = contentViewMinX;
			
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
				
				if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
					[self setNeedsStatusBarAppearanceUpdate];
				
				[self.contentViewController viewDidSlideOut:YES inSlideMenuController:self];
			}];
		}
		
		self.contentViewControllerFrame = frame;
	}
}


#pragma mark - Menu State

- (BOOL)isMenuOpen
{
	if ([self.contentViewController isViewLoaded])
		return self.contentViewController.view.frame.origin.x != 0;
	
	return NO;
}


#pragma mark - Utils

- (CGFloat)contentViewMinX
{
	CGFloat minX = 0;
	
	if ([self isContentViewHidden])
	{
		if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
			minX = CGRectGetWidth(self.view.bounds);
		else
			minX = -CGRectGetWidth(self.view.bounds);
	}
	else
	{
		if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
			minX = self.menuWidth;
		else
			minX = -self.menuWidth;
	}
	
	return minX;
}


- (CGRect)menuViewFrameAccordingToCurrentSlideDirection
{
	CGRect menuFrame = self.view.bounds;
	
	if (self.autoAdjustMenuWidth && ![self isContentViewHidden])
		menuFrame.size.width = self.menuWidth;
	
	if (self.autoAdjustMenuWidth && self.slideDirection == NVSlideMenuControllerSlideFromRightToLeft && ![self isContentViewHidden])
		menuFrame.origin.x = CGRectGetWidth(self.view.bounds) - self.menuWidth;
	
	return menuFrame;
}


- (UIViewAutoresizing)menuViewAutoresizingMaskAccordingToCurrentSlideDirection
{
	UIViewAutoresizing resizingMask = UIViewAutoresizingFlexibleHeight;
	
	if (self.slideDirection == NVSlideMenuControllerSlideFromLeftToRight)
		resizingMask = resizingMask | UIViewAutoresizingFlexibleRightMargin;
	else
		resizingMask = resizingMask | UIViewAutoresizingFlexibleLeftMargin;
	
	return resizingMask;
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
#pragma mark - NVSlideMenuController (Deprecated)

@implementation NVSlideMenuController (Deprecated)

- (void)setContentViewWidthWhenMenuIsOpen:(CGFloat)contentViewWidthWhenMenuIsOpen
{
	if (contentViewWidthWhenMenuIsOpen != _contentViewWidthWhenMenuIsOpen)
	{
		_contentViewWidthWhenMenuIsOpen = contentViewWidthWhenMenuIsOpen;
		if ([self isViewLoaded])
			self.menuWidth = CGRectGetWidth(self.view.bounds) - _contentViewWidthWhenMenuIsOpen;
	}
}


- (CGFloat)contentViewWidthWhenMenuIsOpen
{
	return _contentViewWidthWhenMenuIsOpen;
}


- (void)setPanEnabledWhenSlideMenuIsHidden:(BOOL)panEnabledWhenSlideMenuIsHidden
{
	self.panGestureEnabled = panEnabledWhenSlideMenuIsHidden;
}


- (BOOL)panEnabledWhenSlideMenuIsHidden
{
	return self.panGestureEnabled;
}


- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	[self closeMenuBehindContentViewController:contentViewController animated:animated completion:completion];
}


- (void)showContentViewControllerAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	[self closeMenuAnimated:animated completion:completion];
}


- (void)showMenuAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	[self openMenuAnimated:animated completion:completion];
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
