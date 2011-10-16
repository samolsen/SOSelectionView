//
//  SOSelectionView.h
//  SOSelectionView
//
//  Created by Sam Olsen on 10/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SOSelectionViewDataSource, SOSelectionViewDelegate;

@interface SOSelectionView : UIView
@property (nonatomic, readonly, strong) UILabel * selectedLabel;
@property (nonatomic, strong) IBOutlet UIView * backgroundView;

@property (nonatomic, weak) IBOutlet id<SOSelectionViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<SOSelectionViewDelegate> delegate;
@property (nonatomic, readonly) NSUInteger selectedIndex;


- (void)reloadData;

@end


@protocol SOSelectionViewDataSource <NSObject>
@required
- (NSUInteger)selectionViewItemCount:(SOSelectionView *)selectionView;
- (NSString *)selectionView:(SOSelectionView *)selectionView textAtPosition:(NSUInteger)position;

@end 

@protocol SOSelectionViewDelegate <NSObject>

@optional
- (void)selectionViewDidChangeSelectedIndex:(SOSelectionView *)selectionView;
- (NSTimeInterval)selectionViewAnimationDuration:(SOSelectionView *)selectionView;
- (UITableViewCell *)selectionViewConfigurableTableViewCell:(SOSelectionView *)selectionView;

@end