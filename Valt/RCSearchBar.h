//
//  RCSearchBar.h
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCSearchBarDelegate;

@interface RCSearchBar : UIView <UITextFieldDelegate>

@property(nonatomic, weak) id<RCSearchBarDelegate> delegate;
@property(nonatomic, strong) UIView * searchBack;
@property(nonatomic, copy, readonly) NSString * text;
@property(nonatomic, strong) UITextField * searchField;

@end


@protocol RCSearchBarDelegate <NSObject>

-(void)searchBarDidBeginEditing:(RCSearchBar * )searchBar;
-(void)searchBarDidEndEditing:(RCSearchBar * )searchBar;
-(void)searchBar:(RCSearchBar *)searchBar textDidChange:(NSString *)searchText;
-(void)searchBarCancelTapped:(RCSearchBar *)searchBar;

@end