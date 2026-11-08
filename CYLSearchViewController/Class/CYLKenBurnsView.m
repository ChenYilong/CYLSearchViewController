

#import "CYLKenBurnsView.h"
#include <stdlib.h>

#define enlargeRatio 1.2
#define imageBufer 3

// Private interface
@interface CYLKenBurnsView ()

@property (nonatomic) int currentImage;
@property (nonatomic) BOOL animationInCurse;

- (void) _animate:(NSNumber*)num;
- (void) _startAnimations:(NSArray*)images;
- (void) _startInternetAnimations:(NSArray *)urls;
- (UIImage *) _downloadImageFrom:(NSString *)url;
- (void) _notifyDelegate:(NSNumber *) imageIndex;
@end


@implementation CYLKenBurnsView

@synthesize imagesArray, timeTransition, isLoop, isLandscape;
@synthesize animationInCurse, currentImage, delegate;


-(id)init
{
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void) animateWithImages:(NSMutableArray *)images transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)inLandscape;
{
    self.imagesArray      = images;
    self.timeTransition   = duration;
    self.isLoop           = shouldLoop;
    self.isLandscape      = inLandscape;
    self.animationInCurse = NO;
    
    self.layer.masksToBounds = YES;
    
    [NSThread detachNewThreadSelector:@selector(_startAnimations:) toTarget:self withObject:images];
    
}

- (void) animateWithURLs:(NSArray *)urls transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)inLandscape;
{
    self.imagesArray      = [[NSMutableArray alloc] init];
    self.timeTransition   = duration;
    self.isLoop           = shouldLoop;
    self.isLandscape      = inLandscape;
    self.animationInCurse = NO;
    
    NSUInteger bufferSize = (imageBufer < urls.count) ? imageBufer : urls.count;
    
    // Fill the buffer.
    for (uint i=0; i<bufferSize; i++) {
        NSString *url = [[NSString alloc] initWithString:[urls objectAtIndex:i]];
        [self.imagesArray addObject:[self _downloadImageFrom:url]];
        
    }
    
    self.layer.masksToBounds = YES;
    
    [NSThread detachNewThreadSelector:@selector(_startInternetAnimations:) toTarget:self withObject:urls];
    
}

- (void) _startAnimations:(NSArray *)images
{
    
    
    for (uint i = 0; i < [images count]; i++) {
        
        [self performSelectorOnMainThread:@selector(_animate:)
                               withObject:[NSNumber numberWithInt:i]
                            waitUntilDone:YES];
        
        sleep(self.timeTransition);
        
        i = (i == [images count] - 1) && isLoop ? -1 : i;
        
    }
    
    
}

- (UIImage *) _downloadImageFrom:(NSString *) url
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    return image;
}

- (void) _startInternetAnimations:(NSArray *)urls
{
    
    BOOL wrapping = NO;
    int bufferIndex = 0;
    
    for (NSUInteger urlIndex=self.imagesArray.count; urlIndex < [urls count]; urlIndex++) {
        
        [self performSelectorOnMainThread:@selector(_animate:)
                               withObject:[NSNumber numberWithInt:0]
                            waitUntilDone:YES];
        
        [self.imagesArray removeObjectAtIndex:0];
        [self.imagesArray addObject:[self _downloadImageFrom:[urls objectAtIndex: urlIndex]]];
        
        if ( bufferIndex == self.imagesArray.count -1)
        {
            NSLog(@"Wrapping!!");
            wrapping = YES;
            bufferIndex = -1;
        }
        
        bufferIndex++;
        urlIndex = (urlIndex == [urls count]-1) && isLoop ? -1 : urlIndex;
        
        sleep(self.timeTransition);
    }
    
    
}

