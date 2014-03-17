/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at
 
    http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import <Foundation/Foundation.h>
#import "CMISAtomPubExtensionDataParserBase.h"
#import "CMISAcl.h"
#import "CMISAceParser.h"

@class CMISAclParser;

@protocol CMISAclParserDelegate <NSObject>
@required
/// parses acl delegate method
- (void)aclParser:(CMISAclParser *)aclParser didFinishParsingAcl:(CMISAcl *)acl;
@end

@interface CMISAclParser : CMISAtomPubExtensionDataParserBase <NSXMLParserDelegate, CMISAceParserDelegate>

@property (nonatomic, strong) CMISAcl *acl;

/// Designated Initializer
- (id)initAclParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAclParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

/// parses acl
+(id)aclParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAclParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end
