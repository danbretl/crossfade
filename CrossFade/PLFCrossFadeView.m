//
//  PLFCrossFadeView.m
//  CrossFade
//
//  Created by Dan Bretl on 4/18/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import "PLFCrossFadeView.h"

const float kBackgroundMovementSuppressionDefault = 1.0;
const float kBackgroundAlphaChangeDelayDefault = 0.0;

#define kMovementSuppressionFactorDefault 3.0
#define kAlphaChangeBufferPercentageDefault 0.0

@interface PLFCrossFadeView()
- (void)setup;
@property (nonatomic, strong) UIScrollView * backgroundScrollView;
@property (nonatomic, strong) UIScrollView * foregroundScrollView;
@property (nonatomic, strong) UIPageControl * pageControl;
@property (nonatomic, strong) NSMutableArray * backgroundContentViews;
@property (nonatomic, strong) UIView * backgroundContentViewsContainer;
@property (nonatomic, strong) NSMutableArray * foregroundContentViews;
@property (nonatomic, strong) UIView * foregroundContentViewsContainer;
@property (nonatomic, readonly) CGFloat backgroundContentViewsSpacing;
@property (nonatomic, strong) NSTimer * autoPagingTimer;
- (void) autoPagingTimerFired:(NSTimer *)timer;
@end

@implementation PLFCrossFadeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundMovementSuppression = kMovementSuppressionFactorDefault;
    self.backgroundAlphaChangeDelay = kAlphaChangeBufferPercentageDefault;
    self.backgroundContentViews = [NSMutableArray array];
    self.foregroundContentViews = [NSMutableArray array];
    
    self.backgroundScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.backgroundScrollView.delegate = self;
    self.backgroundScrollView.pagingEnabled = YES;
    self.backgroundScrollView.clipsToBounds = NO;
    self.backgroundScrollView.showsHorizontalScrollIndicator = NO;
    self.backgroundScrollView.showsVerticalScrollIndicator = NO;
    self.backgroundScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundScrollView];
    
    self.foregroundScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.foregroundScrollView.delegate = self;
    self.foregroundScrollView.pagingEnabled = YES;
    self.foregroundScrollView.showsHorizontalScrollIndicator = NO;
    self.foregroundScrollView.showsVerticalScrollIndicator = NO;
    self.foregroundScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.foregroundScrollView];
    
    self.backgroundContentViewsContainer = [[UIView alloc] initWithFrame:self.backgroundScrollView.bounds];
    [self.backgroundScrollView addSubview:self.backgroundContentViewsContainer];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:self.bounds];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.pageControl];
    self.pageControl.hidden = YES;
    self.pageControl.userInteractionEnabled = NO;
    
    self.foregroundContentViewsContainer = [[UIView alloc] initWithFrame:self.foregroundScrollView.bounds];
    [self.foregroundScrollView addSubview:self.foregroundContentViewsContainer];
    
    [self setNeedsLayout];
    
    self.foregroundScrollView.contentOffset = CGPointZero;

}

- (void)layoutSubviews {
    
    NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    self.backgroundScrollView.frame = CGRectMake((self.bounds.size.width - self.backgroundContentViewsSpacing) / 2.0, 0, self.backgroundContentViewsSpacing, self.bounds.size.height);
    self.foregroundScrollView.frame = self.bounds;
        
    UIView * lastBackgroundContentView = nil;
    UIView * lastForegroundContentView = nil;
    for (int i=0; i<self.contentViewsCount; i++) {
        // Background
        UIView * backgroundContentView = self.backgroundContentViews[i];
        backgroundContentView.frame = CGRectMake(self.backgroundContentViewsSpacing * i, 0, self.bounds.size.width + self.backgroundContentViewsSpacing * 2.0, self.backgroundScrollView.bounds.size.height);
        // Foreground
        UIView * foregroundContentView = self.foregroundContentViews[i];
        foregroundContentView.frame = CGRectMake(self.foregroundScrollView.bounds.size.width * i, 0, self.foregroundScrollView.bounds.size.width, self.foregroundScrollView.bounds.size.height);
        if (i + 1 >= self.contentViewsCount) {
            lastBackgroundContentView = backgroundContentView;
            lastForegroundContentView = foregroundContentView;
        }
    }
    
    self.backgroundContentViewsContainer.frame = CGRectMake(-(self.backgroundScrollView.frame.origin.x + self.backgroundScrollView.frame.size.width), 0, CGRectGetMaxX(lastBackgroundContentView.frame), self.backgroundScrollView.bounds.size.height);
    self.foregroundContentViewsContainer.frame = CGRectMake(0, 0, CGRectGetMaxX(lastForegroundContentView.frame), self.foregroundScrollView.bounds.size.height);
    
    self.backgroundScrollView.contentSize = CGSizeMake(self.backgroundContentViewsSpacing * self.backgroundContentViews.count, self.backgroundContentViewsContainer.frame.size.height);
    self.foregroundScrollView.contentSize = CGSizeMake(self.foregroundContentViewsContainer.frame.size.width, self.foregroundScrollView.bounds.size.height);
    
//    self.backgroundScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -self.backgroundScrollView.frame.origin.x, 0, -(self.bounds.size.width - CGRectGetMaxX(self.backgroundScrollView.frame)));
    
}

