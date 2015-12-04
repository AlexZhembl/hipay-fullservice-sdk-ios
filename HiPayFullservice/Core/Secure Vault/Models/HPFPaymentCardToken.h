//
//  HPFPaymentCardToken.h
//  Pods
//
//  Created by Jonathan TIRET on 18/09/2015.
//
//

#import <Foundation/Foundation.h>
#import "HPFPaymentMethod.h"

@interface HPFPaymentCardToken : HPFPaymentMethod

@property (nonatomic, readonly, nonnull) NSString *token;
@property (nonatomic, readonly, nonnull) NSString *brand;
@property (nonatomic, readonly, nonnull) NSString *requestID;
@property (nonatomic, readonly, nonnull) NSString *pan;
@property (nonatomic, readonly, nonnull) NSString *cardHolder;
@property (nonatomic, readonly, nonnull) NSNumber *cardExpiryMonth;
@property (nonatomic, readonly, nonnull) NSNumber *cardExpiryYear;
@property (nonatomic, readonly, nonnull) NSString *issuer;
@property (nonatomic, readonly, nonnull) NSString *country;
@property (nonatomic, readonly, nullable) NSString *domesticNetwork;

- (BOOL)isEqualToPaymentCardToken:(HPFPaymentCardToken  * _Nonnull )object;

@end
