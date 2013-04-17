//
//  PLFScrollViewController.h
//  CrossFade
//
//  Created by Dan Bretl on 4/16/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLFClipView.h"

@interface PLFScrollViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) float movementSuppressionFactor; // Defaults to 1.0. Forcibly kept >= 1.0. A factor of 1.0 will page content the full width of the screen. Factors greater than 1.0 will page content a fraction of that width.
@property (nonatomic) float alphaChangeBufferPercentage; // Defaults to 0.0. Forcibly kept 0 <= p < 0.5. (If an attempt is made to set a value >= 0.5, a value of 0.48 will be set.) The larger the value, the longer the delay before changing alpha (and thus the quicker the alpha change once the change has begun).

@property (nonatomic, weak) IBOutlet PLFClipView * clipView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollViewTouch;

@property (nonatomic, strong) NSArray * contentViews;
@property (nonatomic, strong) UIView * contentViewsContainer;

@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer * movementSuppressionFactorPanGestureRecognizer;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer * alphaChangeBufferPercentagePanGestureRecognizer;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * submitTapGestureRecognizer;

@property (nonatomic, weak) IBOutlet UIView * controlsContainer;
@property (nonatomic, weak) IBOutlet UILabel * movementSuppressionFactorLabel;
@property (nonatomic, weak) IBOutlet UILabel * alphaChangeBufferPercentageLabel;

@end
