//
//  ViewController.m
//  TestXXHash
//
//  Created by 杨勇 on 16/8/24.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import "ViewController.h"
#import "xxhash.h"
#import "FMIblt.h"


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
    
    NSString *str = @"AA21f0c1762a3abc299c013abe7dbcc50001DD";
    
    NSData* bytes = [str dataUsingEncoding:NSUTF8StringEncoding];
    Byte * myByte = (Byte *)[bytes bytes];
    NSLog(@"myByte = %s",myByte);
    
//    XXH32(@"233",32,14881488);
//    _killer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(abc) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@",[self hexStringFromString:@"ABCD"]);
    
    [self test2];
    
    
}


-(void)test1{
    FMIblt * iblt = [FMIblt createIBFWithExponent:4 andLength:32 andK:3 andSeed:0];
    NSLog(@"%d",[iblt isZero]);
}

-(void)test2{
    NSMutableArray * ids = [NSMutableArray arrayWithCapacity:0];
    [ids addObject:[self hexStringFromString:@"1234"]];
    [ids addObject:[self hexStringFromString:@"7894"]];
    [ids addObject:[self hexStringFromString:@"5566"]];
    
//    [self test2x1With:ids];

    [self test2x2With:ids];
    
    
//    char * uuid0 = "fbc29e8b-b47c-4afd-927a-51322f369eb2";
//    char * uuid1 = "5bbf8f3c-1dfb-49ee-ba90-4c8898d6b303";
//    char * uuid2 = "71e9facd-0342-49e9-ae3a-8b3992efb9f3";
//    char * uuid3 = "f101d691-767d-420c-ae1b-7f5688facbb8";
//    char * uuid4 = "46a13cf5-b756-429f-b691-d347e241b063";
//    char * uuid5 = "e89bf6c4-e9a1-49c2-98a6-e7872be24d51";
//    char * uuid6 = "9523acc4-e3e1-4d1b-a222-f53330a95773";
//    char * uuid7 = "7418f17f-c7b4-4321-8d09-5474499f7ff5";
//    char * uuid8 = "0a54e78c-3093-498a-b728-466a49c1e091";
//    char * uuid9 = "bf3b7147-0d47-4fcc-b008-a53a79fa2288";
    
    
}

-(void)test2x2With:(NSMutableArray *)ids{
    // should subtract and decode 1 positive diff
    FMIblt * ibf1 = [FMIblt createIBFWithExponent:4 andLength:4 andK:2 andSeed:0xABCD];
    FMIblt * ibf2 = [FMIblt createIBFWithExponent:4 andLength:4 andK:2 andSeed:0xABCD];
    
    [ibf1 ibltInsertWithId:(char *)[ids[0] UTF8String]];
    [ibf1 ibltInsertWithId:(char *)[ids[1] UTF8String]];
    [ibf1 ibltInsertWithId:(char *)[ids[2] UTF8String]];
    
    
    [ibf2 ibltInsertWithId:(char *)[ids[0] UTF8String]];
    [ibf2 ibltInsertWithId:(char *)[ids[1] UTF8String]];
    
    
    FMIblt * ibf = [FMIblt ibltSubtractWithIBF1:ibf1 andIBF2:ibf2];
    BOOL r =  [FMIblt ibfDecodeWithIbf:ibf];
    NSLog(@"%d",r);
}


-(void)test2x1With:(NSMutableArray *)ids{
    //should create new IBF, insert then remove, get empty ibf
    FMIblt * iblt = [FMIblt createIBFWithExponent:4 andLength:4 andK:2 andSeed:0xABCD];
    
    for (NSString * s in ids) {
        [iblt ibltInsertWithId:(char *)[s UTF8String]];
    }
    
    
    for (NSString * s in ids) {
        [iblt ibltRemoveWithId:(char *)[s UTF8String]];
    }
    NSLog(@"%d",[iblt isZero]);
}


- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

@end
