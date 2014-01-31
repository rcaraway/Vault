//
//  LBAlertSheet.m
//  Dashr
//
//  Created by Laurin Brandner on 14.02.13.
//
//

#import "LBActionSheet.h"
#import "UIView+QuartzEffects.h"

typedef enum _LBActionSheetButtonType {
    LBActionSheetDefaultButtonType = 0,
    LBActionSheetCancelButtonType = 1,
    LBActionSheetDestructiveButtonType = 2,
    LBActionSheetCustomButtonType = 3
} LBActionSheetButtonType;

const CGFloat kLBActionSheetAnimationDuration = 0.3f;
static UIWindow* blockWindow = nil;

@interface LBActionSheet () {
    NSArray* controls;
    NSDictionary* buttonBackgroundImages;
    NSDictionary* buttonTitleAttributes;
    UIImageView* backgroundView;
}


@property (nonatomic, getter = isVisible) BOOL visible;
@property (nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UIView * dimView;
@property(nonatomic, strong) UITapGestureRecognizer * tapGesture;
@property (nonatomic, strong) NSArray* controls;
@property (nonatomic, strong) NSDictionary* buttonBackgroundImages;
@property (nonatomic, strong) NSDictionary* buttonTitleAttribtues;
@property (nonatomic, strong) UIImageView* backgroundView;
@property (nonatomic, readonly) UIWindow* blockWindow;

-(void)_initialize;

-(void)insertControlsObject:(UIView *)object atIndex:(NSUInteger)index;

-(UIButton *)_buttonWithTitle:(NSString*)title orImage:(UIImage*)image type:(LBActionSheetButtonType)type;

-(void)_setButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state type:(LBActionSheetButtonType)type;
-(UIImage *)_buttonBackgroundImageForState:(UIControlState)state type:(LBActionSheetButtonType)type;

-(void)_buttonWasPressed:(UIButton*)sender;
-(void)_applicationWillTerminate:(NSNotification*)notification;

-(void)_dismiss:(BOOL)animated completion:(void (^)(BOOL finished))completion;
-(void)_showInView:(UIView *)view;
-(void)_animateFromTransform:(CGAffineTransform)fromTransform fromAlpha:(CGFloat)fromAlpha toTransform:(CGAffineTransform)toTransform toAlpha:(CGFloat)toAlpha duration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;

@end
@implementation LBActionSheet

@synthesize delegate, titleLabel, visible, dismissOnOtherButtonClicked, controls, buttonBackgroundImages, backgroundView, controlOffsets, contentInsets;

#pragma mark Accessors

-(void)addControls:(NSSet *)objects {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons addObjectsFromArray:objects.allObjects];
    self.controls = newButtons;
    
    [objects enumerateObjectsUsingBlock:^(UIView* view, BOOL *stop) {
        [self addSubview:view];
    }];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)addControlsObject:(UIView *)object {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons addObject:object];
    self.controls = newButtons;
    
    [self addSubview:object];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)insertControlsObject:(UIView *)object atIndex:(NSUInteger)index {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons insertObject:object atIndex:index];
    self.controls = newButtons;
    
    [self addSubview:object];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)removeControls:(NSSet *)objects
{
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons removeObjectsInArray:objects.allObjects];
    self.controls = newButtons;
    [objects enumerateObjectsUsingBlock:^(UIView* view, BOOL *stop) {
        [view removeFromSuperview];
    }];
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)removeControlsObject:(UIButton *)object {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons addObject:object];
    self.controls = newButtons;
    
    [object removeFromSuperview];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(NSUInteger)numberOfButtons {
    return self.controls.count;
}

-(NSUInteger)cancelButtonIndex {
    __block NSUInteger index = NSNotFound;
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == LBActionSheetCancelButtonType) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(NSUInteger)destructiveButtonIndex {
    __block NSUInteger index = NSNotFound;
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == LBActionSheetDestructiveButtonType) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(NSUInteger)firstOtherButtonIndex {
    __block NSUInteger index = NSNotFound;
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == LBActionSheetDefaultButtonType) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(void)setVisible:(BOOL)value {
    if (visible != value) {
        visible = value;
        if (value) {
            CGRect newFrame = self.frame;
            newFrame.size = [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.blockWindow.frame), 0.0f)];
            newFrame.origin.y = CGRectGetHeight(self.blockWindow.frame)-CGRectGetHeight(newFrame);
            self.frame = newFrame;
            
            [self setupDimView];
            
            [self setNeedsLayout];
            
            
            [self.blockWindow makeKeyAndVisible];
            [self.blockWindow addSubview:self.dimView];
            [self.blockWindow addSubview:self];
            [self.blockWindow bringSubviewToFront:self];
        }
        else {
            [self.dimView removeFromSuperview];
            [self removeFromSuperview];
            self.blockWindow.hidden = YES;
        }
    }
}

