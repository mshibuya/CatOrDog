//
//  DeepBeliefPredictor.m
//  CocoaDragAndDrop
//
//  Created by 渋谷充宏 on 2015/09/15.
//  Copyright (c) 2015年 Apple, Inc. All rights reserved.
//

#import "DeepBeliefPredictor.h"
#import <QuartzCore/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <DeepBelief/DeepBelief.h>
#include <sys/time.h>

@implementation DeepBeliefPredictor

- (id)init
{
    if (self = [super init]) {
        NSString* networkPath = [[NSBundle mainBundle] pathForResource:@"jetpac" ofType:@"ntwk"];
        if (networkPath == NULL) {
            fprintf(stderr, "Couldn't find the neural network parameters file - did you add it as a resource to your application?\n");
            assert(false);
        }
        network = jpcnn_create_network([networkPath UTF8String]);
        assert(network != NULL);
        NSString* predictorPath = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"txt"];
        if (predictorPath == NULL) {
            fprintf(stderr, "Couldn't find the predictor file - did you add it as a resource to your application?\n");
            assert(false);
        }
        predictor = jpcnn_load_predictor([predictorPath UTF8String]);
        assert(network != NULL);
    }
    return self;
}

- (void)dealloc
{
    jpcnn_destroy_predictor(predictor);
    jpcnn_destroy_network(network);
    [super dealloc];
}

- (float)runCNNAndPredictOnFrame:(NSImage *)image
{
    CVPixelBufferRef pixelBuffer = [self fastImageFromNSImage:image];
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
    int doReverseChannels;
    if ( kCVPixelFormatType_32ARGB == sourcePixelFormat ) {
        doReverseChannels = 1;
    } else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat ) {
        doReverseChannels = 0;
    } else {
        assert(false); // Unknown source format
    }
    
    const int sourceRowBytes = (int)CVPixelBufferGetBytesPerRow( pixelBuffer );
    const int width = (int)CVPixelBufferGetWidth( pixelBuffer );
    const int fullHeight = (int)CVPixelBufferGetHeight( pixelBuffer );
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    unsigned char* sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
    int height;
    unsigned char* sourceStartAddr;
    if (fullHeight <= width) {
        height = fullHeight;
        sourceStartAddr = sourceBaseAddr;
    } else {
        height = width;
        const int marginY = ((fullHeight - width) / 2);
        sourceStartAddr = (sourceBaseAddr + (marginY * sourceRowBytes));
    }
    void* cnnInput = jpcnn_create_image_buffer_from_uint8_data(sourceStartAddr, width, height, 4, sourceRowBytes, doReverseChannels, 1);
    float* predictions;
    int predictionsLength;
    char** predictionsLabels;
    int predictionsLabelsLength;
    
    struct timeval start;
    gettimeofday(&start, NULL);
    jpcnn_classify_image(network, cnnInput, JPCNN_RANDOM_SAMPLE, -2, &predictions, &predictionsLength, &predictionsLabels, &predictionsLabelsLength);
    struct timeval end;
    gettimeofday(&end, NULL);
    const long seconds  = end.tv_sec  - start.tv_sec;
    const long useconds = end.tv_usec - start.tv_usec;
    const float duration = ((seconds) * 1000 + useconds/1000.0) + 0.5;
    NSLog(@"Took %f ms", duration);
    
    jpcnn_destroy_image_buffer(cnnInput);
    
    return jpcnn_predict(predictor, predictions, predictionsLength);
}


- (CVPixelBufferRef)fastImageFromNSImage:(NSImage *)image{
    CVPixelBufferRef buffer = NULL;
    
    // config
    size_t width = [image size].width;
    size_t height = [image size].height;
    size_t bitsPerComponent = 8; // *not* CGImageGetBitsPerComponent(image);
    CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGBitmapInfo bi = kCGImageAlphaNoneSkipFirst; // *not* CGImageGetBitmapInfo(image);
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey, [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    
    // create pixel buffer
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, k32ARGBPixelFormat, (__bridge CFDictionaryRef)d, &buffer);
    CVPixelBufferLockBaseAddress(buffer, 0);
    void *rasterData = CVPixelBufferGetBaseAddress(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    // context to draw in, set to pixel buffer's address
    CGContextRef ctxt = CGBitmapContextCreate(rasterData, width, height, bitsPerComponent, bytesPerRow, cs, bi);
    assert(ctxt != NULL);
    
    // draw
    NSGraphicsContext *nsctxt = [NSGraphicsContext graphicsContextWithGraphicsPort:ctxt flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsctxt];
    [image compositeToPoint:NSMakePoint(0.0, 0.0) operation:NSCompositeCopy];
    [NSGraphicsContext restoreGraphicsState];
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    CFRelease(ctxt);
    
    return buffer;
}

@end
