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

#define kMovementSuppressionFactorDefault 3.0
#define kAlphaChangeBufferPercentageDefault 0.0

@interface PLFScrollViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic) NSArray * imageFilenames; // Image filename strings
@property (nonatomic) NSArray * imageHeadlines; // Headline text strings
@property (nonatomic) NSArray * imageDescriptions; // Description text strings
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
        self.imageFilenames = @[@"test1.jpg", @"test2.jpg", @"test3.jpg", @"test4.jpg", @"test5.jpg", @"test6.jpg", @"test7.jpg", @"test8.jpg", @"test9.jpg", @"test10.jpg", @"test11.jpg"];
        self.imageHeadlines = @[@"Store all your pictures", @"Automatically sync", @"Access anywhere", @"Send pictures easily"];
        self.imageDescriptions = @[@"All backed up in one place", @"Never worry about losing pictures", @"View and organize on any device", @"Any picture can be sent instantly"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controlsContainer.alpha = 0.0;
    
    self.crossFadeView.backgroundMovementSuppression = kMovementSuppressionFactorDefault;
    self.crossFadeView.backgroundAlphaChangeDelay = kAlphaChangeBufferPercentageDefault;
    self.crossFadeView.staticView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"overlay_minimal"] resizableImageWithCapInsets:UIEdgeInsetsMake(200.0, 159.0, 200.0, 159.0)]];
    
    [self setControlLabelsTextToDataValues];
    
    if (self.crossFadeView.contentViewsCount == 0) {
        for (int i=0; i<self.imageFilenames.count; i++) {
            NSString * imageFilename = self.imageFilenames[i];
            
            UIImageView * contentViewBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFilename]];
            contentViewBackground.contentMode = UIViewContentModeScaleAspectFill;
            
            UIView * contentViewForeground = [[UIView alloc] initWithFrame:CGRectOffset(self.view.bounds, [self.imageFilenames indexOfObject:imageFilename] * self.view.bounds.size.width, 0)];
            
            UILabel * contentViewHeadlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, contentViewForeground.bounds.size.height - 160.0, contentViewForeground.bounds.size.width - 25.0 * 2, 28.0)];
            contentViewHeadlineLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            contentViewHeadlineLabel.textColor = [UIColor whiteColor];
            contentViewHeadlineLabel.font = [UIFont boldSystemFontOfSize:20.0];
            contentViewHeadlineLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            contentViewHeadlineLabel.shadowOffset = CGSizeMake(0, 1.0);
            contentViewHeadlineLabel.textAlignment = NSTextAlignmentCenter;
            contentViewHeadlineLabel.text = self.imageHeadlines[i % self.imageHeadlines.count];
            contentViewHeadlineLabel.backgroundColor = [UIColor clearColor];
            UILabel * contentViewDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, CGRectGetMaxY(contentViewHeadlineLabel.frame), contentViewForeground.bounds.size.width - 25.0 * 2, 28.0)];
            contentViewDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            contentViewDescriptionLabel.textColor = [UIColor whiteColor];
            contentViewDescriptionLabel.font = [UIFont systemFontOfSize:16.0];
            contentViewDescriptionLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            contentViewDescriptionLabel.shadowOffset = CGSizeMake(0, 1.0);
            contentViewDescriptionLabel.textAlignment = NSTextAlignmentCenter;
            contentViewDescriptionLabel.numberOfLines = 2;
            contentViewDescriptionLabel.text = self.imageDescriptions[i % self.imageDescriptions.count];
            contentViewDescriptionLabel.backgroundColor = [UIColor clearColor];
            
            [contentViewForeground addSubview:contentViewHeadlineLabel];
            [contentViewForeground addSubview:contentViewDescriptionLabel];
            
            [self.crossFadeView addBackgroundContentView:contentViewBackground foregroundContentView:contentViewForeground];
        }
    }
    
    self.crossFadeView.pageControl.hidden = NO;
    self.crossFadeView.pageControl.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 87.0);
    self.crossFadeView.autoPagingDuration = 5.0;
    self.crossFadeView.autoPagingShouldLoop = YES;
    self.crossFadeView.autoPagingShouldStopOnUserInteraction = YES;
    
    self.crossFadeView.foregroundScrollView.contentOffset = CGPointZero;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.crossFadeView setNeedsLayout];
    if (!self.hasAppeared) {
        [self setControlLabelsVisibleBlinkAnimatedToStart:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hasAppeared = YES;
    [self.crossFadeView startAutoPaging];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.crossFadeView stopAutoPaging];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.crossFadeView setNeedsLayout];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), NSStringFromCGPoint(scrollView.contentOffset));
}

- (void)setControlLabelsTextToDataValues {
    self.movementSuppressionFactorLabel.text = [NSString stringWithFormat:@"%.2f", self.crossFadeView.backgroundMovementSuppression];
    self.alphaChangeBufferPercentageLabel.text = [NSString stringWithFormat:@"%.2f", self.crossFadeView.backgroundAlphaChangeDelay];
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
        [self performSelector:@selector(setControlLabelsInvisibleIfUntouched) withObject:nil afterDelay:2.0];
    }];
}

- (float)getControlValueForGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    float controlValue = 0.0;
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        controlValue = self.crossFadeView.backgroundMovementSuppression;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        controlValue = self.crossFadeView.backgroundAlphaChangeDelay;
    }
    return controlValue;
}

- (void) setControlValue:(float)controlValue forGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.movementSuppressionFactorPanGestureRecognizer) {
        self.crossFadeView.backgroundMovementSuppression = controlValue;
    } else if (gestureRecognizer == self.alphaChangeBufferPercentagePanGestureRecognizer) {
        self.crossFadeView.backgroundAlphaChangeDelay = controlValue;
    }
    [self setControlLabelsTextToDataValues];
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
            [mailViewController setMessageBody:[NSString stringWithFormat:@"My version of onboarding welcome screen perfection is:<br>Motion Drag %f<br>Alpha Delay %f", self.crossFadeView.backgroundMovementSuppression, self.crossFadeView.backgroundAlphaChangeDelay] isHTML:YES];
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
