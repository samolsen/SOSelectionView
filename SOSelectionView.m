//
//  SOSelectionView.m
//  SOSelectionView
//
//  Created by Sam Olsen on 10/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SOSelectionView.h"

#define kSOSelectionViwDefaultAnimationDuration 0.4
#define kSOSelectionViewDragThreshold 25.0

@interface SOSelectionView() <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UITableView * selectionTable;
@property (nonatomic, strong) UIScrollView * swipeView;

- (void)showSelectionTable;
- (void)hideSelectionTable;
- (void)toggleSelectionTable;

@end

@implementation SOSelectionView
@synthesize selectionTable=_selectionTable;
@synthesize swipeView=_swipeView;
@synthesize selectedLabel=_selectedLabel;
@synthesize backgroundView=_backgroundView;

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;
@synthesize selectedIndex=_selectedIndex;

- (void)setDataSource:(id<SOSelectionViewDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
        [self reloadData];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex)
    {
        _selectedIndex = selectedIndex;
        
        if ([_delegate respondsToSelector:@selector(selectionViewDidChangeSelectedIndex:)]) {
            [_delegate selectionViewDidChangeSelectedIndex:self];
        }
    }
    
    _selectedLabel.text = [_dataSource selectionView:self textAtPosition:_selectedIndex];
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    
    _backgroundView.frame = _backgroundView.bounds;
    [_swipeView insertSubview:_backgroundView belowSubview:_selectedLabel];
}

- (void)setupSubviews
{
    _swipeView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _swipeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _swipeView.contentSize = self.bounds.size;
    _swipeView.alwaysBounceHorizontal = YES;
    _swipeView.alwaysBounceVertical = NO;
    _swipeView.delegate = self;
    [self addSubview:_swipeView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelectionTable)];
    [_swipeView addGestureRecognizer:tap];
    
    _selectedLabel = [[UILabel alloc] initWithFrame:_swipeView.bounds];
    _selectedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _selectedLabel.textAlignment = UITextAlignmentCenter;
    _selectedLabel.backgroundColor = [UIColor clearColor];
    [_swipeView addSubview:_selectedLabel];
    
    UIView * stockBackgroundView = [[UIView alloc] initWithFrame:_swipeView.bounds];
    stockBackgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView = stockBackgroundView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)reloadData
{
    NSUInteger itemCount = [_dataSource selectionViewItemCount:self];

    [_selectionTable reloadData];
    self.selectedIndex = (itemCount <= _selectedIndex) ? 0 :  _selectedIndex;
}

#pragma mark - Show and Hide Table

- (void)toggleSelectionTable
{
    _selectionTable == nil ? [self showSelectionTable] : [self hideSelectionTable];
}

- (void)showSelectionTable
{
    UIView * superview = self.superview;
    
    CGRect frame = self.frame;
    frame.size.height = superview.bounds.size.height - frame.origin.y;
    
    CGRect swipeFrame = _swipeView.frame;
    swipeFrame.origin.y = frame.size.height - swipeFrame.size.height;
    
    CGRect tableFrame = CGRectMake(0.0, 0.0, swipeFrame.size.width, frame.size.height - swipeFrame.size.height);
    tableFrame.origin.y = - tableFrame.size.height;
    _selectionTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _selectionTable.dataSource = self;
    _selectionTable.delegate = self;
    [self addSubview:_selectionTable];
    
    tableFrame.origin.y = 0.0;

    NSTimeInterval animationDuration;
    if ([_delegate respondsToSelector:@selector(selection)]) 
    {
        animationDuration = [_delegate selectionViewAnimationDuration:self];
    }
    else 
    {
        animationDuration = kSOSelectionViwDefaultAnimationDuration;
    }
    
    [superview bringSubviewToFront:self];
    [UIView animateWithDuration:animationDuration 
                     animations:^{
                         self.frame = frame;
                         _swipeView.frame = swipeFrame;
                         _selectionTable.frame = tableFrame;
                     }];
}

- (void)hideSelectionTable
{
    CGRect frame = self.frame;
    frame.size = _swipeView.bounds.size;
    
    CGRect tableFrame = _selectionTable.frame;
    tableFrame.origin.y = - tableFrame.size.height;
    
    NSTimeInterval animationDuration;
    if ([_delegate respondsToSelector:@selector(selection)]) {
        animationDuration = [_delegate selectionViewAnimationDuration:self];
    }
    else {
        animationDuration = kSOSelectionViwDefaultAnimationDuration;
    }
    
    [UIView animateWithDuration:animationDuration 
                     animations:^{
                         _swipeView.frame = _swipeView.bounds;
                         _selectionTable.frame = tableFrame;
                         self.frame = frame;
                     } 
                     completion:^(BOOL finished) {
                         [_selectionTable removeFromSuperview];
                         _selectionTable = nil;
                     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource selectionViewItemCount:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"SOSelectionIdentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) 
    {
        if ([_delegate respondsToSelector:@selector(selectionViewConfigurableTableViewCell:)]) 
        {
            cell = [_delegate selectionViewConfigurableTableViewCell:self];
            _selectionTable.rowHeight = cell.bounds.size.height;
        }

        else 
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    cell.textLabel.text = [_dataSource selectionView:self textAtPosition:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [self hideSelectionTable];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    const CGFloat threshold = kSOSelectionViewDragThreshold;

    if (scrollView.contentOffset.x > threshold) 
    {
        if (_selectedIndex < [_dataSource selectionViewItemCount:self] - 1)
        {
            self.selectedIndex = _selectedIndex + 1;
        }
    }
    
    else if (scrollView.contentOffset.x < -threshold) 
    {
        if (_selectedIndex > 0)
        {
            self.selectedIndex = _selectedIndex - 1;
        }
    }
}

@end
