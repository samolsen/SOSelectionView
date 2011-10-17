//
//  SOSelectionView.h
//  SOSelectionView
//
//  Created by Sam Olsen on 10/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SOSelectionViewDataSource, SOSelectionViewDelegate;

/*!
 UIView subclass used for selecting an item from an ordered set of data.
 
 In the default state, the view presents a UIScrollView with a label.
 The label displays a string indicating what item is currently selected.
 Swiping the scroll view to the left or right increments or decrements the 
 selected index respectively.
 
 Tapping the scroll view changes the view to an expanded state. The view 
 increases its size downward until it reaches the superview's bottom. The 
 scrollview's bounds remains unchanged and it is placed at the bottom of the 
 frame. Above the scrollview a UITableView is presented from which the user 
 may select an item. Choosing an item from the list, or tapping the scrollview
 again reverts the view to its default state.
 */
@interface SOSelectionView : UIView

/*!
 Label presented in left/right swipe area
 Read-only access provide for customization.
 */
@property (nonatomic, readonly, strong) UILabel * selectedLabel;

/*!
 Background view placed behind the swipeable area.
 */
@property (nonatomic, strong) IBOutlet UIView * backgroundView;

/*!
 Data source for the view
 @see SOSelectionViewDataSource
 */
@property (nonatomic, weak) IBOutlet id<SOSelectionViewDataSource> dataSource;

/*!
 Currently selected index of items in the data source.
 */
@property (nonatomic, readonly) NSUInteger selectedIndex;

/*!
 Delegate for the view.
 @see SOSelectionViewDelegate
 */
@property (nonatomic, weak) IBOutlet id<SOSelectionViewDelegate> delegate;

/*!
 Refreshes the view when the data source has changed.
 */
- (void)reloadData;

@end


/*!
 Data source methods for SOSelectionView
 */
@protocol SOSelectionViewDataSource <NSObject>

@required
/*!
 Number of items the selection view should present.
 @param selectionView  the SOSelectionView
 @return size of data set represented by the view
 */
- (NSUInteger)selectionViewItemCount:(SOSelectionView *)selectionView;

@required
/*!
 String representing data at a position in the data source
 @param selectionView  the SOSelectionView
 @param position  the index of the data being represented
 @return string representing a piece of data
 */
- (NSString *)selectionView:(SOSelectionView *)selectionView textAtPosition:(NSUInteger)position;

@end 

/*!
 Delegate methods for SOSelectionView
 */
@protocol SOSelectionViewDelegate <NSObject>

@optional
/*!
 Called when the selected index changes
 @param selectionView  the SOSelectionView
 */
- (void)selectionViewDidChangeSelectedIndex:(SOSelectionView *)selectionView;

@optional
/*!
 Animation time when showing or hiding the table view.
 Default is defined by kSOSelectionViwDefaultAnimationDuration constant in SOSelectionView.m
 @param selectionView  the SOSelectionView
 @return time in seconds that the animation should last
 */
- (NSTimeInterval)selectionViewAnimationDuration:(SOSelectionView *)selectionView;

@optional
/*!
 Configurable UITableViewCell for the choosing an item from the table view.
 When implementing this you should also implement selectionViewTableViewCellReuseIdentifier:
 @see SOSelectionViewDelegate#selectionViewTableViewCellReuseIdentifier:
 @param selectionView  the SOSelectionView
 @return a table view cell that may have its textLabel text modified
 */
- (UITableViewCell *)selectionViewConfigurableTableViewCell:(SOSelectionView *)selectionView;

@optional
/*! 
 String for table view cell reuse identifier.
 Implementations of selectionViewConfigurableTableViewCell: should use the same value returned
 here when initializing a table view cell.
 @see SOSelectionViewDelegate#selectionViewConfigurableTableViewCell
 @param selectionView  the SOSelectionView
 @return a reuse identifier string
 */
- (NSString *)selectionViewTableViewCellReuseIdentifier:(SOSelectionView *)selectionView;

@end