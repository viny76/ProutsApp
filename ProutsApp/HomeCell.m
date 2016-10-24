//
//  HomeCell.m
//  Chillin
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "HomeCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+CustomColors.h"

@implementation HomeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CALayer * layer = [self.plusButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:2]; //when radius is 0, the border is a rectangle
    [layer setBackgroundColor:[[UIColor colorWithHexString:@"4054B2"] CGColor]];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
