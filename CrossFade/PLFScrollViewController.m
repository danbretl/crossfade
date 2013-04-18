//
//  PLFScrollViewController.m
//  CrossFade
//
//  Created by Dan Bretl on 4/16/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import "PLFScrollViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define DEBUGGING_SCROLL_VIEW_CONTROLLER NO

#define kMovementSuppressionFactorDefault 3.0
#define kAlphaChangeBufferPercentageDefault 0.0


@interface PLFScrollViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic) NSArray * imageFilenames; // Image filename strings
@property (nonatomic) NSArray * imageHeadlines; // Headline text strings
@property (nonatomic) NSArray * imageDescriptions; // Description text strings
@property (nonatomic, readonly) CGFloat contentViewsSpacingValue;
- (void)setControlLabelsTextToDataValues;
- (IBAction)controlPanGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (IBAction)controlSubmitGesture:(UITapGestureRecognizer *)gestureRecognizer;
@property (nonatomic) CGPoint movementSuppressionFactorPanAnchorPoint;
@property (nonatomic) CGPoint alphaChangeBufferPercentagePanAnchorPoint;
@property (nonatomic) float movementSuppressionFactorPanAnchorValue;
@property (nonatomic) float alphaChangeBufferPercentagePanAnchorValue;
- (float) getControlValueForGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void) setControlValue:(float)controlValue forGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (CGPoint) getAnchorPointForGestureRecgonizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void) setAnchorPoint:(CGPoint)anchorPoint forGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (float) getAnchorValueForGestureRecgonizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void) setAnchorValue:(float)anchorValue forGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)setControlLabelsVisible:(BOOL)visible animated:(BOOL)animated;
- (void)setControlLabelsVisibleBlinkAnimatedToStart:(BOOL)animatedToStart; // Finish is always animated
@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) BOOL controlsTouched;
@end

