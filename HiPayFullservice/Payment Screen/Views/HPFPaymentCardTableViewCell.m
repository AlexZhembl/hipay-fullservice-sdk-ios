//
//  HPFPaymentCardTableViewCell.m
//  Pods
//
//  Created by Nicolas FILLION on 27/10/2016.
//
//

#import "HPFPaymentCardTableViewCell.h"

@implementation HPFPaymentCardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)removeDependency {

    //[self removeConstraint:_dependencyConstraint];
    _dependencyConstraint.active = NO;
}

- (void)addDependency {

    //[self removeConstraint:_dependencyConstraint];
    _dependencyConstraint.active = YES;
}

@end
