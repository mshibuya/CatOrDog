//
//  main.m
//  ImageLearner
//
//  Created by 渋谷充宏 on 2015/09/15.
//  Copyright (c) 2015年 渋谷充宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "DeepBeliefLearner.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        DeepBeliefLearner *learner = [[DeepBeliefLearner alloc] init];
        NSString *current = [[NSFileManager defaultManager] currentDirectoryPath];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:@"./images"];
        for(NSString *file in files){
            float label;
            if(isupper([file characterAtIndex:0])){
                // cat
                label = 1.0f;
            } else {
                // dog
                label = 0.0f;
            }
            NSString *path = [[NSString stringWithFormat:@"%@/images/%@", current, file] stringByStandardizingPath];
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
            assert(image != NULL);
            NSLog(@"%f --- %@", label, path);
            [learner runCNNOnFrame:image withLabel:label];
        }
        NSLog(@"-----------------------------------------------");
        [learner saveToFile:@"model.txt"];
        NSLog(@"-----------------------------------------------");
        
    }
    return 0;
}
