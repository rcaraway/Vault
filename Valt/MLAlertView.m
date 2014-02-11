//
//  MLAlertView.m
//  MLAlertView
//
//  Copyright (c) 2013 Maximilian Litteral.
//  See LICENSE for full license agreement.
//

#import "MLAlertView.h"
#import "HTAutocompleteManager.h"
#import "HTAutocompleteTextField.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static UIFont * standardFont;
static UIColor * standardColor;
static UIColor * loadingColor;
static UIColor * failureColor;
static UIColor * successColor;

@interface MLAlertView () <UITextFieldDelegate>
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property(nonatomic, copy) NSString * cancelTitle;
@property(nonatomic, copy) NSString * message;
@property(nonatomic, copy) NSString * title;
@property(nonatomic, strong) UITextView *messageView;
@property(nonatomic, strong) UIButton * cancelButton;
@property(nonatomic, strong) NSArray * otherButtonTitles;
@property(nonatomic, strong) NSMutableArray * otherButtons;
@property(nonatomic, strong) UIView * buttonView;
@property(nonatomic, strong) UIActivityIndicatorView * loader;
@property(nonatomic, strong) UIView * titleBack;

@property(nonatomic, strong) UIView * dimView;

@end

@implementation MLAlertView

+(void)initialize
{
    standardFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:19];
    standardColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:239.0/255.0 alpha:1.000];
    loadingColor = [UIColor purpleColor];
    successColor = [UIColor greenColor];
    failureColor = [UIColor redColor];
}

#pragma mark -

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Actions

- (void)show
{
    self.alpha = 0.0;
    self.dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.dimView setBackgroundColor:[UIColor clearColor]];

    self.frame = CGRectMake(CGRectGetMidX(self.dimView.frame)-(self.frame.size.width/2.0), CGRectGetMidY(self.dimView.frame)-(self.frame.size.height/2.0)-350, self.frame.size.width, self.frame.size.height);
    if (self.loginTextField){
        [self.loginTextField becomeFirstResponder];
    }else if (self.passwordTextField){
        [self.passwordTextField becomeFirstResponder];
    }
    [self.dimView addSubview:self];
    [[[UIApplication sharedApplication] windows][0] addSubview:self.dimView];
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:.74 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseInOut   animations:^{
        self.alpha = 1.0;
        [self.dimView setBackgroundColor:[UIColor colorWithWhite:.2 alpha:.75]];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y+260, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss
{
    [self endEditing:YES];
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.dimView];
    CGPoint squareCenterPoint = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame));
    UIOffset attachmentPoint = UIOffsetMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame));
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self offsetFromCenter:attachmentPoint attachedToAnchor:squareCenterPoint];
    [animator addBehavior:attachmentBehavior];
    self.attachmentBehavior = attachmentBehavior;
    UIGravityBehavior *gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[self]];
    gravityBeahvior.magnitude = 4;
    gravityBeahvior.angle = DEGREES_TO_RADIANS(100);
    [animator addBehavior:gravityBeahvior];
    
    self.gravityBehavior = gravityBeahvior;
    self.animator = animator;
    [UIView animateWithDuration:.7 animations:^{
        self.dimView.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [self.dimView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

-(void)loadWithText:(NSString *)text
{
    if (!self.loader){
        [self setupLoader];
    }
    [UIView animateWithDuration:.3 animations:^{
        self.loader.alpha = 1;
        self.title = self.titleLabel.text;
        self.buttonView.userInteractionEnabled = NO;
        self.titleLabel.text=text;
        [self.loader startAnimating];
    }];
}

-(void)setupLoader
{
    self.loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loader setCenter:CGPointMake(CGRectGetWidth(self.frame)-20, 20)];
    [self.loader setAlpha:0];
    [self addSubview:self.loader];
}

-(void)dismissWithSuccessTitle:(NSString *)title
{
    [UIView animateWithDuration:.3 animations:^{
        [self.titleBack setBackgroundColor:successColor];
        self.titleLabel.text = title;
        self.loader.alpha = 0;
        [self.loader stopAnimating];
    }];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.6];
}

-(void)showFailWithTitle:(NSString *)title
{
    [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x-10, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setFrame:CGRectMake(self.frame.origin.x+20, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setFrame:CGRectMake(self.frame.origin.x-10, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
            } completion:^(BOOL finished) {
            }];
        }];
    }];
    self.loader.alpha = 0;
    [self.loader stopAnimating];
    self.buttonView.userInteractionEnabled = YES;
    self.titleLabel.text = title;
    [self performSelector:@selector(showNormal) withObject:nil afterDelay:1.5];
}

