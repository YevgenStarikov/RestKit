//
//  RKURLSpec.m
//  RestKit
//
//  Created by Blake Watters on 6/29/11.
//  Copyright 2011 RestKit
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RKSpecEnvironment.h"
#import "RKURL.h"
#import "NSURL+RestKit.h"

@interface RKURLSpec : RKSpec
@end
    
@implementation RKURLSpec

- (void)testShouldNotExplodeBecauseOfUnicodeCharacters {
    NSException* failed = nil;
    @try {
        [RKURL URLWithBaseURLString:@"http://test.com" resourcePath:@"/places.json?category=Automóviles"];
    }
    @catch (NSException *exception) {
        failed = exception;
    }
    @finally {
        NSAssert((failed == nil), @"No exception should be generated by creating URL with Unicode chars");
    }
}

- (void)testShouldEscapeQueryParameters {
    NSDictionary* queryParams = [NSDictionary dictionaryWithObjectsAndKeys:@"What is your #1 e-mail?", @"question", @"john+restkit@gmail.com", @"answer", nil];
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org" resourcePath:@"/test" queryParameters:queryParams];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/test?answer=john%2Brestkit%40gmail.com&question=What%20is%20your%20%231%20e-mail%3F")));
}

- (void)testShouldHandleNilQueryParameters {
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org" resourcePath:@"/test" queryParameters:nil];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/test")));
}

- (void)testShouldHandleEmptyQueryParameters {
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org" resourcePath:@"/test" queryParameters:[NSDictionary dictionary]];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/test")));
}

- (void)testShouldHandleResourcePathWithoutLeadingSlash {
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org" resourcePath:@"test" queryParameters:nil];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/test")));
}

- (void)testShouldHandleEmptyResourcePath {
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org" resourcePath:@"" queryParameters:nil];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org")));
}

- (void)testShouldHandleBaseURLsWithAPath {
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org/this" resourcePath:@"/test" queryParameters:nil];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/this/test")));
}

- (void)testShouldSimplifyURLsWithSeveralSlashes {
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org//this//" resourcePath:@"/test" queryParameters:nil];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/this/test")));
}

- (void)testShouldPreserveTrailingSlash {
    RKURL* URL = [RKURL URLWithBaseURLString:@"http://restkit.org" resourcePath:@"/test/" queryParameters:nil];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/test/")));    
}

- (void)testShouldReturnTheMIMETypeForURL {
    NSURL *URL = [NSURL URLWithString:@"http://restkit.org/path/to/resource.xml"];
    assertThat([URL MIMETypeForPathExtension], is(equalTo(@"application/xml")));
}

- (void)testInitializationFromStringIsEqualToAbsoluteString {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org"];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org")));
}

- (void)testInitializationFromStringHasNilBaseURL {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org"];
    assertThat([URL baseURL], is(nilValue()));
}

- (void)testInitializationFromStringHasNilResourcePath {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org"];
    assertThat([URL resourcePath], is(nilValue()));
}

- (void)testInitializationFromStringHasNilQueryParameters {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org"];
    assertThat([URL query], is(nilValue()));
    assertThat([URL queryParameters], is(nilValue()));
}

- (void)testInitializationFromStringIncludingQueryParameters {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org/foo?bar=1&this=that"];
    assertThat([URL queryParameters], hasEntries(@"bar", equalTo(@"1"), @"this", equalTo(@"that"), nil));
}

- (void)testInitializationFromURLandResourcePathIncludingQueryParameters {
    NSString *resourcePath = @"/bar?another=option";
    RKURL *URL = [RKURL URLWithBaseURLString:@"http://restkit.org/foo?bar=1&this=that" resourcePath:resourcePath];
    assertThat([URL absoluteString], is(equalTo(@"http://restkit.org/foo/bar?bar=1&this=that&another=option")));
    assertThat([URL queryParameters], hasEntries(@"bar", equalTo(@"1"), 
                                                 @"this", equalTo(@"that"), 
                                                 @"another", equalTo(@"option"), nil));
}

- (void)testInitializationFromNSURL {
    NSURL *URL = [NSURL URLWithString:@"http://restkit.org"];
    RKURL *rkURL = [RKURL URLWithBaseURL:URL];
    assertThat(URL, is(equalTo(rkURL)));
}

- (void)testInitializationFromRKURL {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org"];
    RKURL *rkURL = [RKURL URLWithBaseURL:URL];
    assertThat(URL, is(equalTo(rkURL)));
}

- (void)testInitializationFromNSURLandAppendingOfResourcePath {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org/"];
    RKURL *rkURL = [RKURL URLWithBaseURL:URL resourcePath:@"/entries"];
    assertThat([rkURL absoluteString], equalTo(@"http://restkit.org/entries"));
}

- (void)testMergingOfAdditionalQueryParameters {
    NSURL *URL = [NSURL URLWithString:@"http://restkit.org/search?title=Hacking"];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"Computers" forKey:@"genre"];
    RKURL *newURL = [RKURL URLWithBaseURL:URL resourcePath:nil queryParameters:params];
    assertThat([newURL queryParameters], hasEntries(@"title", equalTo(@"Hacking"), @"genre", equalTo(@"Computers"), nil));
}

- (void)testReplacementOfExistingResourcePath {
    RKURL *URL = [RKURL URLWithBaseURLString:@"http://restkit.org/" resourcePath:@"/articles"];
    RKURL *newURL = [URL URLByReplacingResourcePath:@"/files"];
    assertThat([newURL absoluteString], equalTo(@"http://restkit.org/files"));
    assertThat([newURL resourcePath], equalTo(@"/files"));
}

- (void)testReplacementOfNilResourcePath {
    RKURL *URL = [RKURL URLWithString:@"http://restkit.org/whatever"];
    assertThat([URL resourcePath], is(nilValue()));
    RKURL *newURL = [URL URLByReplacingResourcePath:@"/works"];
    assertThat([newURL resourcePath], is(equalTo(@"/works")));
    assertThat([newURL absoluteString], is(equalTo(@"http://restkit.org/whatever/works")));
}

// TODO: Test...
// TODO: try interpolating the host in the URL...

- (void)testInterpolationOfResourcePath {
    
}

- (void)testInterpolationWithObject {
    
}

@end
