//
//  HPTOperationMapperTests.m
//  HiPayTPP
//
//  Created by Jonathan TIRET on 09/10/2015.
//  Copyright © 2015 Jonathan TIRET. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <HiPayTPP/HPTAbstractMapper+Decode.h>

@interface HPTOperationMapperTests : XCTestCase

@end

@implementation HPTOperationMapperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithWrongData
{
    NSDictionary *rawData = @{
                              @"wrongData": @"anything",
                              };
    
    XCTAssertNil([[HPTOperationMapper alloc] initWithRawData:rawData]);
    
}

- (void)testEnumMapping
{

    NSDictionary *operationMapping = @{@"capture": @(HPTOperationTypeCapture),
                                       @"refund": @(HPTOperationTypeRefund),
                                       @"cancel": @(HPTOperationTypeCancel),
                                       @"acceptChallenge": @(HPTOperationTypeAcceptChallenge),
                                       @"denyChallenge": @(HPTOperationTypeDenyChallenge)};
    
    
    XCTAssertEqualObjects([HPTOperationMapper operationTypeMapping], operationMapping);
}

@end