-(void)setupDimView
{
    if (!self.dimView){
        CGRect screen = [UIScreen mainScreen].bounds;
        self.dimView = [[UIView  alloc] initWithFrame:screen];
        [self.dimView setBackgroundColor:[UIColor clearColor]];
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedDimView)];
        [self.dimView addGestureRecognizer:self.tapGesture];
    }
}

-(void)tappedDimView
{
    [self.delegate actionSheet:self clickedButtonAtIndex:self.cancelButtonIndex];
    [self _dismiss:YES completion:^(BOOL finished) {
    }];
}

-(NSString*)title {
    return self.titleLabel.text;
}

-(void)setTitle:(NSString *)value {
    if (value) {
        UILabel* newTitleLabel = [UILabel new];
        newTitleLabel.backgroundColor = [UIColor clearColor];
        newTitleLabel.textAlignment = NSTextAlignmentCenter;
        newTitleLabel.text = value;
        newTitleLabel.textColor = [UIColor whiteColor];
        newTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        newTitleLabel.numberOfLines = 0;
        self.titleLabel = newTitleLabel;
        [self addSubview:self.titleLabel];
    }
    else {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    }
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(NSAttributedString*)attributedTitle {
    return self.titleLabel.attributedText;
}

-(void)setAttributedTitle:(NSAttributedString *)value {
    self.titleLabel.attributedText = value;
}

-(void)setBackgroundImage:(UIImage *)value {
    if (![self.backgroundView.image isEqual:value]) {
        if (value) {
            if (!self.backgroundView) {
                UIImageView* newBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
                newBackgroundView.image = value;
                [self addSubview:newBackgroundView];
                [self sendSubviewToBack:newBackgroundView];
                self.backgroundView = newBackgroundView;
            }
            
            self.backgroundView.image = value;
        }
        else {
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
        }
    }
}

-(void)setControlOffsets:(UIEdgeInsets)value {
    if (!UIEdgeInsetsEqualToEdgeInsets(controlOffsets, value)) {
        controlOffsets = value;
        
        [self setNeedsLayout];
    }
}

-(void)setContentInsets:(UIEdgeInsets)value {
    if (!UIEdgeInsetsEqualToEdgeInsets(contentInsets, value)) {
        contentInsets = value;
        
        [self setNeedsLayout];
    }
}

-(UIWindow*)blockWindow {
    if (blockWindow) {
        return blockWindow;
    }
    
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    window.windowLevel = UIWindowLevelAlert;
    
    blockWindow = window;
    return window;
}


#pragma mark -
#pragma mark Initialization

-(id)initWithTitle:(NSString *)title delegate:(id <LBActionSheetDelegate>)obj cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super init];
    if (self) {
        if (cancelButtonTitle || destructiveButtonTitle || otherButtonTitles) {
            NSMutableArray* newButtons = [NSMutableArray new];
            if (destructiveButtonTitle) {
                UIButton * button =[self _buttonWithTitle:destructiveButtonTitle orImage:nil type:LBActionSheetDestructiveButtonType];
                [button setBackgroundColor:[UIColor redColor]];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [newButtons addObject:button];
            }
            if (otherButtonTitles) {
                va_list otherTitles;
                va_start(otherTitles, otherButtonTitles);
                for (NSString* otherTitle = otherButtonTitles; otherTitle; otherTitle = (va_arg(otherTitles, NSString*))) {
                    UIButton * button = [self _buttonWithTitle:otherTitle orImage:nil type:LBActionSheetDefaultButtonType];
                    [button setBackgroundColor:[UIColor lightGrayColor]];
                    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [newButtons addObject:button];
                }
                va_end(otherTitles);
            }
            if (cancelButtonTitle) {
                UIButton * button =[self _buttonWithTitle:cancelButtonTitle orImage:nil type:LBActionSheetCancelButtonType];
                [button setBackgroundColor:[UIColor colorWithWhite:.5 alpha:1]];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [newButtons addObject:button];
            }
            [newButtons enumerateObjectsUsingBlock:^(UIView* button, NSUInteger idx, BOOL *stop) {
                [self addSubview:button];
            }];
            self.controls = newButtons;
        }

        
        self.backgroundColor = [UIColor clearColor];
        self.title = title;
        self.delegate = obj;
        [self _initialize];
    }
    
    return self;
}