@implementation PLFScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.movementSuppressionFactor = kMovementSuppressionFactorDefault;
        self.alphaChangeBufferPercentage = kAlphaChangeBufferPercentageDefault;
        self.imageFilenames = @[@"test1.jpg", @"test2.jpg", @"test3.jpg", @"test4.jpg", @"test5.jpg", @"test6.jpg", @"test7.jpg", @"test8.jpg", @"test9.jpg", @"test10.jpg", @"test11.jpg"];
        self.imageHeadlines = @[@"Store all your pictures", @"Automatically sync", @"Access anywhere", @"Send pictures easily"];
        self.imageDescriptions = @[@"All backed up in one place", @"Never worry about losing pictures", @"View and organize on any device", @"Any picture can be sent instantly"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.overlayImageView.image = [[UIImage imageNamed:@"overlay_sans_page_text"] resizableImageWithCapInsets:UIEdgeInsetsMake(200.0, 0, 200.0, 0)];
    
    self.controlsContainer.alpha = 0.0;
    [self setControlLabelsTextToDataValues];
        
    self.backgroundContentViewsContainer = [[UIView alloc] initWithFrame:self.scrollViewBackground.bounds];
    [self.scrollViewBackground addSubview:self.backgroundContentViewsContainer];
    
    self.foregroundContentViewsContainer = [[UIView alloc] initWithFrame:self.scrollViewForeground.bounds];
    [self.scrollViewForeground addSubview:self.foregroundContentViewsContainer];
    
    self.clipView.scrollView = self.scrollViewBackground;
    if (self.backgroundContentViews.count == 0) {
        NSMutableArray * backgroundContentViews = [NSMutableArray array];
        NSMutableArray * foregroundContentViews = [NSMutableArray array];
        for (int i=0; i<self.imageFilenames.count; i++) {
            NSString * imageFilename = self.imageFilenames[i];
            
            UIImageView * contentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFilename]];
            contentView.contentMode = UIViewContentModeScaleAspectFill;
            [self.backgroundContentViewsContainer addSubview:contentView];
            [self.backgroundContentViewsContainer sendSubviewToBack:contentView];
            [backgroundContentViews addObject:contentView];
            
            UIView * contentViewForeground = [[UIView alloc] initWithFrame:CGRectOffset(self.scrollViewForeground.bounds, [self.imageFilenames indexOfObject:imageFilename] * self.scrollViewForeground.bounds.size.width, 0)];
            [self.foregroundContentViewsContainer addSubview:contentViewForeground];
            [foregroundContentViews addObject:contentViewForeground];
            
            UILabel * contentViewHeadlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, contentViewForeground.bounds.size.height - 160.0, contentViewForeground.bounds.size.width - 25.0 * 2, 28.0)];
            contentViewHeadlineLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            contentViewHeadlineLabel.textColor = [UIColor whiteColor];
            contentViewHeadlineLabel.font = [UIFont boldSystemFontOfSize:20.0];
            contentViewHeadlineLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            contentViewHeadlineLabel.shadowOffset = CGSizeMake(0, 1.0);
            contentViewHeadlineLabel.textAlignment = NSTextAlignmentCenter;
            contentViewHeadlineLabel.text = self.imageHeadlines[i % self.imageHeadlines.count];
            UILabel * contentViewDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, CGRectGetMaxY(contentViewHeadlineLabel.frame), contentViewForeground.bounds.size.width - 25.0 * 2, 28.0)];
            contentViewDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            contentViewDescriptionLabel.textColor = [UIColor whiteColor];
            contentViewDescriptionLabel.font = [UIFont systemFontOfSize:16.0];
            contentViewDescriptionLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            contentViewDescriptionLabel.shadowOffset = CGSizeMake(0, 1.0);
            contentViewDescriptionLabel.textAlignment = NSTextAlignmentCenter;
            contentViewDescriptionLabel.numberOfLines = 2;
            contentViewDescriptionLabel.text = self.imageDescriptions[i % self.imageDescriptions.count];
            if (DEBUGGING_SCROLL_VIEW_CONTROLLER) {
                contentViewHeadlineLabel.backgroundColor = [UIColor redColor];
                contentViewDescriptionLabel.backgroundColor = [UIColor yellowColor];
            } else {
                contentViewHeadlineLabel.backgroundColor = [UIColor clearColor];
                contentViewDescriptionLabel.backgroundColor = [UIColor clearColor];
            }
            
            [contentViewForeground addSubview:contentViewHeadlineLabel];
            [contentViewForeground addSubview:contentViewDescriptionLabel];
            
        }
        self.backgroundContentViews = backgroundContentViews;
        self.foregroundContentViews = foregroundContentViews;
    }
    
    self.scrollViewForeground.contentOffset = CGPointZero;
    
    self.scrollViewBackground.showsHorizontalScrollIndicator = DEBUGGING_SCROLL_VIEW_CONTROLLER;
    self.scrollViewBackground.showsVerticalScrollIndicator = DEBUGGING_SCROLL_VIEW_CONTROLLER;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewDidLayoutSubviews];
    if (!self.hasAppeared) {
        [self setControlLabelsVisibleBlinkAnimatedToStart:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hasAppeared = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollViewForeground.frame = self.view.bounds;
    self.scrollViewForeground.contentSize = CGSizeMake(self.view.bounds.size.width * self.imageFilenames.count, self.scrollViewForeground.frame.size.height);
    self.scrollViewForeground.backgroundColor = [UIColor clearColor];

    self.scrollViewBackground.frame = CGRectMake((self.view.bounds.size.width - self.contentViewsSpacingValue) / 2.0, 0, self.contentViewsSpacingValue, self.view.bounds.size.height);
    
    for (int i=0; i<self.imageFilenames.count; i++) {
        UIView * contentView = self.backgroundContentViews[i];
        contentView.frame = CGRectMake(self.contentViewsSpacingValue * i, 0, self.view.bounds.size.width + self.contentViewsSpacingValue * 2.0, self.scrollViewBackground.bounds.size.height);
        NSLog(@"contentView(%d).frame = %@", i, NSStringFromCGRect(contentView.frame));
        UIView * contentViewForeground = self.foregroundContentViews[i];
        contentViewForeground.frame = CGRectMake(self.scrollViewForeground.bounds.size.width * i, 0, self.scrollViewForeground.bounds.size.width, self.scrollViewForeground.bounds.size.height);
    }
    
    self.backgroundContentViewsContainer.frame = CGRectMake(-(self.scrollViewBackground.frame.origin.x + self.scrollViewBackground.frame.size.width), 0, CGRectGetMaxX(((UIView *)self.backgroundContentViews.lastObject).frame), self.scrollViewBackground.bounds.size.height);
    
    self.scrollViewBackground.contentSize = CGSizeMake(self.contentViewsSpacingValue * self.backgroundContentViews.count, self.backgroundContentViewsContainer.frame.size.height);
    NSLog(@"%@ self.scrollView.contentSize = %@", NSStringFromSelector(_cmd), NSStringFromCGSize(self.scrollViewBackground.contentSize));
    self.scrollViewBackground.scrollIndicatorInsets = UIEdgeInsetsMake(0, -self.scrollViewBackground.frame.origin.x, 0, -(self.view.bounds.size.width - CGRectGetMaxX(self.scrollViewBackground.frame)));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollViewForeground) {
        self.scrollViewBackground.contentOffset = CGPointMake(self.scrollViewForeground.contentOffset.x / self.movementSuppressionFactor, self.scrollViewForeground.contentOffset.y);
    } else if (scrollView == self.scrollViewBackground) {
        CGFloat contentOffsetX = self.scrollViewBackground.contentOffset.x;
        CGFloat scrollViewWidth = self.contentViewsSpacingValue;
        CGFloat contentOffsetCenterX = contentOffsetX + scrollViewWidth / 2.0 - self.backgroundContentViewsContainer.frame.origin.x;
//        NSLog(@"coc.x = %f", contentOffsetCenterX);
        CGFloat d = 0;
        for (UIView * contentView in self.backgroundContentViews) {
            CGFloat cxd = self.contentViewsSpacingValue;
            CGFloat cxFull = contentView.center.x + cxd * self.alphaChangeBufferPercentage;
            CGFloat cxZero = contentView.center.x + self.contentViewsSpacingValue - cxd * self.alphaChangeBufferPercentage;
            cxd = cxZero - cxFull;
            d = contentOffsetCenterX - cxFull;
            d = MAX(0, d);
            d = MIN(d, cxd);
            if (contentView == self.backgroundContentViews.lastObject)
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
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), NSStringFromCGPoint(scrollView.contentOffset));
}

