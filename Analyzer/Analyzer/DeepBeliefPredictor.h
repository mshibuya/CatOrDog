//
//  DeepBeliefPredictor.h
//  CocoaDragAndDrop
//
//  Created by 渋谷充宏 on 2015/09/15.
//  Copyright (c) 2015年 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeepBeliefPredictor : NSObject
{
    void* network;
    void* predictor;
}

- (float)runCNNAndPredictOnFrame:(NSImage *)image;

@end
