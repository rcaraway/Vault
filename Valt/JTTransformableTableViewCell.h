/*
 * This file is part of the JTGestureBasedTableView package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>

typedef enum {
    JTTransformableTableViewCellStyleUnfolding,
    JTTransformableTableViewCellStylePullDown,
} JTTransformableTableViewCellStyle;


@protocol JTTransformableTableViewCell <NSObject>

@property (nonatomic, assign) CGFloat  finishedHeight;
@property (nonatomic, strong) UIColor *tintColor;

@end


@interface JTTransformableTableViewCell : UITableViewCell <JTTransformableTableViewCell>

@property(nonatomic, strong) UILabel * customLabel;

+ (JTTransformableTableViewCell *)transformableTableViewCellWithStyle:(JTTransformableTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(UIColor *)colorForFraction:(CGFloat)fraction;

@end


@interface JTUnfoldingTableViewCell : JTTransformableTableViewCell


@end


@interface JTPullDownTableViewCell : JTTransformableTableViewCell


@end
