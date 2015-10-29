//
//  HPTForwardPaymentProductViewController.m
//  Pods
//
//  Created by Jonathan TIRET on 27/10/2015.
//
//

#import "HPTForwardPaymentProductViewController.h"
#import "HPTGatewayClient.h"
#import <SafariServices/SafariServices.h>
#import <WebKit/WebKit.h>
#import "HPTForwardViewController.h"
#import "HPTAbstractPaymentProductViewController_Protected.h"

@interface HPTForwardPaymentProductViewController ()

@end

@implementation HPTForwardPaymentProductViewController

- (instancetype)initWithPaymentPageRequest:(HPTPaymentPageRequest *)paymentPageRequest andSelectedPaymentProduct:(HPTPaymentProduct *)paymentProduct
{
    self = [super initWithPaymentPageRequest:paymentPageRequest];
    if (self) {
        _paymentProduct = paymentProduct;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Forward controller

- (void)forwardViewControllerDidCancel:(HPTForwardViewController *)viewController
{
    [self refreshTransactionStatus:transaction];
}

- (void)forwardViewController:(HPTForwardViewController *)viewController didEndWithTransaction:(HPTTransaction *)theTransaction
{
    [self checkTransactionStatus:theTransaction];
}

- (void)forwardViewController:(HPTForwardViewController *)viewController didFailWithError:(NSError *)error
{
    [self checkTransactionError:error];
}

#pragma mark - Payment workflow

- (void)paymentButtonTableViewCellDidTouchButton:(HPTPaymentButtonTableViewCell *)cell
{
    HPTOrderRequest *orderRequest = [[HPTOrderRequest alloc] initWithOrderRelatedRequest:self.paymentPageRequest];
    
    orderRequest.paymentProductCode = self.paymentProduct.code;
    
    cell.loading = YES;
    
    [[HPTGatewayClient sharedClient] requestNewOrder:orderRequest withCompletionHandler:^(HPTTransaction *theTransaction, NSError *error) {
       
        if (theTransaction != nil) {
            transaction = theTransaction;
            
            if (transaction.forwardUrl != nil) {
                
                HPTForwardViewController *viewController = [HPTForwardViewController relevantForwardViewControllerWithTransaction:transaction];
                
                viewController.delegate = self;
                
                [self presentViewController:viewController animated:YES completion:nil];
            }
            
            else {
                [self checkTransactionStatus:transaction];
            }
        }
        
        else {
            [self checkTransactionError:error];
        }
        
        cell.loading = NO;

    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [@"Payer par " stringByAppendingString:self.paymentProduct.paymentProductDescription];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Vous allez être redirigé afin de pouvoir procéder au paiement.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentButton" forIndexPath:indexPath];
    
    ((HPTPaymentButtonTableViewCell *)cell).delegate = self;
    
    return cell;
}


@end