-(void)showNormal
{
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.titleLabel.text = self.title;
        [self.titleBack setBackgroundColor:standardColor];
    } completion:nil];
    
}

- (void)alertButtonWasTapped:(UIButton *)button {
  
  if(self.delegate!=nil)
  {
      if (self.passwordTextField && self.loginTextField){
          [self.delegate alertView:self clickedButtonAtIndex:button.tag withEmail:self.loginTextField.text password:self.passwordTextField.text];
      }else if (self.passwordTextField){
          [self.delegate alertView:self clickedButtonAtIndex:button.tag withText:self.passwordTextField.text];
      }else{
         [self.delegate alertView:self clickedButtonAtIndex:button.tag];
      }
  } else if (self.buttonDidTappedBlock!=nil){
    self.buttonDidTappedBlock(self, button.tag);
  }
}

-(void)clearText
{
    self.loginTextField.text = @"";
    self.passwordTextField.text = @"";
}

#pragma mark - initializers

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles
{
    return [self initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles usingBlockWhenTapButton:(MLAlertTapButtonBlock)tapButtonBlock
{
  self = [self initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
  
  self.buttonDidTappedBlock = tapButtonBlock;
  
  return self;
}

-(instancetype)initWithTitle:(NSString *)title textFields:(BOOL)textFields delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *)confirmButtonTitle
{
    self = super.init;
    if (self){
        _delegate = delegate;
        self.title = title;
        self.cancelTitle = cancelButtonTitle;
        if (confirmButtonTitle)
            self.otherButtonTitles = @[confirmButtonTitle];
        CGFloat currentWidth = 280;
        CGFloat extraHeight = [self detmineExtraHeight];
        CGRect boundingRect = CGRectMake(0, 0, currentWidth, 80);
        CGFloat height = boundingRect.size.height + 16.0+44+extraHeight;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(20, (screenHeight-height)/2-80, 280, height);
        self.backgroundColor = standardColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        [self setupTitleLabel];
        [self setupLoginField];
        [self setupPasswordField];
        [self setupButtonViewWithYOrigin:height-extraHeight height:extraHeight];
        if (self.cancelTitle) {
            [self setupCancelButton];
        }
        NSInteger count = [_otherButtonTitles count];
        self.otherButtons = [NSMutableArray arrayWithCapacity:count];
        for (int i=0; i<count; i++) {
            [self setupButtonTitleAtIndex:i forCount:count];
        }
        [self addHorizontalMotionEffect];

    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
    self = [super init];
    if (self) {
        _delegate = delegate;
        self.title = title;
        self.message = message;
        self.cancelTitle = cancelButtonTitle;
        self.otherButtonTitles = otherButtonTitles;
        CGFloat currentWidth = 280;
        CGFloat extraHeight = [self detmineExtraHeight];
        CGSize maximumSize = CGSizeMake(currentWidth, CGFLOAT_MAX);
        CGRect boundingRect = [message boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : standardFont} context:nil];
        CGFloat height = boundingRect.size.height + 16.0+44+extraHeight;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(20, (screenHeight-height)/2, 280, height);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        [self setupTitleLabel];
        [self setupMessageViewWithBoundingRect:boundingRect];
        [self setupButtonViewWithYOrigin:height-extraHeight height:extraHeight];
        if (self.cancelTitle) {
            [self setupCancelButton];
        }
        NSInteger count = [_otherButtonTitles count];
        self.otherButtons = [NSMutableArray arrayWithCapacity:count];
        for (int i=0; i<count; i++) {
            [self setupButtonTitleAtIndex:i forCount:count];
        }
        [self addHorizontalMotionEffect];
    }
    return self;
}

-(instancetype)initWithTextfieldWithPlaceholder:(NSString *)placeholder title:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *)confirmButtonTitle
{
    self = super.init;
    if (self){
        _delegate = delegate;
        self.title = title;
        self.cancelTitle = cancelButtonTitle;
        if (confirmButtonTitle)
            self.otherButtonTitles = @[confirmButtonTitle];
        CGFloat currentWidth = 280;
        CGFloat extraHeight = [self detmineExtraHeight];
        CGRect boundingRect = CGRectMake(0, 0, currentWidth, 44);
        CGFloat height = boundingRect.size.height + 16.0+44+extraHeight;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(20, (screenHeight-height)/2-44, 280, height);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        [self setupTitleLabel];
        [self setupPasswordField];
        self.loginTextField.autocompleteType = RCAutocompleteTypeUsername;
        self.loginTextField = nil;
        self.passwordTextField.placeholder = placeholder;
        [self setupButtonViewWithYOrigin:height-extraHeight height:extraHeight];
        if (self.cancelTitle) {
            [self setupCancelButton];
        }
        NSInteger count = [_otherButtonTitles count];
        self.otherButtons = [NSMutableArray arrayWithCapacity:count];
        for (int i=0; i<count; i++) {
            [self setupButtonTitleAtIndex:i forCount:count];
        }
        [self addHorizontalMotionEffect];
    }
    return self;
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.loginTextField){
        if (self.passwordTextField){
             [self.passwordTextField becomeFirstResponder];
        }
    }else{
        if (!self.loginTextField && self.delegate){
            [self.delegate alertView:self clickedButtonAtIndex:1 withText:self.passwordTextField.text];
        }else if (self.delegate){
            [self.delegate alertView:self clickedButtonAtIndex:1 withEmail:self.loginTextField.text password:self.passwordTextField.text];
        }
    }
    return YES;
}

