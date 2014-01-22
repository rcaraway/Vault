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
#import "UIColor+RCColors.m"
#import "RCNetworking.h"

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
    self.backgroundColor = [UIColor listBackground];
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
    self.customLabel.textColor = [self  textColorForFraction:fraction];
    self.customLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    
    self.contentView.backgroundColor = color;
}


@end

@implementation JTPullDownTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/500.f;
        [self.contentView.layer setSublayerTransform:transform];
        [self setupCustomLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor listBackground];
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
    if (self.frame.size.height >= COMMITING_CREATE_CELL_HEIGHT*2){
        if ([[RCNetworking sharedNetwork] loggedIn]){
             self.customLabel.text = @"Release to Sync";
        }else{
             self.customLabel.text = @"Upgrade to Sync";
        }
        self.contentView.frame = CGRectMake(0, (self.frame.size.height - COMMITING_CREATE_CELL_HEIGHT) , self.frame.size.width, COMMITING_CREATE_CELL_HEIGHT);
    }
    else if (self.frame.size.height >= COMMITING_CREATE_CELL_HEIGHT){
        self.customLabel.text = @"Release to Add Item";
        self.contentView.frame = CGRectMake(0, (self.frame.size.height - COMMITING_CREATE_CELL_HEIGHT) , self.frame.size.width, COMMITING_CREATE_CELL_HEIGHT);
    }else{
        self.customLabel.text = @"Pull Down to Create Item";
    }
    CGRect labelRect = CGRectMake(18, fraction * 15, [UIScreen mainScreen].bounds.size.width-36, 30 * fraction);
    CGFloat fontSize = fraction * 20;
    self.customLabel.frame = labelRect;
    self.customLabel.textColor = [self  textColorForFraction:fraction];
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
    CGFloat adjustedFraction = fraction *.5;
    if (fraction == 1){
        adjustedFraction = 1;
    }
    CGFloat red = 0, blue = 0, green = 0, alpha = 0;
    [[UIColor colorWithRed:253.0/255.0 green:245.0/255.0 blue:254.0/255.0 alpha:1] getRed:&red green:&green blue:&blue alpha:&alpha];
    return [UIColor colorWithRed:red*adjustedFraction green:green*adjustedFraction blue:blue*adjustedFraction alpha:1];
}

-(UIColor *)textColorForFraction:(CGFloat)fraction
{
    if (fraction < 1){
        return [UIColor whiteColor];
    }
    return [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:65.0/255.0 alpha:1];
}

-(void)updateSeparatorsWithhFraction:(CGFloat)fraction
{
    if (fraction < 1){
        self.separator1.alpha = 0;
        self.separator2.alpha = 0;
    }else{
        self.separator1.alpha = 1;
        self.separator2.alpha = 1;
        [self.separator1 setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
        [self.separator2 setFrame:CGRectMake(0, 59, self.contentView.frame.size.width, 1)];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat fraction = (self.frame.size.height / self.finishedHeight);
    fraction = MAX(MIN(1, fraction), 0);
    [self updateSeparatorsWithhFraction:fraction];
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.backgroundColor = [UIColor listBackground];
        
        self.separator1 = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        self.separator1.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1];
        self.separator2 = [[UIView  alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
        self.separator2.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1];
        [self.contentView addSubview:self.separator1];
        [self.contentView addSubview:self.separator2];
    }
    return self;
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
