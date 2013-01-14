//
//  CubePageView.m
//
//  Created by Guillaume Salva on 20/12/12.
//  Copyright (c) 2012 Ghinzu.iphone All rights reserved.
//

#import "CubePageView.h"

#ifndef ARC_ENABLED
#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature
#endif

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define ARC_ENABLED 1
#else
#define ARC_ENABLED 0
#endif
#endif



typedef enum _CubePageView_Direction {
	CubePageView_Direction_Next,
	CubePageView_Direction_Next_Stay,
	CubePageView_Direction_Prev,
	CubePageView_Direction_Prev_Stay,
	CubePageView_Direction_None
}CubePageView_Direction;

@interface CubePageView ()
{
	NSArray *pc_pages;
	
	int pc_current_page;
	CubePageView_Direction pc_direction;
	float pc_start_x_touch;
	
	float pc_width_page;
	
	UIView *pc_v_prev;
	UIView *pc_v_current;
	UIView *pc_v_next;
}

- (void)private_cleanPrev;
- (void)private_cleanCurrent;
- (void)private_cleanNext;

- (void)private_showPage:(int)iCurrent;
- (void)private_animPages:(int)iCurrent;

- (void)private_delegate:(int)idx;

@end


@implementation CubePageView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        pc_pages = nil;
		pc_current_page = -1;
		
		pc_direction = CubePageView_Direction_None;
		
		pc_v_prev = nil;
		pc_v_current = nil;
		pc_v_next = nil;
		
		UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
		pgr.minimumNumberOfTouches = 1;
		pgr.maximumNumberOfTouches = 1;
		[self addGestureRecognizer:pgr];
#if !ARC_ENABLED
		[pgr release];
#endif
		pgr = nil;
    }
    return self;
}

- (void)setPages:(NSArray *)pages
{
	pc_width_page = 0.0;
	
    [self private_cleanCurrent];
    [self private_cleanNext];
    [self private_cleanPrev];
    
	if(pc_pages != nil){
#if !ARC_ENABLED
		[pc_pages release];
#endif
		pc_pages = nil;
	}
	if((pages != nil) && ([pages count] > 0)){
		pc_pages = [[NSArray alloc] initWithArray:pages];
		
		UIView *v = [pages objectAtIndex:0];
		pc_width_page = v.frame.size.width;
	}
	
	pc_current_page = -1;
	
	[self selectPage:0 withAnim:NO];
	
	[self private_delegate:0];
}

- (void)selectPage:(int)idx withAnim:(BOOL)anim
{
	int iCurrent = idx;
	if((pc_pages != nil) && ([pc_pages count] > 0)){
		if(iCurrent < 0){
			iCurrent = 0;
		}
		else if(iCurrent >= [pc_pages count]){
			iCurrent = [pc_pages count]-1;
		}
		
		//if(pc_current_page != iCurrent){
			if(anim){
				[self private_animPages:iCurrent];
			}
			else{
				[self private_showPage:iCurrent];
				
				pc_current_page = iCurrent;
			}
		//}
	}
	else{
		pc_current_page = 0;
		[self private_cleanPrev];
		[self private_cleanCurrent];
		[self private_cleanNext];
	}
}

- (int)currentPage
{
	return pc_current_page;
}

- (int)numberPages
{
	int iRes = 0;
	if(pc_pages != nil){
		iRes = [pc_pages count];
	}
	return iRes;
}

// Gesture