- (void)setMovementSuppressionFactor:(float)movementSuppressionFactor {
    movementSuppressionFactor = MAX(1.0, movementSuppressionFactor);
    if (_movementSuppressionFactor != movementSuppressionFactor) {
        int currentIndex = roundf(self.scrollViewForeground.contentOffset.x / self.scrollViewForeground.bounds.size.width);
        currentIndex = MAX(0, currentIndex);
        currentIndex = MIN(currentIndex, self.imageFilenames.count);
        _movementSuppressionFactor = movementSuppressionFactor;
        if (self.isViewLoaded && self.view.window) {
            [self setControlLabelsTextToDataValues];
            [self viewDidLayoutSubviews];
            self.scrollViewForeground.contentOffset = CGPointZero; // Not sure why this was necessary.
            self.scrollViewForeground.contentOffset = CGPointMake(currentIndex * self.scrollViewForeground.bounds.size.width, self.scrollViewForeground.contentOffset.y);
        }
    }
}

- (void)setAlphaChangeBufferPercentage:(float)alphaChangeBufferPercentage {
    alphaChangeBufferPercentage = MAX(0.0, alphaChangeBufferPercentage);
    alphaChangeBufferPercentage = MIN(0.48, alphaChangeBufferPercentage);
    if (_alphaChangeBufferPercentage != alphaChangeBufferPercentage) {
        _alphaChangeBufferPercentage = alphaChangeBufferPercentage;
        if (self.isViewLoaded && self.view.window) {
            [self setControlLabelsTextToDataValues];
        }
    }
}

- (void)setControlLabelsTextToDataValues {
    self.movementSuppressionFactorLabel.text = [NSString stringWithFormat:@"%.2f", self.movementSuppressionFactor];
    self.alphaChangeBufferPercentageLabel.text = [NSString stringWithFormat:@"%.2f", self.alphaChangeBufferPercentage];
}

- (void)setControlLabelsVisible:(BOOL)visible animated:(BOOL)animated {
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.controlsContainer.alpha = visible ? 1.0 : 0.0;
    } completion:NULL];
}

- (void)setControlLabelsInvisibleIfUntouched {
    if (!self.controlsTouched) {
        [self setControlLabelsVisible:NO animated:YES];
    }
}

- (void)setControlLabelsVisibleBlinkAnimatedToStart:(BOOL)animatedToStart {
    [UIView animateWithDuration:animatedToStart ? 0.15 : 0.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.controlsContainer.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(setControlLabelsInvisibleIfUntouched) withObject:nil afterDelay:DEBUGGING_SCROLL_VIEW_CONTROLLER ? 0.5 : 5.0];
    }];
}

