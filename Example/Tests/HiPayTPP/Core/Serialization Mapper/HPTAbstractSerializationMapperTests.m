//
//  HPTAbstractSerializationMapperTests.m
//  HiPayTPP
//
//  Created by Jonathan TIRET on 14/10/2015.
//  Copyright © 2015 Jonathan TIRET. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface HPTAbstractSerializationMapperTests : XCTestCase

@end

@implementation HPTAbstractSerializationMapperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    id request = [[NSObject alloc] init];

    HPTAbstractSerializationMapper *mapper = [HPTAbstractSerializationMapper mapperWithRequest:request];
    
    XCTAssertEqual(mapper.request, request);
}

- (void)testShouldSuclass {

    HPTAbstractSerializationMapper *mapper = [HPTAbstractSerializationMapper mapperWithRequest:[[NSObject alloc] init]];
    
    XCTAssertThrows(mapper.serializedRequest);
}

@end
