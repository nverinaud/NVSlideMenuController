//
//  DetailsViewController.h
//  BasicDemo
//
//  Created by Nicolas Verinaud on 31/12/12.
//  Copyright (c) 2012 Nicolas Verinaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController

@property (nonatomic, strong) id detailedObject;

@property (nonatomic, copy) void(^onShowMenuButtonClicked)(void);
- (void)setOnShowMenuButtonClicked:(void (^)(void))onShowMenuButtonClicked;

@end
