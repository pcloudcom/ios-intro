//
//  GrandFinalleViewController.m
//  FileBrowser
//
//  Created by Todor Pitekov on 5/13/14.
//  Copyright (c) 2014 Todor Pitekov. All rights reserved.
//

#import "GrandFinalleViewController.h"

@interface GrandFinalleViewController () {
	UILabel *_label;
	UILabel *_secondLabel;
}

@end

@implementation GrandFinalleViewController

- (void)animate
{
	[UIView animateKeyframesWithDuration:0.75 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
		[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.55 animations:^{
			CGRect frame = _label.frame;
			frame.origin.x += 20.0f;
			_label.frame = frame;
		}];
		
		[UIView addKeyframeWithRelativeStartTime:0.55 relativeDuration:0.2 animations:^{
			_secondLabel.frame = CGRectMake(0.0f, 140.0f, 320.0f, 100.0f);
			CGRect frame = _label.frame;
			frame.origin.x -= 370.0f;
			_label.frame = frame;
		}];
	} completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 140.0f, 320.0f, 100.0f)];
	_label.font = [UIFont boldSystemFontOfSize:30.0f];
	_label.textColor = [UIColor blackColor];
	_label.textAlignment = NSTextAlignmentCenter;
	_label.backgroundColor = [UIColor clearColor];
	_label.text = @"Благодаря за вниманието";
	_label.lineBreakMode = NSLineBreakByWordWrapping;
	_label.numberOfLines = 0;
	[self.view addSubview:_label];
	
	_secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f, 140.0f, 320.0f, 100.0f)];
	_secondLabel.font = [UIFont boldSystemFontOfSize:30.0f];
	_secondLabel.textColor = [UIColor blackColor];
	_secondLabel.textAlignment = NSTextAlignmentCenter;
	_secondLabel.backgroundColor = [UIColor clearColor];
	_secondLabel.text = @"Въпроси?";
	_secondLabel.lineBreakMode = NSLineBreakByWordWrapping;
	_secondLabel.numberOfLines = 0;
	[self.view addSubview:_secondLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self animate];
	});
}

@end