- (void) _animate:(NSNumber*)num
{
    UIImage* image = [self.imagesArray objectAtIndex:[num intValue]];
    UIImageView *imageView;
    
    float resizeRatio   = -1;
    float widthDiff     = -1;
    float heightDiff    = -1;
    float originX       = -1;
    float originY       = -1;
    float zoomInX       = -1;
    float zoomInY       = -1;
    float moveX         = -1;
    float moveY         = -1;
    float frameWidth    = isLandscape? self.frame.size.width : self.frame.size.height;
    float frameHeight   = isLandscape? self.frame.size.height : self.frame.size.width;
    
    // Widder than screen
    if (image.size.width > frameWidth)
    {
        widthDiff  = image.size.width - frameWidth;
        
        // Higher than screen
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            
            if (widthDiff > heightDiff)
                resizeRatio = frameHeight / image.size.height;
            else
                resizeRatio = frameWidth / image.size.width;
            
            // No higher than screen
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
            
            if (widthDiff > heightDiff)
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = self.bounds.size.height / image.size.height;
        }
        
        // No widder than screen
    }
    else
    {
        widthDiff  = frameWidth - image.size.width;
        
        // Higher than screen
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            
            if (widthDiff > heightDiff)
                resizeRatio = image.size.height / frameHeight;
            else
                resizeRatio = frameWidth / image.size.width;
            
            // No higher than screen
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
            
            if (widthDiff > heightDiff)
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = frameHeight / image.size.height;
        }
    }
    
    // Resize the image.
    float optimusWidth  = (image.size.width * resizeRatio) * enlargeRatio;
    float optimusHeight = (image.size.height * resizeRatio) * enlargeRatio;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, optimusWidth, optimusHeight)];
    
    // Calcule the maximum move allowed.
    float maxMoveX = optimusWidth - frameWidth;
    float maxMoveY = optimusHeight - frameHeight;
    
    float rotation = (arc4random() % 9) / 100;
    
    switch (arc4random() % 4) {
        case 0:
            originX = 0;
            originY = 0;
            zoomInX = 1.25;
            zoomInY = 1.25;
            moveX   = -maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 1:
            originX = 0;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.10;
            zoomInY = 1.10;
            moveX   = -maxMoveX;
            moveY   = maxMoveY;
            break;
            
            
        case 2:
            originX = frameWidth - optimusWidth;
            originY = 0;
            zoomInX = 1.30;
            zoomInY = 1.30;
            moveX   = maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 3:
            originX = frameWidth - optimusWidth;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.20;
            zoomInY = 1.20;
            moveX   = maxMoveX;
            moveY   = maxMoveY;
            break;
            
        default:
            NSLog(@"def");
            break;
    }
    
    CALayer *picLayer    = [CALayer layer];
    picLayer.contents    = (id)image.CGImage;
    picLayer.anchorPoint = CGPointMake(0, 0);
    picLayer.bounds      = CGRectMake(0, 0, optimusWidth, optimusHeight);
    picLayer.position    = CGPointMake(originX, originY);
    
    [imageView.layer addSublayer:picLayer];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setType:kCATransitionFade];
    [[self layer] addAnimation:animation forKey:nil];
    
    // Remove the previous view
    if ([[self subviews] count] > 0){
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    [self addSubview:imageView];
    
    // Generates the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:self.timeTransition+2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    CGAffineTransform rotate    = CGAffineTransformMakeRotation(rotation);
    CGAffineTransform moveRight = CGAffineTransformMakeTranslation(moveX, moveY);
    CGAffineTransform combo1    = CGAffineTransformConcat(rotate, moveRight);
    CGAffineTransform zoomIn    = CGAffineTransformMakeScale(zoomInX, zoomInY);
    CGAffineTransform transform = CGAffineTransformConcat(zoomIn, combo1);
    imageView.transform = transform;
    [UIView commitAnimations];
    
    [self performSelector:@selector(_notifyDelegate:) withObject:num afterDelay:self.timeTransition];
    
    
    
}

- (void) _notifyDelegate: (NSNumber *)imageIndex
{
    if (delegate) {
        if([self.delegate respondsToSelector:@selector(didShowImageAtIndex:)])
        {
            [self.delegate didShowImageAtIndex:[imageIndex intValue]];
        }
        
        if ([imageIndex intValue] == ([self.imagesArray count]-1) && !isLoop && [self.delegate respondsToSelector:@selector(didFinishAllAnimations)]) {
            [self.delegate didFinishAllAnimations];
        }
    }
    
}

@end