- (CGFloat) contentViewsSpacingValue {
    return self.scrollViewForeground.bounds.size.width / self.movementSuppressionFactor;
}

- (float)getControlValueForGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    float controlValue = 0.0;
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        controlValue = self.movementSuppressionFactor;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        controlValue = self.alphaChangeBufferPercentage;
    }
    return controlValue;
}

- (void) setControlValue:(float)controlValue forGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        self.movementSuppressionFactor = controlValue;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        self.alphaChangeBufferPercentage = controlValue;
    }
}

- (CGPoint) getAnchorPointForGestureRecgonizer:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint anchorPoint = CGPointZero;
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        anchorPoint = self.movementSuppressionFactorPanAnchorPoint;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        anchorPoint = self.alphaChangeBufferPercentagePanAnchorPoint;
    }
    return anchorPoint;
}

- (void) setAnchorPoint:(CGPoint)anchorPoint forGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        self.movementSuppressionFactorPanAnchorPoint = anchorPoint;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        self.alphaChangeBufferPercentagePanAnchorPoint = anchorPoint;
    }
}

- (float) getAnchorValueForGestureRecgonizer:(UIPanGestureRecognizer *)gestureRecognizer {
    float anchorValue = 0.0;
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        anchorValue = self.movementSuppressionFactorPanAnchorValue;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        anchorValue = self.alphaChangeBufferPercentagePanAnchorValue;
    }
    return anchorValue;
}

- (void) setAnchorValue:(float)anchorValue forGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        self.movementSuppressionFactorPanAnchorValue = anchorValue;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        self.alphaChangeBufferPercentagePanAnchorValue = anchorValue;
    }
}

- (float) controlValueIncrementForGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    float increment = 0.0;
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        increment = 0.5;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        increment = 0.02;
    }
    return increment;
}

- (void)controlPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    BOOL gestureBegan = gestureRecognizer.state == UIGestureRecognizerStateBegan;
    BOOL gestureEnded = (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
                         gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
                         gestureRecognizer.state == UIGestureRecognizerStateFailed);
    BOOL shouldAdjustVisibility = gestureBegan || gestureEnded;
    BOOL shouldBeVisible = !gestureEnded;
        
    CGPoint locationInView = [gestureRecognizer locationInView:self.view];
    if (gestureBegan) {
        [self setAnchorPoint:locationInView forGestureRecognizer:gestureRecognizer];
        [self setAnchorValue:[self getControlValueForGestureRecognizer:gestureRecognizer] forGestureRecognizer:gestureRecognizer];
    } else {
        CGPoint anchorPoint = [self getAnchorPointForGestureRecgonizer:gestureRecognizer];
        CGFloat distanceVerticalFromAnchor = - (locationInView.y - anchorPoint.y);
        float anchorValueChange = roundf((distanceVerticalFromAnchor / 44.0)) * [self controlValueIncrementForGestureRecognizer:gestureRecognizer];
//        NSLog(@"distanceVerticalFromAnchor = %f", distanceVerticalFromAnchor);
//        NSLog(@"anchorValueChange = %f", anchorValueChange);
        if (anchorValueChange != 0) {
            [self setControlValue:[self getControlValueForGestureRecognizer:gestureRecognizer] + anchorValueChange forGestureRecognizer:gestureRecognizer];
            [self setAnchorPoint:locationInView forGestureRecognizer:gestureRecognizer];
            [self setAnchorValue:[self getControlValueForGestureRecognizer:gestureRecognizer] forGestureRecognizer:gestureRecognizer];
        }

    }
    
    if (shouldAdjustVisibility) {
        [self setControlLabelsVisible:shouldBeVisible animated:YES];
    }
    
    self.controlsTouched = YES;
    
}

- (void)controlSubmitGesture:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (gestureRecognizer == self.submitTapGestureRecognizer) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            [mailViewController setToRecipients:@[@"dan@picturelife.com"]];
            [mailViewController setSubject:@"Onboarding Perfection"];
            [mailViewController setMessageBody:[NSString stringWithFormat:@"My version of onboarding welcome screen perfection is:<br>Motion Drag %f<br>Alpha Delay %f", self.movementSuppressionFactor, self.alphaChangeBufferPercentage] isHTML:YES];
             [self presentViewController:mailViewController animated:YES completion:NULL];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (result == MFMailComposeResultSent) {
        [[[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Your opinion is the most important one." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (result == MFMailComposeResultFailed) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Tell Dan your idea of perfection IRL." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
