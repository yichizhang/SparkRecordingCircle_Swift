//
//  ViewController.m
//  SparkRecordingCircle
//
//  Created by Sam Page on 1/02/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import "ViewController.h"
#import "RecordingCircleOverlayView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGFloat w = CGRectGetHeight(self.view.bounds);
    RecordingCircleOverlayView *recordingCircleOverlayView = [[RecordingCircleOverlayView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-w*0.5f, 0, w, w) strokeWidth:7.f insets:UIEdgeInsetsMake(10.f, 0.f, 10.f, 0.f)];
    recordingCircleOverlayView.duration = 10.f;
    [self.view addSubview:recordingCircleOverlayView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
