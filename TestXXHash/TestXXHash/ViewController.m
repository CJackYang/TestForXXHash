//
//  ViewController.m
//  TestXXHash
//
//  Created by 杨勇 on 16/8/24.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import "ViewController.h"
#import "xxhash.h"


// size of array to hold the data
#define BUFFER_SIZE 2000000

// seed for hash function
#define SEED 14881488

// amount of bytes to read from object, the more the better, if your objects are smaller
// you will get crash
#define BYTES_TO_READ 32

@interface ViewController ()
@property (nonatomic) NSTimer * killer;
@property (nonatomic) BOOL aaa;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    XXH32(@"233",32,14881488);
    _killer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(abc) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)abc{
    _aaa = !_aaa;
    static  int i = 0;
    NSLog(@"%d",i);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (_aaa) {
            XXH64(@"ababbabbababbab", BYTES_TO_READ, SEED);
            i++;
        }
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
