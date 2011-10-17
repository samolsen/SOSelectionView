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

/*!
 When the data source changes, refresh the view.
 */
- (void)setDataSource:(id<SOSelectionViewDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
        [self reloadData];
    }
}

/*!
 If the selected index is changed, notify the delegate.
 Sets the text in the _selectedLabel.
 */
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

/*!
 Remove previous view and place background behind the swipeable area.
 */
- (void)setBackgroundView:(UIView *)backgroundView
{
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    
    _backgroundView.frame = _swipeView.frame;
    [self insertSubview:_backgroundView belowSubview:_swipeView];
}


/*!
 Called by initWithFrame: and initWithCoder:
 Initializes swipeable area with the selected label and a white
 background view.
 
 Adds tap gesture to toggle expanded and closed states.
 */
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

/*!
 @see UIView#initWithFrame:
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

/*!
 @see UIView#initWithCoder:
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

/*!
 Refreshes the view when the data source has changed.
 
 Bounds the selected index between 0 and the number
 of items represented less 1.
 */
- (void)reloadData
{
    NSUInteger itemCount = [_dataSource selectionViewItemCount:self];

    [_selectionTable reloadData];
    self.selectedIndex = (itemCount <= _selectedIndex) ? 0 :  _selectedIndex;
}

#pragma mark - Show and Hide Table

/*!
 Expands or collapses view based on current state.
 */
- (void)toggleSelectionTable
{
    _selectionTable == nil ? [self showSelectionTable] : [self hideSelectionTable];
}


/*!
 Expand the view. Fill the parent downward. Place swipeable area at the bottom with
 a table view above.
 */
- (void)showSelectionTable
{
    UIView * superview = self.superview;
    
    // Calculate new frame
    CGRect frame = self.frame;
    frame.size.height = superview.bounds.size.height - frame.origin.y;
    
    // Calculate new position for swipeable area.
    CGRect swipeFrame = _swipeView.frame;
    swipeFrame.origin.y = frame.size.height - swipeFrame.size.height;
    
    // Calculate table view frame.
    CGRect tableFrame = CGRectMake(0.0, 0.0, swipeFrame.size.width, frame.size.height - swipeFrame.size.height);
    // First place table origin.y above 0
    tableFrame.origin.y = - tableFrame.size.height;
    
    // Initialize table and add to view.
    _selectionTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _selectionTable.dataSource = self;
    _selectionTable.delegate = self;
    [self addSubview:_selectionTable];
    
    // Adjust origin for animation.
    tableFrame.origin.y = 0.0;

    // Get animation time. If this is not provided by the delegate
    // we use a default, non-zero time.
    NSTimeInterval animationDuration;
    if ([_delegate respondsToSelector:@selector(selection)]) 
    {
        animationDuration = [_delegate selectionViewAnimationDuration:self];
    }
    else 
    {
        animationDuration = kSOSelectionViwDefaultAnimationDuration;
    }
    
    // Animate view and subviews into new positions.
    [superview bringSubviewToFront:self];
    [UIView animateWithDuration:animationDuration 
                     animations:^{
                         self.frame = frame;
                         _swipeView.frame = swipeFrame;
                         _selectionTable.frame = tableFrame;
                     }];
}


/*!
 Collapse the view, hiding the table view.
 */
- (void)hideSelectionTable
{
    // Reset frame/
    CGRect frame = self.frame;
    frame.size = _swipeView.bounds.size;
    
    // Calculate table frame for animation
    CGRect tableFrame = _selectionTable.frame;
    tableFrame.origin.y = - tableFrame.size.height;
    
    // Get animation time. If this is not provided by the delegate
    // we use a default, non-zero time.
    NSTimeInterval animationDuration;
    if ([_delegate respondsToSelector:@selector(selection)]) {
        animationDuration = [_delegate selectionViewAnimationDuration:self];
    }
    else {
        animationDuration = kSOSelectionViwDefaultAnimationDuration;
    }
    
    // Animate and remove table view on completion.
    [UIView animateWithDuration:animationDuration 
                     animations:^{
                         _swipeView.frame = _swipeView.bounds;
                         _selectionTable.frame = tableFrame;
                         self.frame = frame;
                     } 
                     completion:^(BOOL finished) {
                         [_selectionTable removeFromSuperview];
                         _selectionTable = nil; // Free some memory.
                     }];
}

#pragma mark - UITableViewDataSource

/*!
 @see UITableViewDataSource#tableView:numberOfRowsInSection:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource selectionViewItemCount:self];
}

/*!
 @see UITableViewDataSource#tableView:cellForRowAtIndexPath:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier; // Use a delegate provided reuse identifier if possible.
    if ([_delegate respondsToSelector:@selector(selectionViewTableViewCellReuseIdentifier:)])
    {
        identifier = [_delegate selectionViewTableViewCellReuseIdentifier:self];
    }
    else
    {
        static NSString * defaultIdentifier = @"SOSelectionIdentifier"; // Default reuse identifier.
        identifier = defaultIdentifier;
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier]; // Try to dequeue.
    
    if (!cell) 
    {
        // Let the delegate provide a reuseable table view cell.
        if ([_delegate respondsToSelector:@selector(selectionViewConfigurableTableViewCell:)]) 
        {
            cell = [_delegate selectionViewConfigurableTableViewCell:self];
            _selectionTable.rowHeight = cell.bounds.size.height;
        }

        else // Or default
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    cell.textLabel.text = [_dataSource selectionView:self textAtPosition:indexPath.row]; // Get the text from the data source.
    
    return cell;
}

#pragma mark - UITableViewDelegate

/*!
 @see UITableView#tableView:didSelectRowAtIndexPath:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row; // Set selected index.
    [self hideSelectionTable]; // Collapse view
}

#pragma mark - UIScrollViewDelegate

/*!
 @see UIScrollViewDelegate#scrollViewDidEndDragging:willDecelerate:
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    const CGFloat threshold = kSOSelectionViewDragThreshold; // Use a constant...

    if (scrollView.contentOffset.x > threshold) // Swipe left
    {
        if (_selectedIndex < [_dataSource selectionViewItemCount:self] - 1)
        {
            self.selectedIndex = _selectedIndex + 1;
        }
    }
    
    else if (scrollView.contentOffset.x < -threshold) // Swipe right
    {
        if (_selectedIndex > 0)
        {
            self.selectedIndex = _selectedIndex - 1;
        }
    }
}

@end
