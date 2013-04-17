//
//  PLFScrollViewController.h
//  CrossFade
//
//  Created by Dan Bretl on 4/16/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLFClipView.h"

@interface PLFScrollViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet PLFClipView * clipView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;

@property (nonatomic, strong) NSArray * contentViews;
@property (nonatomic, strong) UIView * contentViewsContainer;

@end
