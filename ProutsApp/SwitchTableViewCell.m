//
//  SwitchTableViewCell.m
//  Abbvie
//
//  Created by Creatiwity on 20/10/2015.
//  Copyright © 2015 Creatiwity. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.cellSwitch setOnTintColor:[UIColor colorBlueButton]];
}

@end
