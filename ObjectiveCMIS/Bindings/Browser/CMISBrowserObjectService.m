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

#import "CMISBrowserObjectService.h"
#import "CMISRequest.h"
#import "CMISHttpResponse.h"
#import "CMISConstants.h"
#import "CMISBrowserUtil.h"
#import "CMISBrowserConstants.h"
#import "CMISURLUtil.h"
#import "CMISFileUtil.h"
#import "CMISErrors.h"
#import "CMISLog.h"

@implementation CMISBrowserObjectService

- (CMISRequest*)retrieveObject:(NSString *)objectId
                        filter:(NSString *)filter
                 relationships:(CMISIncludeRelationship)relationships
              includePolicyIds:(BOOL)includePolicyIds
               renditionFilder:(NSString *)renditionFilter
                    includeACL:(BOOL)includeACL
       includeAllowableActions:(BOOL)includeAllowableActions
               completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    NSString *objectUrl = [self getObjectUrlObjectId:objectId selector:kCMISBrowserJSONSelectorObject];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions boolValue:includeAllowableActions urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships value:[CMISEnums stringForIncludeRelationShip:relationships] urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludePolicyIds boolValue:includePolicyIds urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAcl boolValue:includeACL urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISBrowserJSONParameterSuccinct value:kCMISParameterValueTrue urlString:objectUrl];
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:objectUrl]
                                           session:self.bindingSession
                                       cmisRequest:cmisRequest
                                   completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                       if (httpResponse.statusCode == 200 && httpResponse.data) {
                                           CMISTypeCache *typeCache = [[CMISTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                           [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                               if (error) {
                                                   completionBlock(nil, error);
                                               } else {
                                                   completionBlock(objectData, nil);
                                               }
                                           }];
                                           
                                       } else {
                                           completionBlock(nil, error);
                                       }
                                   }];
    
    return cmisRequest;
}

- (CMISRequest*)retrieveObjectByPath:(NSString *)path
                              filter:(NSString *)filter
                       relationships:(CMISIncludeRelationship)relationships
                    includePolicyIds:(BOOL)includePolicyIds
                     renditionFilder:(NSString *)renditionFilter
                          includeACL:(BOOL)includeACL
             includeAllowableActions:(BOOL)includeAllowableActions
                     completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    NSString *objectUrl = [self getObjectUrlByPath:path selector:kCMISBrowserJSONSelectorObject];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter value:filter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions boolValue:includeAllowableActions urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships value:[CMISEnums stringForIncludeRelationShip:relationships] urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludePolicyIds boolValue:includePolicyIds urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAcl boolValue:includeACL urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISBrowserJSONParameterSuccinct value:kCMISParameterValueTrue urlString:objectUrl];
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:objectUrl]
                                           session:self.bindingSession
                                       cmisRequest:cmisRequest
                                   completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                       if (httpResponse.statusCode == 200 && httpResponse.data) {
                                           CMISTypeCache *typeCache = [[CMISTypeCache alloc] initWithRepositoryId:self.bindingSession.repositoryId bindingService:self];
                                           [CMISBrowserUtil objectDataFromJSONData:httpResponse.data typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                               if (error) {
                                                   completionBlock(nil, error);
                                               } else {
                                                   completionBlock(objectData, nil);
                                               }
                                           }];
                                          
                                       } else {
                                           completionBlock(nil, error);
                                       }
                                   }];
    
    return cmisRequest;
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                                 toFile:(NSString *)filePath
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self downloadContentOfObject:objectId
                                streamId:streamId
                                  toFile:filePath
                                  offset:nil
                                  length:nil
                         completionBlock:completionBlock
                           progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                               if (progressBlock) {
                                   progressBlock(bytesDownloaded, bytesTotal);
                               }
                           }];
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                                 toFile:(NSString *)filePath
                                 offset:(NSDecimalNumber*)offset
                                 length:(NSDecimalNumber*)length
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    return [self downloadContentOfObject:objectId
                                streamId:streamId
                          toOutputStream:outputStream
                                  offset:offset
                                  length:length
                         completionBlock:completionBlock
                           progressBlock:progressBlock];
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                         toOutputStream:(NSOutputStream *)outputStream
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self downloadContentOfObject:objectId
                                streamId:streamId
                          toOutputStream:outputStream
                                  offset:nil
                                  length:nil
                         completionBlock:completionBlock
                           progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                               if (progressBlock) {
                                   progressBlock(bytesDownloaded, bytesTotal);
                               }
                           }];
}

- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                         toOutputStream:(NSOutputStream *)outputStream
                                 offset:(NSDecimalNumber*)offset
                                 length:(NSDecimalNumber*)length
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    
    NSString *rootUrl = [self.bindingSession objectForKey:kCMISBrowserBindingSessionKeyRootFolderUrl];
    
    NSString *contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterStreamId value:streamId urlString:rootUrl];
    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterObjectId value:objectId urlString:contentUrl];
    contentUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISBrowserJSONParameterSelector value:kCMISBrowserJSONSelectorContent urlString:contentUrl];

    unsigned long long streamLength = 0; //TODO do we need this?

    [self.bindingSession.networkProvider invoke:[NSURL URLWithString:contentUrl]
                                  httpMethod:HTTP_GET
                                     session:self.bindingSession
                                outputStream:outputStream
                               bytesExpected:streamLength
                                      offset:offset
                                      length:length
                                 cmisRequest:request
                             completionBlock:^(CMISHttpResponse *httpResponse, NSError *error)
    {
        if (completionBlock) {
          completionBlock(error);
        }
    } progressBlock:progressBlock];
    
    return request;
}

