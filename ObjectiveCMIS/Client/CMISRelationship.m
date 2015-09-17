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

#import "CMISRelationship.h"
#import "CMISSession.h"
#import "CMISErrors.h"
#import "CMISLog.h"
#import "CMISOperationContext.h"

@interface CMISRelationship ()

@property (nonatomic, strong) CMISSession *session;

@end

@implementation CMISRelationship
/**
 initialiser
 */
- (id)initWithObjectData:(CMISObjectData *)relationshipData
                    session:(CMISSession *)session {
    self = [super init];
    if (self) {
        self.identifier = relationshipData.identifier;
        self.baseType = relationshipData.baseType;
        self.session = session;
        self.properties = relationshipData.properties;
    }
    return self;
}

/**
 *  Retrieves the link of relationship,  e.g.  uploald link of a folder
 *  completionBlock returns the link object as CMIS object or nil if unsuccessful
 */
- (CMISRequest*) retrieveLink:(void (^)(CMISObject *object, NSError *error))completionBlock {
    NSString *sourceId = [self.properties propertyValueForId:@"cmis:sourceId"];
    
    if (sourceId == nil) {
        CMISLogError(@"No sourceId found for relationship id %@", self.identifier);
        // TODO: populate error properly
        NSString *detailedDescription = [NSString stringWithFormat:@"No sourceId found for relationship id %@", self.identifier];
        NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:detailedDescription];
        
        completionBlock(nil, error);
    }
    
    return [self.session retrieveObject:sourceId completionBlock:completionBlock];
}

@end
