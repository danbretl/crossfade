//
//  PLFAppDelegate.h
//  CrossFade
//
//  Created by Dan Bretl on 4/16/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLFScrollViewController;

@interface PLFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PLFScrollViewController *viewController;

@end
