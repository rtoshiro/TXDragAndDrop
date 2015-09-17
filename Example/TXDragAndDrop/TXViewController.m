//
//  TXViewController.m
//  TXDragAndDrop
//
//  Created by rtoshiro on 09/16/2015.
//  Copyright (c) 2015 rtoshiro. All rights reserved.
//

#import "TXViewController.h"
#import "UIView+DragAndDrop.h"

@interface TXViewController ()

@end

@implementation TXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  [self.myview setDraggingEnabled:YES];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