#pragma mark - View Setup

-(void)setupLoginField
{
    self.loginTextField = [[HTAutocompleteTextField  alloc] initWithFrame:CGRectMake(22, 44, 280-44, 44)];
    self.loginTextField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.loginTextField.backgroundColor = self.backgroundColor;
    self.loginTextField.font = standardFont;
    self.loginTextField.delegate = self;
    self.loginTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.loginTextField.placeholder = @"Email";
    self.loginTextField.autocompleteType = RCAutoCompleteTypeEmailOnly;
    self.loginTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.loginTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.loginTextField.returnKeyType = UIReturnKeyNext;
    [self addSubview:self.loginTextField];
}

-(void)setupPasswordField
{
    self.passwordTextField = [[UITextField  alloc] initWithFrame:CGRectMake(22, (self.loginTextField!=nil ? 88:44), 280-44, 44)];
    self.passwordTextField.delegate = self;
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.placeholder = @"Master Password";
    self.passwordTextField.font = standardFont;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.passwordTextField];
}

-(void)setupButtonViewWithYOrigin:(CGFloat)yOrigin height:(CGFloat)height
{
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, yOrigin, 280, height)];
    CALayer *horizontalBorder = [CALayer layer];
    horizontalBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    horizontalBorder.backgroundColor = [UIColor colorWithRed:0.824 green:0.827 blue:0.831 alpha:1.000].CGColor;
    [self.buttonView.layer addSublayer:horizontalBorder];
    
    if ((self.cancelTitle && [self.otherButtonTitles count] == 1) || ([self.otherButtonTitles count] <= 2 && !self.cancelTitle)) {
        CALayer *centerBorder = [CALayer layer];
        centerBorder.frame = CGRectMake(self.buttonView.frame.size.width/2+0.5, 0.0f, 0.5f, self.buttonView.frame.size.height);
        centerBorder.backgroundColor = [UIColor colorWithRed:0.824 green:0.827 blue:0.831 alpha:1.000].CGColor;
        [self.buttonView.layer addSublayer:centerBorder];
    }
    [self addSubview:self.buttonView];
}

-(void)setupTitleLabel
{
    self.titleBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
    _titleBack.backgroundColor = standardColor;
    [self addSubview:_titleBack];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
    _titleLabel.text = self.title;
    _titleLabel.textColor = [UIColor colorWithWhite:.37 alpha:1];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [_titleBack addSubview:_titleLabel];
}

