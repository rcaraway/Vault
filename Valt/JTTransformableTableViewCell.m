/*
 * This file is part of the JTGestureBasedTableView package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "JTTransformableTableViewCell.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_NAME @"HelveticaNeue"
#define NORMAL_CELL_FINISHING_HEIGHT 60
#define COMMITING_CREATE_CELL_HEIGHT 60


@implementation JTUnfoldingTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupEverything];
        
    }
    return self;
}

-(void)setupEverything
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1/500.f;
    [self.contentView.layer setSublayerTransform:transform];
    
    [self setupCustomLabel];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.autoresizingMask = UIViewAutoresizingNone;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    self.tintColor = [UIColor whiteColor];
}

-(void)setupCustomLabel
{
    self.customLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 15, [UIScreen mainScreen].bounds.size.width-36, 30)];
    [self.customLabel setBackgroundColor:self.contentView.backgroundColor];
    [self.customLabel setNumberOfLines:1];
    UIFont * helvetica =[UIFont fontWithName:FONT_NAME size:20];
    [self.customLabel setFont:helvetica];
    [self.customLabel setTextColor:[UIColor whiteColor]];
    [self.customLabel setTextAlignment:NSTextAlignmentCenter];
    [self.customLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.customLabel];
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat fraction = (self.frame.size.height / self.finishedHeight);
    fraction = MAX(MIN(1, fraction), 0);
    
    UIColor * color = [self colorForFraction:fraction];
    CGRect labelRect = CGRectMake(18, fraction * 15, [UIScreen mainScreen].bounds.size.width-36, 30 * fraction);
    CGFloat fontSize = fraction * 20;
    if (self.frame.size.height >= COMMITING_CREATE_CELL_HEIGHT){
        self.customLabel.text = @"Release to Add Item";
        self.contentView.frame = CGRectMake(0, (self.frame.size.height - COMMITING_CREATE_CELL_HEIGHT)/2.0 , self.frame.size.width, COMMITING_CREATE_CELL_HEIGHT);
    }else{
        self.customLabel.text = @"Pull Apart to Add Item";
    }
    
    self.customLabel.frame = labelRect;
    self.customLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    
    self.contentView.backgroundColor = color;
}


@end

@implementation JTPullDownTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/500.f;
        [self.contentView.layer setSublayerTransform:transform];
        [self setupCustomLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.autoresizingMask = UIViewAutoresizingNone;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.tintColor = [UIColor whiteColor];
    }
    return self;
}


-(void)setupCustomLabel
{
    self.customLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 15, [UIScreen mainScreen].bounds.size.width-36, 30)];
    [self.customLabel setBackgroundColor:self.contentView.backgroundColor];
    [self.customLabel setNumberOfLines:1];
    UIFont * helvetica =[UIFont fontWithName:FONT_NAME size:20];
    [self.customLabel setFont:helvetica];
    [self.customLabel setTextColor:[UIColor whiteColor]];
    [self.customLabel setTextAlignment:NSTextAlignmentCenter];
    [self.customLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.customLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat fraction = (self.frame.size.height / self.finishedHeight);
    fraction = MAX(MIN(1, fraction), 0);
    
    UIColor * color = [self colorForFraction:fraction];
    
    CGSize contentViewSize = self.contentView.frame.size;
    
    
    CGSize requiredLabelSize;

    // Since sizeWithFont() method has been depreciated, boundingRectWithSize() method has been used for iOS 7.
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        CGRect requiredLabelRect = [self.textLabel.text boundingRectWithSize:contentViewSize
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:self.textLabel.font,
                                                                               NSParagraphStyleAttributeName: paragraphStyle}
                                                                     context:nil];

        requiredLabelSize = requiredLabelRect.size;
    } else {
        requiredLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font
                                            constrainedToSize:contentViewSize
                                                lineBreakMode:NSLineBreakByClipping];
    }
    
    self.contentView.backgroundColor = color;
    if (self.frame.size.height >= COMMITING_CREATE_CELL_HEIGHT){
        self.customLabel.text = @"Release to Add Item";
        self.contentView.frame = CGRectMake(0, (self.frame.size.height - COMMITING_CREATE_CELL_HEIGHT)/2.0 , self.frame.size.width, COMMITING_CREATE_CELL_HEIGHT);
    }else{
        self.customLabel.text = @"Pull Down to Create Item";
    }
    CGRect labelRect = CGRectMake(18, fraction * 15, [UIScreen mainScreen].bounds.size.width-36, 30 * fraction);
    CGFloat fontSize = fraction * 20;
    self.customLabel.frame = labelRect;
    self.customLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];

    
    self.imageView.frame = CGRectMake(10.0 + requiredLabelSize.width + 10.0,
                                      (self.finishedHeight - self.imageView.frame.size.height)/2,
                                      self.imageView.frame.size.width,
                                      self.imageView.frame.size.height);
    
    self.textLabel.frame = CGRectMake(10.0, 0.0, contentViewSize.width - 20.0, self.finishedHeight);
}

@end



#pragma mark -

@implementation JTTransformableTableViewCell

@synthesize finishedHeight, tintColor;


-(UIColor *)colorForFraction:(CGFloat)fraction
{
    return [UIColor colorWithRed:fraction/1.0f green:0 blue:fraction/1.0f alpha:1];
}

+ (JTTransformableTableViewCell *)unfoldingTableViewCellWithReuseIdentifier:(NSString *)reuseIdentifier {
    JTUnfoldingTableViewCell *cell = (id)[[JTUnfoldingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                           reuseIdentifier:reuseIdentifier];
    return cell;
}

+ (JTTransformableTableViewCell *)pullDownTableViewCellWithReuseIdentifier:(NSString *)reuseIdentifier {
    JTPullDownTableViewCell *cell = (id)[[JTPullDownTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                          reuseIdentifier:reuseIdentifier];
    return cell;
}

+ (JTTransformableTableViewCell *)transformableTableViewCellWithStyle:(JTTransformableTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    switch (style) {
        case JTTransformableTableViewCellStylePullDown:
            return [JTTransformableTableViewCell pullDownTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
        case JTTransformableTableViewCellStyleUnfolding:
        default:
            return [JTTransformableTableViewCell unfoldingTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
    }
}

@end
