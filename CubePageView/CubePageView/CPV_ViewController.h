//
//  CPV_ViewController.h
//  CubePageView
//
//  Created by Guillaume Salva on 1/14/13.
//  Copyright (c) 2013 Ghinzu_iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CubePageView.h"

@interface CPV_ViewController : UIViewController <CubePageView_Delegate>

@property (nonatomic, strong) CubePageView *pages;

@property (nonatomic, strong) IBOutlet UILabel *nb_pages;

- (IBAction)numberPagesChange:(id)sender;

@end
