
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#pragma - CYLKenBurnsViewDelegate
@protocol CYLKenBurnsViewDelegate <NSObject>
@optional
- (void)didShowImageAtIndex:(NSUInteger)index;
- (void)didFinishAllAnimations;

@end

@interface CYLKenBurnsView : UIView {
    NSMutableArray *imagesArray;
    float timeTransition;
    BOOL isLoop;
    BOOL isLandscape;
    __weak id <CYLKenBurnsViewDelegate> delegate;
}

@property (nonatomic, assign) float timeTransition;
@property (nonatomic, retain) NSMutableArray *imagesArray;
@property (nonatomic) BOOL isLoop;
@property (nonatomic) BOOL isLandscape;
@property (weak) id<CYLKenBurnsViewDelegate> delegate;

- (void) animateWithImages:(NSArray *)images transitionDuration:(float)time loop:(BOOL)isLoop isLandscape:(BOOL)isLandscape;
- (void) animateWithURLs:(NSArray *)urls transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)inLandscape;

@end