-(void)setupMessageViewWithBoundingRect:(CGRect)boundingRect
{
    self.messageView = [[UITextView alloc] init];
    CGFloat newLineHeight = boundingRect.size.height + 16.0;
    _messageView.frame = CGRectMake(0, 44, 280, newLineHeight);
    _messageView.text = self.message;
    _messageView.font = standardFont;
    _messageView.editable = NO;
    _messageView.dataDetectorTypes = UIDataDetectorTypeAll;
    _messageView.userInteractionEnabled = NO;
    _messageView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_messageView];
}

-(void)setupCancelButton
{
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([self.otherButtonTitles count] == 1) {
        _cancelButton.frame = CGRectMake(0, 0, 141, 44);
    }
    else _cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.buttonView.frame)-44, 280, 44);
    [_cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithWhite:.37 alpha:1] forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithRed:0.769 green:0.000 blue:0.071 alpha:1.000] forState:UIControlStateHighlighted];
    [_cancelButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:217.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:1.000]] forState:UIControlStateHighlighted];
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_cancelButton addTarget:self action:@selector(didCancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.tag = 0;
    [self.cancelButton setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.000]];
    [self.buttonView addSubview:_cancelButton];
}

-(void)didCancel
{
    [self.delegate alertViewTappedCancel:self];
    [self dismiss];
}

-(void)setupButtonTitleAtIndex:(NSInteger)index forCount:(NSInteger) count
{
    UIButton *otherTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (count == 1 && !self.cancelTitle) {
        //1 other button and no cancel button
        otherTitleButton.frame = CGRectMake(0, 0, 280, 44);
        otherTitleButton.tag = 0;
    }
    else if ((count == 2 && !self.cancelTitle) || (count == 1 && self.cancelTitle)) {
        // 2 other buttons, no cancel or 1 other button and cancel
        otherTitleButton.tag = index+1;
        otherTitleButton.frame = CGRectMake(140, 0, 142, 44);
    }
    else if (count >= 2) {
        
        if (self.cancelTitle) {
            otherTitleButton.frame = CGRectMake(0, (index*44)+0.5, 280, 44);
            otherTitleButton.tag = index+1;
        }
        else {
            otherTitleButton.frame = CGRectMake(0, index*44, 280, 44);
            otherTitleButton.tag = index;
        }
        CALayer *horizontalBorder = [CALayer layer];
        horizontalBorder.frame = CGRectMake(0.0f, 0, 1, otherTitleButton.frame.size.height);
        horizontalBorder.backgroundColor = standardColor.CGColor;
        [self.buttonView.layer addSublayer:horizontalBorder];
    }
    [otherTitleButton addTarget:self action:@selector(alertButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
    [otherTitleButton setTitle:_otherButtonTitles[index] forState:UIControlStateNormal];
    [otherTitleButton setTitleColor:[UIColor colorWithWhite:.37 alpha:1] forState:UIControlStateNormal];
    [otherTitleButton setTitleColor:[UIColor colorWithRed:0.071 green:0.431 blue:0.965 alpha:1.000] forState:UIControlStateHighlighted];
    [otherTitleButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:205.0/255.0 green:202.0/255.0 blue:217.0/255.0 alpha:1.000]] forState:UIControlStateHighlighted];
    [otherTitleButton setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.000]];
    otherTitleButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.otherButtons addObject:otherTitleButton];
    [self.buttonView addSubview:otherTitleButton];
}

-(void)addHorizontalMotionEffect
{
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [self addMotionEffect:group];
}

#pragma mark - Convenience


-(CGFloat)detmineExtraHeight
{
    CGFloat extraHeight = 0;
    if ((_cancelTitle && [_otherButtonTitles count] <= 1) || ([_otherButtonTitles count] < 2 && !_cancelTitle)) {
        extraHeight = 44;
    }
    else if (_cancelTitle && [_otherButtonTitles count] > 1) {
        extraHeight = 44 + [_otherButtonTitles count]*44;
    }
    return extraHeight;
}

@end
