//
//  RCValtView.h
//  Valt
//
//  Created by Robert Caraway on 1/13/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCValtView : UIImageView

-(void)shake;
-(void)openCompletion:(void(^)())completion;
-(void)lockCompletion:(void(^)())completion;

@end