-(void)addCornerMask
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}


-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    
    return self;
}

-(void)_initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    [self initializeAppearance];
    self.dismissOnOtherButtonClicked = YES;
    self.controlOffsets = UIEdgeInsetsMake(4.0f, 21.0f, 4.0f, 21.0f);
    self.contentInsets = UIEdgeInsetsMake(7.0f, 0.0f, 7.0f, 0.0f);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
}

-(void)initializeAppearance {}

#pragma mark -
#pragma mark Memory

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Appearance

-(UIButton *)_buttonWithTitle:(NSString *)title orImage:(UIImage *)image type:(LBActionSheetButtonType)type {
    UIButton* newButton = [UIButton new];
    newButton.tag = type;
    
    if (title) {
        [newButton setTitle:title forState:UIControlStateNormal];
    }
    else {
        [newButton setImage:image forState:UIControlStateNormal];
        newButton.adjustsImageWhenHighlighted = NO;
    }
    [newButton addTarget:self action:@selector(_buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return newButton;
}

-(NSUInteger)addButtonWithTitle:(NSString *)title {
    UIButton* newButton = [self _buttonWithTitle:title orImage:nil type:LBActionSheetDefaultButtonType];
    [self addControlsObject:newButton];
    
    return self.controls.count-1;
}

-(NSUInteger)addButtonWithImage:(UIImage *)image {
    UIButton* newButton = [self _buttonWithTitle:nil orImage:image type:LBActionSheetDefaultButtonType];
    [self addControlsObject:newButton];
    
    return self.controls.count-1;
}

-(void)insertButtonWithTitle:(NSString *)title atIndex:(NSUInteger)index {
    UIButton* newButton = [self _buttonWithTitle:title orImage:nil type:LBActionSheetDefaultButtonType];
    [self insertControlsObject:newButton atIndex:index];
}

-(void)insertButtonWithImage:(UIImage *)image atIndex:(NSUInteger)index {
    UIButton* newButton = [self _buttonWithTitle:nil orImage:image type:LBActionSheetDefaultButtonType];
    [self insertControlsObject:newButton atIndex:index];
}

-(void)insertControl:(UIView *)control atIndex:(NSUInteger)index {
    control.tag = LBActionSheetCustomButtonType;
    [self insertControlsObject:control atIndex:index];
}

-(NSString *)buttonTitleAtIndex:(NSUInteger)buttonIndex {
    UIButton* button = self.controls[buttonIndex];
    return [button titleForState:UIControlStateNormal];
}

-(UIButton *)buttonAtIndex:(NSUInteger)buttonIndex {
    return self.controls[buttonIndex];
}

-(void)_setButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state type:(LBActionSheetButtonType)type {
    NSNumber* typeKey = @(type);
    NSNumber* stateKey = @(state);
    
    NSMutableDictionary* newButtonBackroundImages = self.buttonBackgroundImages.mutableCopy ?: [NSMutableDictionary new];
    NSMutableDictionary* newTypeInfo = [newButtonBackroundImages[typeKey] mutableCopy] ?: [NSMutableDictionary new];
    [newTypeInfo setObject:image forKey:stateKey];
    [newButtonBackroundImages setObject:newTypeInfo forKey:typeKey];
    
    self.buttonBackgroundImages = newButtonBackroundImages;
    
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag != LBActionSheetCustomButtonType && [obj isKindOfClass:[UIButton class]]) {
            [obj setBackgroundImage:[self _buttonBackgroundImageForState:UIControlStateNormal type:obj.tag] forState:UIControlStateNormal];
            [obj setBackgroundImage:[self _buttonBackgroundImageForState:UIControlStateHighlighted type:obj.tag] forState:UIControlStateHighlighted];
        }
    }];
}

