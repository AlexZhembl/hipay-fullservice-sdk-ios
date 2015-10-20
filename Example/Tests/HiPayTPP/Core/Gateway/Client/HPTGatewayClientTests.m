//
//  HPTGatewayClientTests.m
//  HiPayTPP
//
//  Created by Jonathan TIRET on 13/10/2015.
//  Copyright © 2015 Jonathan TIRET. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HPTGatewayClient+Testing.h"
#import <HiPayTPP/HPTAbstractClient+Private.h>
#import <HiPayTPP/HPTHostedPaymentPageRequestSerializationMapper.h>
#import <HiPayTPP/HPTOrderRequestSerializationMapper.h>

@interface HPTGatewayClientTests : XCTestCase
{
    HPTHTTPClient *mockedHTTPClient;
    HPTGatewayClient *gatewayClient;
}

@end

@implementation HPTGatewayClientTests

- (void)setUp {
    [super setUp];
    
    mockedHTTPClient = [OCMockObject mockForClass:[HPTHTTPClient class]];
    
    gatewayClient = [OCMockObject partialMockForObject:[[HPTGatewayClient alloc] initWithHTTPClient:mockedHTTPClient clientConfig:[HPTClientConfig sharedClientConfig]]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testClientConfig
{
    OCMockObject *clientConfigMock = [OCMockObject mockForClass:[HPTClientConfig class]];
    
    [((HPTClientConfig *)[[clientConfigMock expect] andReturnValue:@(HPTEnvironmentStage)]) environment];
    [((HPTClientConfig *)[[clientConfigMock expect] andReturn:@"user_id"]) username];
    [((HPTClientConfig *)[[clientConfigMock expect] andReturn:@"password"]) password];
    
    id clientConfigClassMock = OCMClassMock([HPTClientConfig class]);
    OCMStub([clientConfigClassMock sharedClientConfig]).andReturn(clientConfigMock);
    
    [HPTGatewayClient createClient];
    
    [clientConfigMock verify];
    OCMVerify([clientConfigClassMock sharedClientConfig]);
}

- (void)testEndpoints
{
    XCTAssertEqualObjects(HPTGatewayClientBaseURLStage, @"https://stage-secure-gateway.hipay-tpp.com/rest/v1/");
    XCTAssertEqualObjects(HPTGatewayClientBaseURLProduction, @"https://secure-gateway.hipay-tpp.com/rest/v1/");
}

- (void)testPerformRequestWihoutCompletionHandler
{
    NSError *HTTPError = [NSError errorWithDomain:HPTHiPayTPPErrorDomain code:HPTErrorCodeHTTPClient userInfo:@{}];
    OCMockObject *HTTPResponse = [OCMockObject mockForClass:[HPTHTTPResponse class]];
    
    [[[((OCMockObject *)mockedHTTPClient) expect] andDo:^(NSInvocation *invocation) {
        
        HPTHTTPClientCompletionBlock passedCompletionBlock;
        [invocation getArgument: &passedCompletionBlock atIndex: 5];
        
        passedCompletionBlock((HPTHTTPResponse *) HTTPResponse, HTTPError);
        
    }] performRequestWithMethod:HPTHTTPMethodPost path:[OCMArg isEqual:@"resource/item"] parameters:[OCMArg isEqual:@{@"hello": @"world"}] completionHandler:OCMOCK_ANY];
    
    [gatewayClient handleRequestWithMethod:HPTHTTPMethodPost path:@"resource/item" parameters:@{@"hello": @"world"} responseMapperClass:[HPTAbstractMapper class] completionHandler:nil];
    
    [(OCMockObject *)gatewayClient verify];
    [(OCMockObject *)mockedHTTPClient verify];
}

- (void)testPerformRequestHTTPError
{
    NSError *HTTPError = [NSError errorWithDomain:HPTHiPayTPPErrorDomain code:HPTErrorCodeHTTPClient userInfo:@{}];
    NSDictionary *body = @{@"response": @(1)};
    OCMockObject *HTTPResponse = [OCMockObject mockForClass:[HPTHTTPResponse class]];
    
    NSError *gatewayError = [NSError errorWithDomain:HPTHiPayTPPErrorDomain code:0 userInfo:@{}];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Loading request"];
    
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {
        XCTAssertNil(object);
        XCTAssertEqual(error, gatewayError);
        [expectation fulfill];
    };
    
    [[[HTTPResponse expect] andReturn:body] body];
    
    [[[(OCMockObject *)gatewayClient expect] andReturn:gatewayError] errorForResponseBody:body andError:HTTPError];
    
    [[[((OCMockObject *)mockedHTTPClient) expect] andDo:^(NSInvocation *invocation) {
        
        HPTHTTPClientCompletionBlock passedCompletionBlock;
        [invocation getArgument: &passedCompletionBlock atIndex: 5];
        
        passedCompletionBlock((HPTHTTPResponse *) HTTPResponse, HTTPError);
        
    }] performRequestWithMethod:HPTHTTPMethodPost path:[OCMArg isEqual:@"resource/item"] parameters:[OCMArg isEqual:@{@"hello": @"world"}] completionHandler:OCMOCK_ANY];
    
    [gatewayClient handleRequestWithMethod:HPTHTTPMethodPost path:@"resource/item" parameters:@{@"hello": @"world"} responseMapperClass:[HPTAbstractMapper class] completionHandler:completionBlock];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
    
    [HTTPResponse verify];
    [(OCMockObject *)gatewayClient verify];
    [(OCMockObject *)mockedHTTPClient verify];
}

- (void)testPerformRequestMalformedResponse
{
    NSDictionary *body = @{@"response": @(1)};
    OCMockObject *HTTPResponse = [OCMockObject mockForClass:[HPTHTTPResponse class]];
    OCMockObject *mockedMapper = [OCMockObject mockForClass:[HPTAbstractMapper class]];
    
    id mapperClassMock = OCMClassMock([HPTAbstractMapper class]);
    OCMStub([mapperClassMock mapperWithRawData:body]).andReturn(nil);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Loading request"];
    
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {
        XCTAssertNil(object);
        XCTAssertEqualObjects(error.domain, HPTHiPayTPPErrorDomain);
        XCTAssertEqual(error.code, HPTErrorCodeAPIOther);
        XCTAssertEqualObjects(error.userInfo[NSLocalizedFailureReasonErrorKey], @"Malformed server response");
        [expectation fulfill];
    };

    [[[HTTPResponse expect] andReturn:body] body];
    
    [[[((OCMockObject *)mockedHTTPClient) expect] andDo:^(NSInvocation *invocation) {
        
        HPTHTTPClientCompletionBlock passedCompletionBlock;
        [invocation getArgument: &passedCompletionBlock atIndex: 5];
        
        passedCompletionBlock((HPTHTTPResponse *) HTTPResponse, nil);
        
    }] performRequestWithMethod:HPTHTTPMethodPost path:[OCMArg isEqual:@"resource/item"] parameters:[OCMArg isEqual:@{@"hello": @"world"}] completionHandler:OCMOCK_ANY];
    
    [gatewayClient handleRequestWithMethod:HPTHTTPMethodPost path:@"resource/item" parameters:@{@"hello": @"world"} responseMapperClass:[HPTAbstractMapper class] completionHandler:completionBlock];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
    
    [HTTPResponse verify];
    [(OCMockObject *)gatewayClient verify];
    [(OCMockObject *)mockedHTTPClient verify];
    [mockedMapper verify];
    OCMVerify([mapperClassMock mapperWithRawData:body]);
}

- (void)testPerformRequestProperResponse
{
    NSDictionary *body = @{@"response": @(1)};
    OCMockObject *HTTPResponse = [OCMockObject mockForClass:[HPTHTTPResponse class]];
    OCMockObject *mockedMapper = [OCMockObject mockForClass:[HPTAbstractMapper class]];
    id mappedObject = [[NSObject alloc] init];
    [[[mockedMapper expect] andReturn:mappedObject] mappedObject];
    
    id mapperClassMock = OCMClassMock([HPTAbstractMapper class]);
    OCMStub([mapperClassMock mapperWithRawData:body]).andReturn(mockedMapper);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Loading request"];
    
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqual(object, mappedObject);
        [expectation fulfill];
    };
    
    [[[HTTPResponse expect] andReturn:body] body];
    
    [[[((OCMockObject *)mockedHTTPClient) expect] andDo:^(NSInvocation *invocation) {
        
        HPTHTTPClientCompletionBlock passedCompletionBlock;
        [invocation getArgument: &passedCompletionBlock atIndex: 5];
        
        passedCompletionBlock((HPTHTTPResponse *) HTTPResponse, nil);
        
    }] performRequestWithMethod:HPTHTTPMethodPost path:[OCMArg isEqual:@"resource/item"] parameters:[OCMArg isEqual:@{@"hello": @"world"}] completionHandler:OCMOCK_ANY];
    
    [gatewayClient handleRequestWithMethod:HPTHTTPMethodPost path:@"resource/item" parameters:@{@"hello": @"world"} responseMapperClass:[HPTAbstractMapper class] completionHandler:completionBlock];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
    
    [HTTPResponse verify];
    [(OCMockObject *)gatewayClient verify];
    [(OCMockObject *)mockedHTTPClient verify];
    [mockedMapper verify];
    OCMVerify([mapperClassMock mapperWithRawData:body]);
}

- (void)testInitiateHostedPaymentPage
{
    id request = [[NSObject alloc] init];
    OCMockObject *mockedSerializationMapper = [OCMockObject mockForClass:[HPTAbstractSerializationMapper class]];
    
    NSDictionary *parameters = @{};
    [[[mockedSerializationMapper expect] andReturn:parameters] serializedRequest];
    
    id mapperClassMock = OCMClassMock([HPTHostedPaymentPageRequestSerializationMapper class]);
    OCMStub([mapperClassMock mapperWithRequest:request]).andReturn(mockedSerializationMapper);
    
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {};
    
    [[(OCMockObject *)gatewayClient expect] handleRequestWithMethod:HPTHTTPMethodPost path:[OCMArg isEqual:@"hpayment"] parameters:parameters responseMapperClass:[HPTHostedPaymentPageMapper class] completionHandler:completionBlock];
    
    [gatewayClient initializeHostedPaymentPageRequest:request withCompletionHandler:completionBlock];
    
    OCMVerify([mapperClassMock mapperWithRequest:request]);
    [(OCMockObject *)gatewayClient verify];
}

- (void)testRequestNewOrder
{
    id request = [[NSObject alloc] init];
    OCMockObject *mockedSerializationMapper = [OCMockObject mockForClass:[HPTAbstractSerializationMapper class]];
    
    NSDictionary *parameters = @{};
    [[[mockedSerializationMapper expect] andReturn:parameters] serializedRequest];
    
    id mapperClassMock = OCMClassMock([HPTOrderRequestSerializationMapper class]);
    OCMStub([mapperClassMock mapperWithRequest:request]).andReturn(mockedSerializationMapper);
    
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {};
    
    [[(OCMockObject *)gatewayClient expect] handleRequestWithMethod:HPTHTTPMethodPost path:[OCMArg isEqual:@"order"] parameters:parameters responseMapperClass:[HPTTransactionMapper class] completionHandler:completionBlock];
    
    [gatewayClient requestNewOrder:request withCompletionHandler:completionBlock];
    
    OCMVerify([mapperClassMock mapperWithRequest:request]);
    [(OCMockObject *)gatewayClient verify];
}

- (void)testTransactionWithReferenceOK
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Loading request"];
    id theObject = [[NSObject alloc] init];
    NSArray *mappedArray = @[theObject];
    
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {
        XCTAssertEqual(object, theObject);
        XCTAssertNil(error);
        [expectation fulfill];
    };
    
    [[[(OCMockObject *)gatewayClient expect] andDo:^(NSInvocation *invocation) {
        
        HPTTransactionsCompletionBlock passedCompletionBlock;
        [invocation getArgument: &passedCompletionBlock atIndex: 6];
        
        passedCompletionBlock(mappedArray, nil);
        
    }] handleRequestWithMethod:HPTHTTPMethodGet path:@"transaction/trId" parameters:@{} responseMapperClass:[HPTTransactionDetailsMapper class] completionHandler:OCMOCK_ANY];
    
    [gatewayClient getTransactionWithReference:@"trId" withCompletionHandler:completionBlock];
    
    [(OCMockObject *)gatewayClient verify];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testTransactionWithReferenceError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Loading request"];
    NSError *theError = [NSError errorWithDomain:HPTHiPayTPPErrorDomain code:0 userInfo:@{}];
    
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {
        XCTAssertEqual(error, theError);
        [expectation fulfill];
    };
    
    [[[(OCMockObject *)gatewayClient expect] andDo:^(NSInvocation *invocation) {
        
        HPTTransactionsCompletionBlock passedCompletionBlock;
        [invocation getArgument: &passedCompletionBlock atIndex: 6];
        
        passedCompletionBlock(nil, theError);
        
    }] handleRequestWithMethod:HPTHTTPMethodGet path:@"transaction/trId" parameters:@{} responseMapperClass:[HPTTransactionDetailsMapper class] completionHandler:OCMOCK_ANY];
    
    [gatewayClient getTransactionWithReference:@"trId" withCompletionHandler:completionBlock];
    
    [(OCMockObject *)gatewayClient verify];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testTransactionDetailsWithOrderId
{
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {};
    
    [[(OCMockObject *)gatewayClient expect] handleRequestWithMethod:HPTHTTPMethodGet path:@"transaction" parameters:@{@"orderid":@"orderId"} responseMapperClass:[HPTTransactionDetailsMapper class] completionHandler:completionBlock];
    
    [gatewayClient getTransactionsWithOrderId:@"orderId" withCompletionHandler:completionBlock];
    
    [(OCMockObject *)gatewayClient verify];
}

- (void)testOperationTypeValues
{
    XCTAssertThrowsSpecificNamed([gatewayClient operationValueForOperationType:HPTOperationTypeUnknown], NSException, NSInvalidArgumentException);
    
    XCTAssertEqualObjects([gatewayClient operationValueForOperationType:HPTOperationTypeCapture], @"capture");
    XCTAssertEqualObjects([gatewayClient operationValueForOperationType:HPTOperationTypeRefund], @"refund");
    XCTAssertEqualObjects([gatewayClient operationValueForOperationType:HPTOperationTypeAcceptChallenge], @"acceptChallenge");
    XCTAssertEqualObjects([gatewayClient operationValueForOperationType:HPTOperationTypeDenyChallenge], @"denyChallenge");
    XCTAssertEqualObjects([gatewayClient operationValueForOperationType:HPTOperationTypeCancel], @"cancel");
}

- (void)testPerformOperation
{
    void (^completionBlock)(id object, NSError *error) = ^void(id object, NSError *error) {};
    
    [[(OCMockObject *)gatewayClient expect] handleRequestWithMethod:HPTHTTPMethodPost path:@"maintenance/transaction/trId" parameters:@{@"operation": @"capture"} responseMapperClass:[HPTOperationMapper class] completionHandler:completionBlock];
    
    [[[(OCMockObject *)gatewayClient expect] andReturn:@"capture"] operationValueForOperationType:HPTOperationTypeCapture];
    
    [gatewayClient performMaintenanceOperation:HPTOperationTypeCapture onTransactionWithReference:@"trId" withCompletionHandler:completionBlock];
    
    [(OCMockObject *)gatewayClient verify];
}

@end