- (CGFloat)backgroundContentViewsSpacing {
    return self.foregroundScrollView.bounds.size.width / self.backgroundMovementSuppression;
}

- (void)setStaticView:(UIView *)staticView {
    if (_staticView != staticView) {
        _staticView = staticView;
        self.staticView.frame = self.bounds;
        self.staticView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.staticView aboveSubview:self.backgroundScrollView];
    }
}

- (void)addBackgroundContentView:(UIView *)backgroundContentView foregroundContentView:(UIView *)foregroundContentView {
    [self.backgroundContentViews addObject:backgroundContentView];
    [self.foregroundContentViews addObject:foregroundContentView];
    [self.backgroundContentViewsContainer addSubview:backgroundContentView];
    [self.foregroundContentViewsContainer addSubview:foregroundContentView];
    [self.backgroundContentViewsContainer sendSubviewToBack:backgroundContentView];
    [self.foregroundContentViewsContainer sendSubviewToBack:backgroundContentView];
    self.pageControl.numberOfPages = self.contentViewsCount;
    [self setNeedsLayout];
}

- (void)removeAllContentViews {
    for (UIView * foregroundContentView in self.foregroundContentViews) {
        [foregroundContentView removeFromSuperview];
    }
    [self.foregroundContentViews removeAllObjects];
    for (UIView * backgroundContentView in self.backgroundContentViews) {
        [backgroundContentView removeFromSuperview];
    }
    [self.backgroundContentViews removeAllObjects];
    [self setNeedsLayout];
}

- (NSUInteger)contentViewsCount {
    return MIN(self.backgroundContentViews.count, self.foregroundContentViews.count);
}

- (void)setBackgroundMovementSuppression:(float)backgroundMovementSuppression {
    backgroundMovementSuppression = MAX(1.0, backgroundMovementSuppression);
    if (_backgroundMovementSuppression != backgroundMovementSuppression) {
        int currentIndex = roundf(self.foregroundScrollView.contentOffset.x / self.foregroundScrollView.bounds.size.width);
        currentIndex = MIN(self.foregroundContentViews.count - 1, MAX(0, currentIndex));
        _backgroundMovementSuppression = backgroundMovementSuppression;
        [self setNeedsLayout];
        [self layoutIfNeeded];
        self.foregroundScrollView.contentOffset = CGPointZero; // Not sure why this was necessary.
        self.foregroundScrollView.contentOffset = CGPointMake(currentIndex * self.foregroundScrollView.bounds.size.width, self.foregroundScrollView.contentOffset.y);
    }
}

#pragma mark Autopaging

- (void)startAutoPaging {
    [self.autoPagingTimer invalidate];
    self.autoPagingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(autoPagingTimerFired:) userInfo:nil repeats:YES];
}

- (void)stopAutoPaging {
    [self.autoPagingTimer invalidate];
    self.autoPagingTimer = nil;
}

- (void)autoPagingTimerFired:(NSTimer *)timer {
    
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.foregroundScrollView) {
        self.backgroundScrollView.contentOffset = CGPointMake(self.foregroundScrollView.contentOffset.x / self.backgroundMovementSuppression, self.foregroundScrollView.contentOffset.y);
        int currentPage = MIN(self.contentViewsCount, MAX(0, roundf(self.foregroundScrollView.contentOffset.x / self.foregroundScrollView.bounds.size.width)));
        self.pageControl.currentPage = currentPage;
    } else if (scrollView == self.backgroundScrollView) {
        CGFloat contentOffsetCenterX = self.backgroundScrollView.contentOffset.x + self.backgroundContentViewsSpacing / 2.0 - self.backgroundContentViewsContainer.frame.origin.x;
        CGFloat distanceFromCenter = 0;
        for (UIView * contentView in self.backgroundContentViews) {
            CGFloat alphaChangeSpanDistance = self.backgroundContentViewsSpacing;
            CGFloat alphaChangeSpanStart = contentView.center.x + alphaChangeSpanDistance * self.backgroundAlphaChangeDelay;
            CGFloat alphaChangeSpanFinish = contentView.center.x + self.backgroundContentViewsSpacing - alphaChangeSpanDistance * self.backgroundAlphaChangeDelay;
            alphaChangeSpanDistance = alphaChangeSpanFinish - alphaChangeSpanStart;
            distanceFromCenter = contentOffsetCenterX - alphaChangeSpanStart;
            distanceFromCenter = MIN(MAX(0, distanceFromCenter), alphaChangeSpanDistance);
            if (contentView == self.backgroundContentViews.lastObject)
                distanceFromCenter = 0;
            contentView.alpha = 1.0 - (distanceFromCenter / alphaChangeSpanDistance);
        }
    }
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView * view = nil;
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        view = [self.delegate viewForZoomingInScrollView:scrollView];
    }
    return view;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [self delegatePerformSelectorIfResponds:_cmd];
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    BOOL shouldScrollToTop = YES;
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        shouldScrollToTop = [self.delegate scrollViewShouldScrollToTop:scrollView];
    }
    return shouldScrollToTop;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self delegatePerformSelectorIfResponds:_cmd];
}

- (void)delegatePerformSelectorIfResponds:(SEL)selector {
    if (self.delegate && [self.delegate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:selector];
#pragma clang diagnostic pop
    }
}

@end
