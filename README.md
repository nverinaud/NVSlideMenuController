# NVSlideMenuController

A slide menu done right.

## Requirements

* No ARC (use `-fno-objc-arc` if your project uses ARC)
* iOS 5.0+ (since `UIViewController containment API` is used)

## Usage

* Drop `lib/NVSlideMenuController/NVSlideMenuController.{h|m}` in your project
* Add `QuartzCore.framework`
* (optional) set `-fno-objc-arc` to `NVSlideMenuController.m` if you use ARC

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
[self.slideMenuController setContentViewController:newContentViewController animated:YES completion:nil];
```

**Enable/Disable the pan gesture**

You could need to disable the pan gesture, for example when your content view controller has a table view with reorder control (see issue #2).

```objective-c
// For example when your view controller enter in editing mode
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];

	if (editing)
		self.slideMenuController.panGestureEnabled = NO;
}
```

For more have a look at the demo app :)

## What's next ?

* Support ARC using preprocessor macro
* Support Storyboard
* Add slide right-to-left feature
* Support CocoaPods

## Author

Nicolas VERINAUD ([@nverinaud](https://twitter.com/nverinaud))

## License

See `LICENSE.md`.