- (CMISRequest*)deleteContentOfObject:(CMISStringInOutParameter *)objectIdParam
                          changeToken:(CMISStringInOutParameter *)changeTokenParam
                      completionBlock:(void (^)(NSError *error))completionBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)changeContentOfObject:(CMISStringInOutParameter *)objectIdParam
                      toContentOfFile:(NSString *)filePath
                             mimeType:(NSString *)mimeType
                    overwriteExisting:(BOOL)overwrite
                          changeToken:(CMISStringInOutParameter *)changeTokenParam
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)changeContentOfObject:(CMISStringInOutParameter *)objectId
               toContentOfInputStream:(NSInputStream *)inputStream
                        bytesExpected:(unsigned long long)bytesExpected
                             filename:(NSString *)filename
                             mimeType:(NSString *)mimeType
                    overwriteExisting:(BOOL)overwrite
                          changeToken:(CMISStringInOutParameter *)changeToken
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)createDocumentFromFilePath:(NSString *)filePath
                                  mimeType:(NSString *)mimeType
                                properties:(CMISProperties *)properties
                                  inFolder:(NSString *)folderObjectId
                           completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                             progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    if (inputStream == nil) {
        CMISLogError(@"Could not find file %@", filePath);
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                 detailedDescription:@"Invalid file"]);
        }
        return nil;
    }
    
    NSError *fileError = nil;
    unsigned long long bytesExpected = [CMISFileUtil fileSizeForFileAtPath:filePath error:&fileError];
    if (fileError) {
        CMISLogError(@"Could not determine size of file %@: %@", filePath, [fileError description]);
    }
    
    return [self createDocumentFromInputStream:inputStream
                                      mimeType:mimeType
                                    properties:properties
                                      inFolder:folderObjectId
                                 bytesExpected:bytesExpected
                               completionBlock:completionBlock
                                 progressBlock:progressBlock];
}

- (CMISRequest*)createDocumentFromInputStream:(NSInputStream *)inputStream
                                     mimeType:(NSString *)mimeType
                                   properties:(CMISProperties *)properties
                                     inFolder:(NSString *)folderObjectId
                                bytesExpected:(unsigned long long)bytesExpected // optional
                              completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                                progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)deleteObject:(NSString *)objectId
                 allVersions:(BOOL)allVersions
             completionBlock:(void (^)(BOOL objectDeleted, NSError *error))completionBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)createFolderInParentFolder:(NSString *)folderObjectId
                                properties:(CMISProperties *)properties
                           completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)deleteTree:(NSString *)folderObjectId
                allVersion:(BOOL)allVersions
             unfileObjects:(CMISUnfileObject)unfileObjects
         continueOnFailure:(BOOL)continueOnFailure
           completionBlock:(void (^)(NSArray *failedObjects, NSError *error))completionBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)updatePropertiesForObject:(CMISStringInOutParameter *)objectIdParam
                               properties:(CMISProperties *)properties
                              changeToken:(CMISStringInOutParameter *)changeTokenParam
                          completionBlock:(void (^)(NSError *error))completionBlock
{
    NSString * message = [NSString stringWithFormat:@"%s is not implemented yet", __PRETTY_FUNCTION__];
    NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
    @throw exception;
}

- (CMISRequest*)retrieveRenditions:(NSString *)objectId
                   renditionFilter:(NSString *)renditionFilter
                          maxItems:(NSNumber *)maxItems
                         skipCount:(NSNumber *)skipCount
                   completionBlock:(void (^)(NSArray *renditions, NSError *error))completionBlock
{
    NSString *objectUrl = [self getObjectUrlObjectId:objectId selector:kCMISBrowserJSONSelectorRenditions];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter value:renditionFilter urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterMaxItems value:[maxItems stringValue] urlString:objectUrl];
    objectUrl = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterSkipCount value:[skipCount stringValue] urlString:objectUrl];
    
    CMISRequest *cmisRequest = [[CMISRequest alloc] init];
    
    [self.bindingSession.networkProvider invokeGET:[NSURL URLWithString:objectUrl]
                                           session:self.bindingSession
                                       cmisRequest:cmisRequest
                                   completionBlock:^(CMISHttpResponse *httpResponse, NSError *error) {
                                       if (httpResponse.statusCode == 200 && httpResponse.data) {
                                           NSError *parsingError = nil;
                                           NSArray *renditions = [CMISBrowserUtil renditionsFromJSONData:httpResponse.data error:&parsingError];
                                           if (parsingError)
                                           {
                                               completionBlock(nil, parsingError);
                                           } else {
                                               completionBlock(renditions, nil);
                                           }
                                       } else {
                                           completionBlock(nil, error);
                                       }
                                   }];
    
    return cmisRequest;
}

@end