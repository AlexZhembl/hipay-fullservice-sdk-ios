//
//  SecureVaultClient.m
//  Pods
//
//  Created by Jonathan TIRET on 01/10/2015.
//
//

#import "HPFSecureVaultClient.h"
#import "HPFAbstractClient+Private.h"

HPFSecureVaultClient *HPFSecureVaultClientSharedInstance = nil;

@implementation HPFSecureVaultClient

+ (instancetype)sharedClient
{
    if (HPFSecureVaultClientSharedInstance == nil) {
        HPFSecureVaultClientSharedInstance = [[HPFSecureVaultClient alloc] init];
    }
    
    return HPFSecureVaultClientSharedInstance;
}

- (instancetype)initWithHTTPClient:(HPFHTTPClient *)theHTTPClient clientConfig:(HPFClientConfig *)theClientConfig
{
    self = [super init];
    if (self) {
        HTTPClient = theHTTPClient;
        clientConfig = theClientConfig;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        HTTPClient = [HPFSecureVaultClient createClient];
        clientConfig = [HPFClientConfig sharedClientConfig];
    }
    return self;
}

+ (HPFHTTPClient *)createClient
{
    NSString *baseURL;
    
    switch ([HPFClientConfig sharedClientConfig].environment) {
        case HPFEnvironmentProduction:
            baseURL = HPFSecureVaultClientBaseURLProduction;
            break;
            
        case HPFEnvironmentStage:
            baseURL = HPFSecureVaultClientBaseURLStage;
            break;
    }
    
    return [[HPFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL] username:[HPFClientConfig sharedClientConfig].username password:[HPFClientConfig sharedClientConfig].password];
    
}

- (HPFPaymentCardToken *)paymentCardTokenWithData:(NSDictionary *)rawData
{
    return [[HPFPaymentCardTokenMapper alloc] initWithRawData:rawData].mappedObject;
}

- (id<HPFRequest>)generateTokenWithCardNumber:(NSString *)cardNumber cardExpiryMonth:(NSString *)cardExpiryMonth cardExpiryYear:(NSString *)cardExpiryYear cardHolder:(NSString *)cardHolder securityCode:(NSString *)securityCode multiUse:(BOOL)multiUse andCompletionHandler:(HPFSecureVaultClientCompletionBlock)completionBlock
{
    if (securityCode == nil) {
        securityCode = @"";
    }
    
    NSDictionary *parameters = @{
                                 @"card_number": cardNumber,
                                 @"card_expiry_month": cardExpiryMonth,
                                 @"card_expiry_year": cardExpiryYear,
                                 @"card_holder": cardHolder,
                                 @"cvc": securityCode,
                                 @"multi_use": @(multiUse).stringValue,
                                 };
    
    return [HTTPClient performRequestWithMethod:HPFHTTPMethodPost path:@"token/create" parameters:parameters completionHandler:^(HPFHTTPResponse *response, NSError *error) {
        
        [self manageRequestWithHTTPResponse:response error:error andCompletionHandler:completionBlock];
        
    }];
}

- (id<HPFRequest>)updatePaymentCardWithToken:(NSString *)token requestID:(NSString *)requestID setCardExpiryMonth:(NSString *)cardExpiryMonth cardExpiryYear:(NSString *)cardExpiryYear cardHolder:(NSString *)cardHolder completionHandler:(HPFSecureVaultClientCompletionBlock)completionBlock
{
    NSDictionary *parameters = @{
                                 @"request_id": requestID,
                                 @"token": token,
                                 @"card_expiry_month": cardExpiryMonth,
                                 @"card_expiry_year": cardExpiryYear,
                                 @"card_holder": cardHolder,
                                 };
    
    return [HTTPClient performRequestWithMethod:HPFHTTPMethodPost path:@"token/update" parameters:parameters completionHandler:^(HPFHTTPResponse *response, NSError *error) {
        
        [self manageRequestWithHTTPResponse:response error:error andCompletionHandler:completionBlock];
        
    }];
}

- (id<HPFRequest>)lookupPaymentCardWithToken:(NSString *)token requestID:(NSString *)requestID andCompletionHandler:(HPFSecureVaultClientCompletionBlock)completionBlock
{
    NSDictionary *parameters = @{@"request_id": requestID};
    
    return [HTTPClient performRequestWithMethod:HPFHTTPMethodGet path:[@"token/" stringByAppendingString:token] parameters:parameters completionHandler:^(HPFHTTPResponse *response, NSError *error) {
        
        [self manageRequestWithHTTPResponse:response error:error andCompletionHandler:completionBlock];
        
    }];
}

- (void)manageRequestWithHTTPResponse:(HPFHTTPResponse *)response error:(NSError *)error andCompletionHandler:(HPFSecureVaultClientCompletionBlock)completionBlock
{
    if (completionBlock != nil) {
        
        NSError *resultError = nil;
        HPFPaymentCardToken *resultObject = nil;
        
        if (error == nil) {
            HPFPaymentCardToken *newToken = [self paymentCardTokenWithData:response.body];
            
            if (newToken != nil) {
                resultObject = newToken;
            } else {
                resultError = [NSError errorWithDomain:HPFHiPayTPPErrorDomain code:HPFErrorCodeAPIOther userInfo:@{NSLocalizedFailureReasonErrorKey: @"Malformed server response"}];
            }
        } else {
            resultError = [self errorForResponseBody:response.body andError:error];
        }
        
        if ([NSThread isMainThread]) {
            completionBlock(resultObject, resultError);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(resultObject, resultError);
            });
        }
    }
}

@end