- (void)gesture:(UIGestureRecognizer *)gr
{
	if((pc_v_current != nil) && (pc_v_next != nil) && (pc_v_prev != nil)){
		if((gr != nil) && [gr isKindOfClass:[UIPanGestureRecognizer class]]){
			UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)gr;
			CGPoint p_touch = [pgr locationInView:self];
			CGPoint p_translation = [pgr translationInView:self];
			
			
			if(pc_direction == CubePageView_Direction_None){
				if(p_translation.x < 0.0){
					pc_direction = CubePageView_Direction_Next;
					pc_start_x_touch = p_touch.x;
				}
				else if(p_translation.x > 0.0){
					pc_direction = CubePageView_Direction_Prev;
					pc_start_x_touch = p_touch.x;
				}
			}
			
			if(pc_direction != CubePageView_Direction_None){
				__block float fPercent = 0.0;
				float fRealTouch = 0.0;
				if(pc_direction == CubePageView_Direction_Next){
					fRealTouch = (self.frame.size.width-(pc_start_x_touch-p_touch.x));
				}
				else if(pc_direction == CubePageView_Direction_Prev){
					fRealTouch = (p_touch.x-pc_start_x_touch);
				}
				
				fPercent = fRealTouch/self.frame.size.width;
				
				if(fPercent < 0.0){
					fPercent = 0.0;
				}
				else if(fPercent > 1.0){
					fPercent = 1.0;
				}
				
				__block float rotation = 0.0;
				
				if((pgr.state == UIGestureRecognizerStateEnded) ||
				   (pgr.state == UIGestureRecognizerStateCancelled)){
					// ANIM
					if(pc_direction == CubePageView_Direction_Next){
						if(fRealTouch > (self.frame.size.width*0.75)){
							pc_direction = CubePageView_Direction_Next_Stay;
						}
					}
					else if(pc_direction == CubePageView_Direction_Prev){
						if(fRealTouch < (self.frame.size.width*0.25)){
							pc_direction = CubePageView_Direction_Prev_Stay;
						}
					}
					
					[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
						if((pc_direction == CubePageView_Direction_Next) ||
						   (pc_direction == CubePageView_Direction_Next_Stay)){
							fPercent = 0.0;
							if(pc_direction == CubePageView_Direction_Next_Stay){
								fPercent = 1.0;
							}
							
							rotation =(fPercent*90.0)+90.0;
							
							if(pc_v_current != nil){
								pc_v_current.layer.anchorPoint = CGPointMake(0.5, 0.5);
								CATransform3D t = CATransform3DIdentity;
								t.m34 = kCubePageView_M34;
								float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
								pc_v_current.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation+180.0), 0.0, 1.0, 0.0);
								pc_v_current.center = CGPointMake((self.frame.size.width/2.0)-fProject, floorf(self.frame.size.height/2.0));
								[self addSubview:pc_v_current];
							}
							
							rotation = (fPercent*90.0);
							
							if(pc_v_next != nil){
								pc_v_next.layer.anchorPoint = CGPointMake(0.5, 0.5);
								CATransform3D t = CATransform3DIdentity;
								t.m34 = kCubePageView_M34;
								float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
								pc_v_next.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation), 0.0, 1.0, 0.0);
								pc_v_next.center = CGPointMake((self.frame.size.width/2.0)+fProject, floorf(self.frame.size.height/2.0));
								[self addSubview:pc_v_next];
							}
						}
						else {
							fPercent = 1.0;
							if(pc_direction == CubePageView_Direction_Prev_Stay){
								fPercent = 0.0;
							}
							
							rotation = (fPercent*90.0);
							
							if(pc_v_current != nil){
								pc_v_current.layer.anchorPoint = CGPointMake(0.5, 0.5);
								CATransform3D t = CATransform3DIdentity;
								t.m34 = kCubePageView_M34;
								float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
								pc_v_current.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation), 0.0, 1.0, 0.0);
								pc_v_current.center = CGPointMake((self.frame.size.width/2.0)+fProject, floorf(self.frame.size.height/2.0));
								[self addSubview:pc_v_current];
							}
							
							rotation = (fPercent*90.0)+90.0;
							
							if(pc_v_prev != nil){
								pc_v_prev.layer.anchorPoint = CGPointMake(0.5, 0.5);
								CATransform3D t = CATransform3DIdentity;
								t.m34 = kCubePageView_M34;
								float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
								pc_v_prev.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation+180.0), 0.0, 1.0, 0.0);
								pc_v_prev.center = CGPointMake((self.frame.size.width/2.0)-fProject, floorf(self.frame.size.height/2.0));
								[self addSubview:pc_v_prev];
							}
						}
					}completion:^(BOOL finished){
						if(finished){
							if((pc_direction != CubePageView_Direction_Prev_Stay) &&
							   (pc_direction != CubePageView_Direction_Next_Stay)){
								pc_current_page = pc_current_page+((pc_direction == CubePageView_Direction_Next)?1:-1);
								if(pc_pages != nil){
									if(pc_current_page < 0){
										pc_current_page = [pc_pages count]-1;
									}
									else if(pc_current_page >= [pc_pages count]){
										pc_current_page = 0;
									}
								}
								[self selectPage:pc_current_page withAnim:NO];
								[self private_delegate:pc_current_page];
							}
							else{
								[self selectPage:pc_current_page withAnim:NO];
							}
							pc_direction = CubePageView_Direction_None;
						}
					}];
				}
				else{
					if(pc_direction == CubePageView_Direction_Next){
						rotation = (fPercent*90.0)+90.0;
						
						if(pc_v_current != nil){
							pc_v_current.layer.anchorPoint = CGPointMake(0.5, 0.5);
							CATransform3D t = CATransform3DIdentity;
							t.m34 = kCubePageView_M34;
							float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
							pc_v_current.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation+180.0), 0.0, 1.0, 0.0);
							pc_v_current.center = CGPointMake((self.frame.size.width/2.0)-fProject, floorf(self.frame.size.height/2.0));
							[self addSubview:pc_v_current];
						}
						
						rotation = (fPercent*90.0);
						
						if(pc_v_next != nil){
							pc_v_next.layer.anchorPoint = CGPointMake(0.5, 0.5);
							CATransform3D t = CATransform3DIdentity;
							t.m34 = kCubePageView_M34;
							float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
							pc_v_next.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation), 0.0, 1.0, 0.0);
							pc_v_next.center = CGPointMake((self.frame.size.width/2.0)+fProject, floorf(self.frame.size.height/2.0));
							[self addSubview:pc_v_next];
						}
					}
					else {
						rotation = (fPercent*90.0);
						
						if(pc_v_current != nil){
							pc_v_current.layer.anchorPoint = CGPointMake(0.5, 0.5);
							CATransform3D t = CATransform3DIdentity;
							t.m34 = kCubePageView_M34;
							float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
							pc_v_current.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation), 0.0, 1.0, 0.0);
							pc_v_current.center = CGPointMake((self.frame.size.width/2.0)+fProject, floorf(self.frame.size.height/2.0));
							[self addSubview:pc_v_current];
						}
						
						rotation = (fPercent*90.0)+90.0;
						
						if(pc_v_prev != nil){
							pc_v_prev.layer.anchorPoint = CGPointMake(0.5, 0.5);
							CATransform3D t = CATransform3DIdentity;
							t.m34 = kCubePageView_M34;
							float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
							pc_v_prev.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation+180.0), 0.0, 1.0, 0.0);
							pc_v_prev.center = CGPointMake((self.frame.size.width/2.0)-fProject, floorf(self.frame.size.height/2.0));
							[self addSubview:pc_v_prev];
						}
					}
				}
			}
		}
	}
}

