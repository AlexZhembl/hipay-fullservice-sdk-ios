//
//  HPTGatewayClient.h
//  Pods
//
//  Created by Jonathan TIRET on 13/10/2015.
//
//

#import <HiPayTPP/HiPayTPP.h>
#import "HPTHTTPClient.h"
#import "HPTClientConfig.h"
#import "HPTAbstractClient.h"

#import "HPTHostedPaymentPage.h"
#import "HPTOperation.h"
#import "HPTTransaction.h"

#import "HPTHostedPaymentPageRequest.h"
#import "HPTOrderRequest.h"

#define HPTGatewayClientBaseURLStage        @"https://stage-secure-gateway.hipay-tpp.com/rest/v1/"
#define HPTGatewayClientBaseURLProduction   @"https://secure-gateway.hipay-tpp.com/rest/v1/"

typedef void (^HPTHostedPaymentPageCompletionBlock)(HPTHostedPaymentPage *hostedPaymentPage, NSError *error);
typedef void (^HPTOperationCompletionBlock)(HPTOperation *operation, NSError *error);
typedef void (^HPTTransactionCompletionBlock)(HPTTransaction *transaction, NSError *error);
typedef void (^HPTTransactionsCompletionBlock)(NSArray *transactions, NSError *error);

@interface HPTGatewayClient : HPTAbstractClient
{
    HPTHTTPClient *HTTPClient;
    HPTClientConfig *clientConfig;
}

- (void)initializeHostedPaymentPageRequest:(HPTHostedPaymentPageRequest *)hostedPaymentPageRequest withCompletionHandler:(HPTHostedPaymentPageCompletionBlock)completionBlock;

- (void)requestNewOrder:(HPTOrderRequest *)orderRequest withCompletionHandler:(HPTTransactionCompletionBlock)completionBlock;

- (void)getTransactionWithReference:(NSString *)transactionReference withCompletionHandler:(HPTTransactionCompletionBlock)completionBlock;

- (void)getTransactionsWithOrderId:(NSString *)orderId withCompletionHandler:(HPTTransactionsCompletionBlock)completionBlock;

@end