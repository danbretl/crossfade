//
//  PLFScrollViewController.m
//  CrossFade
//
//  Created by Dan Bretl on 4/16/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import "PLFScrollViewController.h"

#define kSpacing 300.0
#define kSpacingAlphaBuffer 50.0

#define DEBUGGING_SCROLL_VIEW_CONTROLLER NO

@interface PLFScrollViewController ()
@property (nonatomic) NSArray * imageFilenames;
@end

@implementation PLFScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imageFilenames = @[@"test1.jpg", @"test2.jpg", @"test3.jpg", @"test4.jpg", @"test5.jpg", @"test6.jpg", @"test7.jpg", @"test8.jpg", @"test9.jpg", @"test10.jpg", @"test11.jpg", @"img0.jpg", @"img1.jpg", @"img2.jpg", @"img3.jpg"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentViewsContainer = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    [self.scrollView addSubview:self.contentViewsContainer];
    
    self.clipView.scrollView = self.scrollView;
    if (self.contentViews.count == 0) {
        NSMutableArray * contentViews = [NSMutableArray array];
        for (NSString * imageFilename in self.imageFilenames) {
            UIImageView * contentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFilename]];
            contentView.contentMode = UIViewContentModeScaleAspectFill;
            [self.contentViewsContainer addSubview:contentView];
            [self.contentViewsContainer sendSubviewToBack:contentView];
            [contentViews addObject:contentView];
        }
        self.contentViews = contentViews;
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    self.scrollView.showsHorizontalScrollIndicator = DEBUGGING_SCROLL_VIEW_CONTROLLER;
    self.scrollView.showsVerticalScrollIndicator = DEBUGGING_SCROLL_VIEW_CONTROLLER;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.frame = CGRectMake((self.view.bounds.size.width - kSpacing) / 2.0, 0, kSpacing, self.view.bounds.size.height);
    
    for (int i=0; i<self.contentViews.count; i++) {
        UIView * contentView = self.contentViews[i];
        contentView.frame = CGRectMake(kSpacingAlphaBuffer + kSpacing * i, 0, self.view.bounds.size.width + (kSpacing - kSpacingAlphaBuffer) * 2.0, self.scrollView.bounds.size.height);
        NSLog(@"contentView(%d).frame = %@", i, NSStringFromCGRect(contentView.frame));
    }
    
    self.contentViewsContainer.frame = CGRectMake(-(self.scrollView.frame.origin.x + self.scrollView.frame.size.width), 0, CGRectGetMaxX(((UIView *)self.contentViews.lastObject).frame) + kSpacingAlphaBuffer, self.scrollView.bounds.size.height);
    
    self.scrollView.contentSize = CGSizeMake(kSpacing * self.contentViews.count, self.contentViewsContainer.frame.size.height);
    NSLog(@"%@ self.scrollView.contentSize = %@", NSStringFromSelector(_cmd), NSStringFromCGSize(self.scrollView.contentSize));
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -self.scrollView.frame.origin.x, 0, -(self.view.bounds.size.width - CGRectGetMaxX(self.scrollView.frame)));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat contentOffsetX = self.scrollView.contentOffset.x;
        CGFloat scrollViewWidth = kSpacing;
        CGFloat contentOffsetCenterX = contentOffsetX + scrollViewWidth / 2.0 - self.contentViewsContainer.frame.origin.x;
//        NSLog(@"coc.x = %f", contentOffsetCenterX);
        CGFloat d = 0;
        for (UIView * contentView in self.contentViews) {
            CGFloat cxFull = contentView.center.x + kSpacingAlphaBuffer;
            CGFloat cxZero = contentView.center.x + kSpacing - kSpacingAlphaBuffer;
            CGFloat cxd = cxZero - cxFull;
            d = contentOffsetCenterX - cxFull;
            d = MAX(0, d);
            d = MIN(d, cxd);
            if (contentView == self.contentViews.lastObject)
                d = 0;
            CGFloat a = 1.0 - (d / cxd);
//            NSLog(@"  cv%d", [self.contentViews indexOfObject:contentView]);
//            NSLog(@"    cxF = %f / cxZ = %f / cxd = %f", cxFull, cxZero, cxd);
//            NSLog(@"    d = %f / a = %f", d, a);
            contentView.alpha = a;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), NSStringFromCGPoint(self.scrollView.contentOffset));
    }
}

@end