// Private

- (void)private_cleanPrev
{
	if(pc_v_prev != nil){
		[pc_v_prev removeFromSuperview];
	}
	pc_v_prev = nil;
}

- (void)private_cleanCurrent
{
	if(pc_v_current != nil){
		[pc_v_current removeFromSuperview];
	}
	pc_v_current = nil;
}

- (void)private_cleanNext
{
	if(pc_v_next != nil){
		[pc_v_next removeFromSuperview];
	}
	pc_v_next = nil;
}

- (void)private_showPage:(int)iCurrent
{
	if((pc_pages != nil) && ([pc_pages count] > 0)){
		int iPrev = -1;
		int iNext = -1;
		
		iPrev = iCurrent-1;
		if(iPrev < 0){
			iPrev = [pc_pages count]-1;
		}
		if(iPrev == iCurrent){
			iPrev = -1;
		}
		
		iNext = iCurrent+1;
		if(iNext >= [pc_pages count]){
			iNext = 0;
		}
		if(iNext == iCurrent){
			iNext = -1;
		}
		
		[self private_cleanPrev];
		[self private_cleanCurrent];
		[self private_cleanNext];
		
		pc_v_current = [pc_pages objectAtIndex:iCurrent];
		pc_v_current.layer.anchorPoint = CGPointMake(0.5, 0.5);
		pc_v_current.layer.transform = CATransform3DIdentity;
		pc_v_current.center = CGPointMake(floorf(self.frame.size.width/2.0), floorf(self.frame.size.height/2.0));
		[self addSubview:pc_v_current];
		
		if(iPrev >= 0){
			pc_v_prev = [pc_pages objectAtIndex:iPrev];
			pc_v_prev.layer.anchorPoint = CGPointMake(0.5, 0.5);
			CATransform3D t = CATransform3DIdentity;
			t.m34 = kCubePageView_M34;
			pc_v_prev.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(pc_width_page/2.0)), kCubePageView_toRadians(180.0+90.0), 0.0, 1.0, 0.0);
			pc_v_prev.center = CGPointMake((self.frame.size.width/2.0)-(pc_width_page/2.0), floorf(self.frame.size.height/2.0));
			[self addSubview:pc_v_prev];
		}
		
		if(iNext >= 0){
			pc_v_next = [pc_pages objectAtIndex:iNext];
			pc_v_next.layer.anchorPoint = CGPointMake(0.5, 0.5);
			CATransform3D t = CATransform3DIdentity;
			t.m34 = kCubePageView_M34;
			pc_v_next.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(pc_width_page/2.0)), kCubePageView_toRadians(90.0), 0.0, 1.0, 0.0);
			pc_v_next.center = CGPointMake((self.frame.size.width/2.0)+(pc_width_page/2.0), floorf(self.frame.size.height/2.0));
			[self addSubview:pc_v_next];
		}
	}
}

