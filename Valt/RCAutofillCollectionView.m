//
//  RCAutofillCollectionView.m
//  Valt
//
//  Created by Rob Caraway on 4/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCAutofillCollectionView.h"
#import "RCAutofillCell.h"

#import "UIColor+RCColors.h"

#import "RCPassword.h"
#import "RCSecureNoteFiller.h"

NSString * const didTapAutofillForWeb = @"didTapAutofillForWeb";

@interface RCAutofillCollectionView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property(nonatomic, strong) NSArray * autofills;
@property(nonatomic, copy) NSString * filterString;

@end

@implementation RCAutofillCollectionView


#pragma mark - Initialization

+(UICollectionViewFlowLayout *)layout
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout  alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    layout.sectionInset = UIEdgeInsetsZero;
    return layout;
}

-(id)initWithPassword:(RCPassword *)password
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 43) collectionViewLayout:[RCAutofillCollectionView layout]];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.password = password;
        self.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [self registerClass:[RCAutofillCell class] forCellWithReuseIdentifier:@"Cell"];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return nil;
}

-(void)setAutofills:(NSArray *)autofills
{
    NSMutableArray * array = [NSMutableArray array];
    if (self.password.username.length > 0){
        [array addObject:self.password.username];
    }
    if (self.password.password.length > 0){
        [array addObject:self.password.password];
    }
    if (self.password.notes.length > 0){
        NSArray * lines = [self.password.notes componentsSeparatedByString:@","];
        NSMutableArray * trimmedLines = [NSMutableArray new];
        for (NSString * line in lines) {
            NSString * trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [trimmedLines addObject:trimmed];
        }
        [array addObjectsFromArray:trimmedLines];
    }
    [array addObjectsFromArray:autofills];
    if (self.filterString.length > 0){
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", self.filterString];
        [array filterUsingPredicate:predicate];
    }
    _autofills = [array copy];
    [self reloadData];
}

#pragma mark - Delegate/DataSource

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     [[NSNotificationCenter defaultCenter] postNotificationName:didTapAutofillForWeb object:self.autofills[indexPath.row]];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCAutofillCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setAutofillText:self.autofills[indexPath.row]];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * autofillText = self.autofills[indexPath.row];
    CGFloat width = [autofillText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}].width;
    return CGSizeMake(width+22, 43);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.autofills.count;
}

#pragma mark - Filtering

-(void)filterWithString:(NSString *)string
{
    self.filterString = string;
    [[RCSecureNoteFiller sharedFiller] autoFillForString:string completion:^(NSArray * array) {
        self.autofills = array;
    }];
}


@end
