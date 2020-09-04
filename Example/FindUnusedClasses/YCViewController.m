//
//  YCViewController.m
//  FindUnusedClasses
//
//  Created by sea777777 on 09/03/2020.
//  Copyright (c) 2020 sea777777. All rights reserved.
//

#import "YCViewController.h"
#import <FindUnusedClasses/FindUnusedClasses.h>
#import "YCUnused2.h"

@interface YCViewController ()

@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    [[YCUnused2 new] doSomething];
    
    
    //耗时操作，尽量放在子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [FindUnusedClasses allUnusedClasses:[self class]];
    });
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
