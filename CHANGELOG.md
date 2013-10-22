# Changelog

## Release 1.5.6

* FIX: forward status bar style & appearance to child view controllers.

## Release 1.5.5

* FIX: fix the toggle of the content view.

## Release 1.5.4

* FIX: fix implementation of custom container view controller. (Thanks to [Gabriel Reis](https://github.com/greis))

## Release 1.5.3

* FIX: rotation issue introduced in 1.5.2 (sorry about that!)
* FIX: rotation issue on panning (issue #8)

## Release 1.5.2

* NEW: You can now enable/disable the shadow on the content view. (Thanks to [Gabriel Reis & Matt Polito from Hashrocket](https://github.com/hashrocketeer))
* NEW: add `menuWidth` property, it replaces `contentViewWidthWhenMenuIsOpen`
* DEPRECATION: `contentViewWidthWhenMenuIsOpen` is now deprecated

## Release 1.5.1

* FIX: fix initial bounds of content view controller in viewDidLoad.

## Release 1.5.0

* ENHANCEMENT: Remove the panGesture's requirement that the tapGesture fails. (Thanks to [David Berry](https://github.com/DavidBarry))
* NEW: You can now make the content view bounce when navigating. (Thanks to [David Berry](https://github.com/DavidBarry))

## Release 1.4.3

* FIX: issue [#5](https://github.com/nverinaud/NVSlideMenuController/issues/5) has been fixed.

## Release 1.4.2

* FIX: fix bridge cast warning when not using ARC.

## Release 1.4.1

* FIX: fix performance issue due to the shadow.

## Release 1.4.0

* NEW: You can now completly hide the content view and show it partially.
* DEPRECATED APIs:
	* `-setContentViewController:animated:completion:` replaced by  `-closeMenuBehindContentViewController:animated:completion:`
	* `-showContentViewControllerAnimated:completion:` replaced by `-closeMenuAnimated:completion:`
	* `-showMenuAnimated:completion:` replaced by `-openMenuAnimated:completion:`.

## Release 1.3.2

* NEW: add `contentViewWidthWhenMenuIsOpen` property.

## Release 1.3.1

* IMPORTANT FIX: the pan gesture now works fine.
* NEW: ARC is supported conditionaly.

## Release 1.3.0

* NEW: You can now change the slide direction (left -> right or right -> left).

## Release 1.2.0

* NEW: add `NVSlideMenuControllerCallbacks` category on `UIViewController`.
* NEW: default implementation of `NVSlideMenuControllerCallbacks` category has 
been added to View Controller Containers provided by Apple.

## Release 1.1.3

* NEW: add `panGestureEnabled` property.
* DEPRECATED: `panEnabledWhenSlideMenuIsHidden` property is now deprecated.
* FIX: issue [#2](https://github.com/nverinaud/NVSlideMenuController/issues/2) has been fixed.

## Release 1.1.2

* UPDATE: make `-[NVSlideMenuController isMenuOpen]` a public API.

## Release 1.1.1

* FIX: fix a typo in README for `no ARC compiler flag`.

## Release 1.0.2

* NEW: add a nice shadow on the content view controller's view.

## Release 1.0.1

* FIX: The menu state is now preserved when presenting a view controller modally.

## Release 1.0.0

* First release.
