//
//  PLFCrossFadeView.h
//  CrossFade
//
//  Created by Dan Bretl on 4/18/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLFCrossFadeViewDelegate;

@interface PLFCrossFadeView : UIView <UIScrollViewDelegate>

@property (nonatomic) float backgroundMovementSuppression; // Defaults to 1.0. Forcibly kept >= 1.0. A factor of 1.0 will page content the full width of the screen. Factors greater than 1.0 will page content a fraction of that width.
@property (nonatomic) float backgroundAlphaChangeDelay; // Defaults to 0.0. Forcibly kept 0 <= p < 0.5. (If an attempt is made to set a value >= 0.5, a value of 0.48 will be set.) The larger the value, the longer the delay before changing alpha (and thus the quicker the alpha change once the change has begun).

@property (nonatomic, readonly) UIScrollView * backgroundScrollView;
@property (nonatomic) UIView * staticView; // Does not scroll. By default, positioned in between background and foreground content. Frame will be set to this views bounds.
@property (nonatomic, readonly) UIScrollView * foregroundScrollView;

- (void)addBackgroundContentView:(UIView *)backgroundContentView foregroundContentView:(UIView *)foregroundContentView;
- (void)removeAllContentViews;
@property (nonatomic, readonly) NSUInteger contentViewsCount;

@property (nonatomic, readonly) UIPageControl * pageControl; // Hidden by default. If made visible, should also position it as desired. userInteractionEnabled = NO by default as well.

- (void)startAutoPaging;
- (void)stopAutoPaging;

@property (nonatomic, weak) id<PLFCrossFadeViewDelegate> delegate;

@end

@protocol PLFCrossFadeViewDelegate <NSObject, UIScrollViewDelegate>
// Forward UIScrollViewDelegate callbacks
@end
