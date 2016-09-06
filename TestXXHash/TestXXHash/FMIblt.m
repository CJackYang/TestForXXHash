//
//  FMIblt.m
//  TestXXHash
//
//  Created by 杨勇 on 16/8/30.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import "FMIblt.h"
#import "xxhash.h"

@implementation FMIblt

+(instancetype)createIBFWithExponent:(NSInteger)exponent andLength:(uint32_t)length andK:(NSInteger)k andSeed:(int)seed{
    FMIblt *iblt = [[FMIblt alloc]init];
    iblt.n = pow(2, exponent);
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < iblt.n; i++) {
        Cells * cell = [[Cells alloc] initWithLength:length];
        [arr addObject:cell];
    }
    iblt.B = [NSArray arrayWithArray:arr];
    iblt.hashPad = malloc(sizeof(uint32_t));
    iblt.k = k;
    iblt.length = length;
    iblt.seed = seed;
    return iblt;
}


+(NSArray *)hashToDistinctIndices:(char *)sid andK:(NSInteger)k andN:(int)n andSeed:(int)seed{
    NSMutableArray * indices = [NSMutableArray arrayWithCapacity:0];
    uint32_t s = seed;
    while (indices.count<k) {
        s = XXH32(sid,4,s);
        int idx = s % n;
        if (![indices containsObject:@(idx)]) {
            [indices addObject:@(idx)];
        }
    }
    
    return indices;
}

-(void)ibfUnionWithId:(char *)sid andIsinsert:(BOOL)insert{
    
    NSArray * indices = [FMIblt hashToDistinctIndices:sid andK:self.k andN:self.n andSeed:self.seed];
    for (NSNumber * j in indices) {
        
        for (int m = 0; m < self.length; m ++) {
            
            ((Cells *)self.B[[j intValue]])->idSum[m] ^= sid[m];
        }
        
        uint32_t  hashpad = XXH32(sid,4, self.seed);
        
        (((Cells *)self.B[[j intValue]])->hashSum) ^= hashpad;
        
        ((Cells *)self.B[[j intValue]])->count  = ((Cells *)self.B[[j integerValue]])->count + (insert ? 1: -1);
    }
}

-(void)ibltInsertWithId:(char *)sid{
    [self ibfUnionWithId:sid andIsinsert:YES];
}

-(void)ibltRemoveWithId:(char *)sid{
    [self ibfUnionWithId:sid andIsinsert:NO];
}

-(void)ibltEncodeWithIds:(NSArray *)ids{
    for (NSString * sid in ids) {
        [self ibltInsertWithId:(char *)[sid UTF8String]];
    }
}

+(FMIblt *)ibltSubtractWithIBF1:(FMIblt *)ibf1 andIBF2:(FMIblt *)ibf2{
    FMIblt * ibf = [FMIblt createIBFWithExponent:log2(ibf1.n) andLength:ibf1.length andK:ibf1.k andSeed:ibf1.seed];
    
    for (int i = 0; i < ibf.n; i++) {
        
        for (int m = 0; m < ibf.length; m ++) {
            ((Cells *)ibf.B[i])->idSum[m] = ((Cells *)ibf1.B[i])->idSum[m] ^ ((Cells *)ibf2.B[i])->idSum[m];
        }
        
        ((Cells *)ibf.B[i])->hashSum = (((Cells *)ibf1.B[i])->hashSum) ^ (((Cells *)ibf2.B[i])->hashSum);
        
        ((Cells *)ibf.B[i])->count = ((Cells *)ibf1.B[i])->count - ((Cells *)ibf2.B[i])->count;
    }
    
    return ibf;
}

-(BOOL)isZero{
    for (int i = 0; i < self.n ; i++) {
        for (int m = 0; m < self.length; m ++) {
            if(((Cells *)self.B[i])->idSum[m] != 0)
                return false;
        }
        if (((Cells *)self.B[i])->hashSum != 0)
            return false;
        
        
        if (((Cells *)self.B[i])->count != 0)
            return false;
        
    }
    return  true;
}


+(BOOL)ibfDecodeWithIbf:(FMIblt *)ibf{
    NSMutableArray * pureList = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * DAB = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * DBA = [NSMutableArray arrayWithCapacity:0];
    
    
    for (int i = 0; i < ibf.n; i ++) {
        Cells * cell = ibf.B[i];
        if ([cell isPureWithSeed:ibf.seed])
            [pureList addObject:@(i)];
    }
    
    while (pureList.count) {
        int i = [[pureList firstObject]intValue];
        [pureList removeObjectAtIndex:0];
        if (![ibf.B[i] isPureWithSeed:ibf.seed])
             continue;
        
        //keep a copy
        char * sid = malloc(sizeof(char) * ibf.length);
        strcpy(sid, ((Cells *)ibf.B[i])->idSum);
        uint32_t hash = ((Cells *)ibf.B[i])->hashSum;
        int c = ((Cells *)ibf.B[i])->count;
        
        c > 0 ? [DAB addObject:[NSString stringWithUTF8String:sid]] : [DBA addObject:[NSString stringWithUTF8String:sid]];
        
        NSArray * indices = [FMIblt hashToDistinctIndices:sid andK:ibf.k andN:ibf.n andSeed:ibf.seed];
        for (NSNumber * j in indices) {
            //Xor idSum
            for (int m = 0; m < ibf.length; m ++) {
                ((Cells *)ibf.B[[j intValue]])->idSum[m] ^= sid[m];
            }
            
//            uint32_t  hashpad = XXH32(sid,4, self.seed);
            (((Cells *)ibf.B[[j intValue]])->hashSum) ^= hash;
            
            
            ((Cells *)ibf.B[[j intValue]])->count -= c;
            
            if([((Cells *)ibf.B[[j intValue]]) isPureWithSeed:ibf.seed])
               [pureList addObject:j];
        }
        
    }
    
    ibf.DAB = DAB;
    ibf.DBA = DBA;
    
    
    return ibf.isZero;
}


@end

@implementation Cells

-(instancetype)initWithLength:(int)length{
    if (self = [super init]) {
        idSum = malloc(sizeof(char) * length);
        memset(idSum, 0, length);
        
        hashSum = 0;
        
        count = 0;
    }
    return self;
}

-(BOOL)isPureWithSeed:(int)seed{
    if(count == 1 || count == -1){
        
        int hashpad = XXH32(idSum,4, seed);
        if (hashSum == hashpad) {
            return  YES;
        }
    }
    return NO;
}

-(BOOL)empty{
    return (count == 0 && idSum == 0 && hashSum == 0);
}


@end