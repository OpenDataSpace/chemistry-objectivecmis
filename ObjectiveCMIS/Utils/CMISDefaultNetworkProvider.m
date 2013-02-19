/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "CMISDefaultNetworkProvider.h"
#import "CMISAuthenticationProvider.h"
#import "CMISErrors.h"
#import "CMISHttpRequest.h"
#import "CMISHttpDownloadRequest.h"
#import "CMISHttpUploadRequest.h"
#import "CMISRequest.h"
#import "CMISSessionParameters.h"
#import "CMISNetworkProvider.h"

@interface CMISDefaultNetworkProvider ()
+ (NSMutableURLRequest *)createRequestForUrl:(NSURL *)url
                                  httpMethod:(CMISHttpRequestMethod)httpRequestMethod
                                     session:(CMISBindingSession *)session;
@end

@implementation CMISDefaultNetworkProvider
#pragma mark block based methods


- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
          body:(NSData *)body
       headers:(NSDictionary *)additionalHeaders
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                           httpMethod:httpRequestMethod
                                                                              session:session];
    
    [CMISHttpRequest startRequest:urlRequest
                       httpMethod:httpRequestMethod
                      requestBody:body
                          headers:additionalHeaders
           authenticationProvider:session.authenticationProvider
                  completionBlock:completionBlock];
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
   inputStream:(NSInputStream *)inputStream
       headers:(NSDictionary *)additionalHeaders
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                           httpMethod:httpRequestMethod
                                                                              session:session];
    
    [CMISHttpUploadRequest startRequest:urlRequest
                             httpMethod:httpRequestMethod
                            inputStream:inputStream
                                headers:additionalHeaders
                          bytesExpected:0
                 authenticationProvider:session.authenticationProvider
                        completionBlock:completionBlock
                          progressBlock:nil];
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
   inputStream:(NSInputStream *)inputStream
       headers:(NSDictionary *)additionalHeaders
 bytesExpected:(unsigned long long)bytesExpected
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
 requestObject:(CMISRequest *)requestObject
{
    if (!requestObject.isCancelled) {
        NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                               httpMethod:httpRequestMethod
                                                                                  session:session];
        
        CMISHttpUploadRequest *uploadRequest = [CMISHttpUploadRequest startRequest:urlRequest
                                                                        httpMethod:httpRequestMethod
                                                                       inputStream:inputStream
                                                                           headers:additionalHeaders
                                                                     bytesExpected:bytesExpected
                                                            authenticationProvider:session.authenticationProvider
                                                                   completionBlock:completionBlock
                                                                     progressBlock:progressBlock];
        requestObject.httpRequest = uploadRequest;
    } else {
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled
                                                 detailedDescription:@"Request was cancelled"]);
        }
    }
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
  outputStream:(NSOutputStream *)outputStream
 bytesExpected:(unsigned long long)bytesExpected
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
 requestObject:(CMISRequest *)requestObject
{
    if (!requestObject.isCancelled) {
        NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                               httpMethod:HTTP_GET
                                                                                  session:session];
        
        CMISHttpDownloadRequest *downloadRequest = [CMISHttpDownloadRequest startRequest:urlRequest
                                                                              httpMethod:httpRequestMethod
                                                                            outputStream:outputStream
                                                                           bytesExpected:bytesExpected
                                                                  authenticationProvider:session.authenticationProvider
                                                                         completionBlock:completionBlock
                                                                           progressBlock:progressBlock];
        requestObject.httpRequest = downloadRequest;
    } else {
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled
                                                 detailedDescription:@"Request was cancelled"]);
            
        }
    }
}

- (void)invokeGET:(NSURL *)url
          session:(CMISBindingSession *)session
  completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_GET
                session:session
                   body:nil
                headers:nil
        completionBlock:completionBlock];
}

- (void)invokePOST:(NSURL *)url
           session:(CMISBindingSession *)session
              body:(NSData *)body
           headers:(NSDictionary *)additionalHeaders
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_POST
                session:session
                   body:body
                headers:additionalHeaders
        completionBlock:completionBlock];
}

- (void)invokePUT:(NSURL *)url
          session:(CMISBindingSession *)session
             body:(NSData *)body
          headers:(NSDictionary *)additionalHeaders
  completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_PUT
                session:session
                   body:body
                headers:additionalHeaders
        completionBlock:completionBlock];
}

- (void)invokeDELETE:(NSURL *)url
             session:(CMISBindingSession *)session
     completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_DELETE
                session:session
                   body:nil
                headers:nil
        completionBlock:completionBlock];
}

#pragma mark Helper methods
+ (NSMutableURLRequest *)createRequestForUrl:(NSURL *)url
                                  httpMethod:(CMISHttpRequestMethod)httpRequestMethod
                                     session:(CMISBindingSession *)session
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60];
    NSString *httpMethod;
    switch (httpRequestMethod) {
        case HTTP_GET:
            httpMethod = @"GET";
            break;
        case HTTP_POST:
            httpMethod = @"POST";
            break;
        case HTTP_DELETE:
            httpMethod = @"DELETE";
            break;
        case HTTP_PUT:
            httpMethod = @"PUT";
            break;
        default:
            log(@"Invalid http request method: %d", httpRequestMethod);
            return nil;
    }
    
    [request setHTTPMethod:httpMethod];
    log(@"HTTP %@: %@", httpMethod, [url absoluteString]);
    
    return request;
}

@end