- (void)private_animPages:(int)iCurrent
{
	if((pc_pages != nil) && ([pc_pages count] > 0)){
		pc_direction = CubePageView_Direction_None;
		if(iCurrent < pc_current_page){
			if((pc_current_page-iCurrent) > (([pc_pages count]-(pc_current_page+1))+iCurrent)){
				pc_direction = CubePageView_Direction_Next;
			}
			else{
				pc_direction = CubePageView_Direction_Prev;
			}
		}
		else if(iCurrent > pc_current_page){
			if((iCurrent-pc_current_page) > (([pc_pages count]-(iCurrent+1))+pc_current_page)){
				pc_direction = CubePageView_Direction_Prev;
			}
			else{
				pc_direction = CubePageView_Direction_Next;
			}
		}
		else{
			pc_current_page = iCurrent;
			[self private_delegate:pc_current_page];
		}
		
		if(pc_direction != CubePageView_Direction_None){
			[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
				float fPercent = 0.0;
				float rotation = 0.0;
				
				if(pc_direction == CubePageView_Direction_Next){
					fPercent = 0.0;
					
					rotation = (fPercent*90.0)+90.0;
					
					if(pc_v_current != nil){
						pc_v_current.layer.anchorPoint = CGPointMake(0.5, 0.5);
						CATransform3D t = CATransform3DIdentity;
						t.m34 = kCubePageView_M34;
						float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
						pc_v_current.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation+180.0), 0.0, 1.0, 0.0);
						pc_v_current.center = CGPointMake((self.frame.size.width/2.0)-fProject, floorf(self.frame.size.height/2.0));
						[self addSubview:pc_v_current];
					}
					
					rotation = (fPercent*90.0);
					
					if(pc_v_next != nil){
						pc_v_next.layer.anchorPoint = CGPointMake(0.5, 0.5);
						CATransform3D t = CATransform3DIdentity;
						t.m34 = kCubePageView_M34;
						float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
						pc_v_next.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation), 0.0, 1.0, 0.0);
						pc_v_next.center = CGPointMake((self.frame.size.width/2.0)+fProject, floorf(self.frame.size.height/2.0));
						[self addSubview:pc_v_next];
					}
				}
				else {
					fPercent = 1.0;
					
					rotation = (fPercent*90.0);
					
					if(pc_v_current != nil){
						pc_v_current.layer.anchorPoint = CGPointMake(0.5, 0.5);
						CATransform3D t = CATransform3DIdentity;
						t.m34 = kCubePageView_M34;
						float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
						pc_v_current.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation), 0.0, 1.0, 0.0);
						pc_v_current.center = CGPointMake((self.frame.size.width/2.0)+fProject, floorf(self.frame.size.height/2.0));
						[self addSubview:pc_v_current];
					}
					
					rotation = (fPercent*90.0)+90.0;
					
					if(pc_v_prev != nil){
						pc_v_prev.layer.anchorPoint = CGPointMake(0.5, 0.5);
						CATransform3D t = CATransform3DIdentity;
						t.m34 = kCubePageView_M34;
						float fProject = (pc_width_page/2.0)*sinf(kCubePageView_toRadians(rotation));
						pc_v_prev.layer.transform = CATransform3DRotate(CATransform3DTranslate(t, 0.0, 0.0, -1.0*(fProject)), kCubePageView_toRadians(rotation+180.0), 0.0, 1.0, 0.0);
						pc_v_prev.center = CGPointMake((self.frame.size.width/2.0)-fProject, floorf(self.frame.size.height/2.0));
						[self addSubview:pc_v_prev];
					}
				}
			}completion:^(BOOL finished){
				if(finished){
					pc_current_page = pc_current_page+((pc_direction == CubePageView_Direction_Next)?1:-1);
					if(pc_pages != nil){
						if(pc_current_page < 0){
							pc_current_page = [pc_pages count]-1;
						}
						else if(pc_current_page >= [pc_pages count]){
							pc_current_page = 0;
						}
					}
					[self private_showPage:pc_current_page];
					[self private_animPages:iCurrent];
				}
			}];
		}
	}
}

- (void)private_delegate:(int)idx
{
	if((delegate != nil) && [delegate respondsToSelector:@selector(CubePageView:newPage:)]){
		dispatch_async(dispatch_get_main_queue(), ^{
			if((delegate != nil) && [delegate respondsToSelector:@selector(CubePageView:newPage:)]){
				[delegate CubePageView:self newPage:idx];
			}
		});
	}
}

- (void)dealloc
{
	delegate = nil;
	[self private_cleanCurrent];
	[self private_cleanNext];
	[self private_cleanPrev];
#if !ARC_ENABLED
	[pc_pages release];
#endif
	pc_pages = nil;
	pc_v_prev = nil;
	pc_v_current = nil;
	pc_v_next = nil;
#if !ARC_ENABLED
	[super dealloc];
#endif
}

@end
