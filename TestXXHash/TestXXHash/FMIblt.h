//
//  FMIblt.h
//  TestXXHash
//
//  Created by 杨勇 on 16/8/30.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMIblt : NSObject

@property (nonatomic) NSArray * B;

@property (nonatomic) int n;

@property (nonatomic) uint32_t length;

@property (nonatomic) uint32_t * hashPad;

@property (nonatomic) NSInteger k;

@property (nonatomic) int seed;

@property (nonatomic) NSMutableArray * DAB;

@property (nonatomic) NSMutableArray * DBA;

+(instancetype)createIBFWithExponent:(NSInteger)exponent
                           andLength:(uint32_t)length
                                andK:(NSInteger)k
                             andSeed:(NSInteger)seed;

+(FMIblt *)ibltSubtractWithIBF1:(FMIblt *)ibf1 andIBF2:(FMIblt *)ibf2;

+(BOOL)ibfDecodeWithIbf:(FMIblt *)ibf;

-(BOOL)isZero;


-(void)ibltEncodeWithIds:(NSArray *)ids;

-(void)ibltInsertWithId:(char *)sid;

-(void)ibltRemoveWithId:(char *)sid;

-(BOOL)ibfDecodeWithIbf:(FMIblt *)ibf;
@end


@interface Cells : NSObject{
    @public
    int count;
    char * idSum;
    uint32_t hashSum;
}
-(instancetype)initWithLength:(int)length;

-(BOOL)isPureWithSeed:(int)seed;
//-(BOOL)isPure;
//
//-(BOOL)empty;
//
//-(void)addValue:(NSArray *)v;

@end







