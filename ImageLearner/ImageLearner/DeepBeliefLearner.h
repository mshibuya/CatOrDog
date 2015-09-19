//
//  DeepBeliefLeaner.h
//  ExampleLearner
//
//  Created by 渋谷充宏 on 2015/09/15.
//  Copyright (c) 2015年 渋谷充宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import "DeepBelief.h"

@interface DeepBeliefLearner : NSObject
{
    void* network;
    void* trainer;
}

- (void)saveToFile:(NSString *)file;
- (void)runCNNOnFrame:(NSImage *)image withLabel:(float)label;

@end
