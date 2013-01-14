//
//  CubePageView.h
//
//  Created by Guillaume Salva on 20/12/12.
//  Copyright (c) 2012 Ghinzu.iphone All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kCubePageView_M34 (1.0/-500.0)

#define kCubePageView_toRadians(a) ((a)*M_PI/180.0f)


@protocol CubePageView_Delegate;

@interface CubePageView : UIView <UIGestureRecognizerDelegate>
{
	__unsafe_unretained id <CubePageView_Delegate> delegate;
	
	BOOL auto_start_stop;
}

@property (nonatomic, assign) id<CubePageView_Delegate> delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)setPages:(NSArray *)pages;

- (void)selectPage:(int)idx withAnim:(BOOL)anim;
- (int)currentPage;
- (int)numberPages;

@end


@protocol CubePageView_Delegate <NSObject>
@optional

- (void)CubePageView:(CubePageView *)pc
			 newPage:(int)page;

@end