-(void)layoutSubviews
{
    UIEdgeInsets insets = self.contentInsets;
    UIEdgeInsets offsets = self.controlOffsets;
    CGFloat maxWidth = CGRectGetWidth(self.bounds)-offsets.left-offsets.right-insets.left-insets.right;
    __block CGPoint origin = CGPointMake(offsets.left+insets.left, offsets.top+insets.top);
    
    self.backgroundView.frame = self.bounds;
    CGSize neededTitleSize = [self.titleLabel sizeThatFits:CGSizeMake(maxWidth, 100.0f)];
    CGRect newTitleLabelFrame = (CGRect){origin, {maxWidth, neededTitleSize.height}};
    self.titleLabel.frame = newTitleLabelFrame;
    
    if (CGRectGetHeight(newTitleLabelFrame)>0.0f) {
        origin.y = CGRectGetMaxY(newTitleLabelFrame)+offsets.top+offsets.bottom;
    }
    
    [self.controls enumerateObjectsUsingBlock:^(UIView* control, NSUInteger idx, BOOL *stop) {
        [control setCornerRadius:5];
        CGSize neededSize = CGSizeMake(self.bounds.size.width-22, 44);
        control.frame = (CGRect){{CGRectGetWidth(self.bounds)/2.0f-neededSize.width/2.0f, origin.y}, neededSize};
        origin.y += CGRectGetHeight(control.frame)+offsets.top+offsets.bottom;
    }];
}

-(CGSize)sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = self.contentInsets;
    UIEdgeInsets offsets = self.controlOffsets;
    CGFloat maxWidth = size.width-offsets.left-offsets.right-insets.left-insets.right;
    CGSize neededTitleSize = [self.titleLabel sizeThatFits:CGSizeMake(maxWidth, 100.0f)];
    __block CGFloat neededHeight = CGSizeEqualToSize(neededTitleSize, CGSizeZero) ? 0.0f : neededTitleSize.height+offsets.top+offsets.bottom;
    
    [self.controls enumerateObjectsUsingBlock:^(UIView* control, NSUInteger idx, BOOL *stop) {
        CGSize neededSize;
        if (control.tag == LBActionSheetCustomButtonType) {
            neededSize = control.frame.size;
            if (CGSizeEqualToSize(neededSize, CGSizeZero)) {
                neededSize = [control sizeThatFits:control.frame.size];
            }
        }
        else {
            neededSize = [control sizeThatFits:control.frame.size];
        }
        neededHeight += neededSize.height+offsets.top+offsets.bottom;
    }];
    
    return CGSizeMake(size.width, self.controls.count * 50 + 22 + neededTitleSize.height);
}

#pragma mark -
#pragma mark Presentation

-(void)_animateFromTransform:(CGAffineTransform)fromTransform fromAlpha:(CGFloat)fromAlpha toTransform:(CGAffineTransform)toTransform toAlpha:(CGFloat)toAlpha duration:(CGFloat)duration completion:(void (^)(BOOL))completion {
    self.transform = fromTransform;


    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState animations:^{

    } completion:completion];
}

-(void)_showInView:(UIView *)view
{
    if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.delegate willPresentActionSheet:self];
    }
    
    self.visible = YES;
    CGAffineTransform fromTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, CGRectGetHeight(self.bounds));

    self.transform = fromTransform;
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
       self.dimView.backgroundColor = [UIColor colorWithWhite:.1 alpha:.6];
        self.transform = CGAffineTransformIdentity;
        [self addCornerMask];
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
            [self.delegate didPresentActionSheet:self];
        }
    }];
}

-(void)showInView:(UIView *)view {
    [self _showInView:view];
}

-(void)showFromTabBar:(UITabBar *)tabBar {
    [self _showInView:tabBar.superview];
}

-(void)showFromToolbar:(UIToolbar *)toolbar {
    [self _showInView:toolbar.superview];
}

-(void)_dismiss:(BOOL)animated completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.1 initialSpringVelocity:.9 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.dimView.backgroundColor = [UIColor clearColor];
        self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.bounds.size.height);
    } completion:^(BOOL finished) {
        self.visible = NO;
        completion(finished);
    }];
}

-(void)dismissWithClickedButtonIndex:(NSUInteger)buttonIndex animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:self willDismissWithButtonIndex:buttonIndex];
    }
    
    [self _dismiss:animated completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self didDismissWithButtonIndex:buttonIndex];
        }
    }];
}

#pragma mark -
#pragma mark Other Methods

-(void)_buttonWasPressed:(UIButton *)sender {
    NSUInteger index = [self.controls indexOfObject:sender];
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:index];
    }
    
    BOOL dismiss = (sender.tag != LBActionSheetDefaultButtonType) ?: self.dismissOnOtherButtonClicked;
    if (dismiss) {
        [self dismissWithClickedButtonIndex:index animated:YES];
    }
}

-(void)_applicationWillTerminate:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.delegate actionSheetCancel:self];
    }
    
    [self _dismiss:NO completion:nil];
}

#pragma mark -

@end
