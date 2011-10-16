//
//  SOViewController.m
//  SOSelectionView
//
//  Created by Sam Olsen on 10/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SOViewController.h"

#import "SOSelectionView.h"

@interface SOViewController() <SOSelectionViewDataSource>
@end

@implementation SOViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

static NSArray * selectionStrings = nil;

+ (NSArray *)selectionStrings
{
    if (!selectionStrings)
    {
        selectionStrings = [[NSArray alloc] initWithObjects:
                            @"Zero",
                            @"One",
                            @"Two",
                            @"Three",
                            @"Four",
                            @"Five",
                            nil];
    }

    return selectionStrings;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 50.0);
    SOSelectionView * selectionView = [[SOSelectionView alloc] initWithFrame:frame];
    selectionView.dataSource = self;
    [self.view addSubview:selectionView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - SOSelectionViewDataSource

- (NSUInteger)selectionViewItemCount:(SOSelectionView *)selectionView
{
    return [[SOViewController selectionStrings] count];
}

- (NSString *)selectionView:(SOSelectionView *)selectionView textAtPosition:(NSUInteger)position
{
    return [[SOViewController selectionStrings] objectAtIndex:position];
}

@end
