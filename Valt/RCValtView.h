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
-(void)open;
-(void)lock;

@end

extern NSString * const valtViewDidOpen;
extern NSString * const valtViewDidLock;