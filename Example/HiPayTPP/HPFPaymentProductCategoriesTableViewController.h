//
//  HPFPaymentProductCategoriesTableViewController.h
//  HiPayTPP
//
//  Created by Jonathan Tiret on 29/11/2015.
//  Copyright © 2015 Jonathan TIRET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPFPaymentProductCategoriesTableViewController : UITableViewController
{
    NSMutableSet *selectedPaymentProducts;
}

@property (nonatomic, readonly) NSSet *selectedPaymentProducts;

- (instancetype)initWithSelectedPaymentProducts:(NSSet *)selectedPaymentProducts;

@end
