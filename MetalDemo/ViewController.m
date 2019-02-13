//
//  ViewController.m
//  MetalDemo
//
//  Created by HW on 2019/2/13.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "ViewController.h"
#import "MyMetalView.h"

@interface ViewController ()
@property (strong, nonatomic) MyMetalView* metalView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _metalView = [[MyMetalView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_metalView];
    
}


@end
