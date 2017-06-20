//
//  ContentViewController.m
//  AccountBook
//
//  Created by lidaye on 20/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

#import "ContentViewController.h"
#import "AccountBook-Swift.h"

@interface ContentViewController ()

@end

@implementation ContentViewController

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    self.title = _message.object;
    [self.view addSubview:[JSONFormatter prettyViewIn:self.view message:_message.content]];
}

@end
