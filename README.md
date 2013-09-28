# NVSlideMenuController

A slide menu done right.

## Requirements

* You can use ARC or not, this library supports both
* iOS 5.0+ (because `UIViewController containment API` is used)

## Usage

* Drop `lib/NVSlideMenuController/NVSlideMenuController.{h|m}` in your project
* Add `QuartzCore.framework`

**Create a slide menu**

```objective-c
UIViewController *menuViewController = ... ; // Your menu view controller
UIViewController *contentViewController = ... ; // The initial content view controller (home page ?)

NVSlideMenuController *slideMenuController = [[NVSlideMenuController alloc] initWithMenuViewController:menuViewController andContentViewController:contentViewController];

self.window.rootViewController = slideMenuController; // Assuming you are in app delegate did finish launching
```

**Change & show new content from the menu**

```objective-c
// Inside your menuViewController
UIViewController *newContentViewController = ... ; // Create & configure your new content view controller (as usual)
[self.slideMenuController closeMenuBehindContentViewController:newContentViewController animated:YES completion:nil];
```

**NVSlideMenuController callbacks**

The library provides 4 methods through a UIViewController category. 
You can override them to manage the slide in/out of the content view controller. It is best described by the provided demo app.

```objective-c
@interface UIViewController (NVSlideMenuControllerCallbacks)

- (void)viewWillSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController;
- (void)viewDidSlideIn:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController;
- (void)viewWillSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController;
- (void)viewDidSlideOut:(BOOL)animated inSlideMenuController:(NVSlideMenuController *)slideMenuController;

@end
```

**Change the slide direction**

You can specify the slide direction by setting the `slideDirection` property to `NVSlideMenuControllerSlideFromLeftToRight`
or `NVSlideMenuControllerSlideFromRightToLeft`. The views will update accordingly if needed (look at the demo app for a taste).
You can also animate the change.

```objective-c
// Inside your view controller (menu or content)
[self.slideMenuController setSlideDirection:NVSlideMenuControllerSlideFromRightToLeft animated:YES];
// or more simply...
self.slideMenuController.slideDirection = NVSlideMenuControllerSlideFromRightToLeft; // this one will not animate
```

**Enable/Disable the pan gesture**

You could need to disable the pan gesture, for example when your content view controller has a table view with reorder control (see issue [#2](https://github.com/nverinaud/NVSlideMenuController/issues/2)).

```objective-c
// For example when your view controller enter in editing mode
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];

	if (editing)
		self.slideMenuController.panGestureEnabled = NO;
}
```

For more have a look at the demo app `;-]`

## What's next ?

- Enhance UX and UI for iOS 7

## Author

Nicolas VERINAUD ([@nverinaud](https://twitter.com/nverinaud))

## License

Released under the MIT License. For more see `LICENSE.md`.
