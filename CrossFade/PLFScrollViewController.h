//
//  PLFScrollViewController.h
//  CrossFade
//
//  Created by Dan Bretl on 4/16/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLFCrossFadeView.h"

@interface PLFScrollViewController : UIViewController <UIGestureRecognizerDelegate, PLFCrossFadeViewDelegate>

@property (nonatomic, weak) IBOutlet PLFCrossFadeView * crossFadeView;

@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer * movementSuppressionFactorPanGestureRecognizer;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer * alphaChangeBufferPercentagePanGestureRecognizer;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * submitTapGestureRecognizer;

@property (nonatomic, weak) IBOutlet UIView * controlsContainer;
@property (nonatomic, weak) IBOutlet UILabel * movementSuppressionFactorLabel;
@property (nonatomic, weak) IBOutlet UILabel * alphaChangeBufferPercentageLabel;

@end
