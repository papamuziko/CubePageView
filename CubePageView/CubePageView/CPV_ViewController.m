//
//  CPV_ViewController.m
//  CubePageView
//
//  Created by Guillaume Salva on 1/14/13.
//  Copyright (c) 2013 Ghinzu_iOS. All rights reserved.
//

#import "CPV_ViewController.h"

@interface CPV_ViewController ()

@end

@implementation CPV_ViewController

@synthesize pages;
@synthesize nb_pages;

- (void)private_setNewNumberOfPages:(int)nb
{
    if(nb > 0){
        int idx = [self.pages currentPage];
        
        NSMutableArray *ma = [[NSMutableArray alloc] init];
        int i;
        UILabel *l = nil;
        for (i=0; i<nb; i++) {
            l = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.pages.frame.size.width, self.pages.frame.size.height)];
            l.backgroundColor = [UIColor whiteColor];
            l.text = [NSString stringWithFormat:@"%d", i];
            l.textAlignment = UITextAlignmentCenter;
            l.textColor = [UIColor blackColor];
            l.font = [UIFont systemFontOfSize:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)?100.0:40.0];
            [ma addObject:l];
            [l release];
        }
        [self.pages setPages:[NSArray arrayWithArray:ma]];
        [self.pages selectPage:idx withAnim:NO];
        [ma release];
        
        self.nb_pages.text = [NSString stringWithFormat:@"%d", nb];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        self.pages = [[CubePageView alloc] initWithFrame:CGRectMake(60.0, 150.0, 648.0, 830.0)];
    }
    else{
        self.pages = [[CubePageView alloc] initWithFrame:CGRectMake(10.0, 90.0, 300.0, 350.0)];
    }
    self.pages.backgroundColor = [UIColor clearColor];
    self.pages.delegate = self;
    [self.view addSubview:self.pages];
    [self private_setNewNumberOfPages:4];
}

- (IBAction)numberPagesChange:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    [self private_setNewNumberOfPages:stepper.value];
}

- (void)CubePageView:(CubePageView *)pc newPage:(int)page
{
    NSLog(@"new page : %d", page);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
