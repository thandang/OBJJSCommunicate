//
//  AOWebViewDelegate.m
//  OBJJSCommunicate
//
//  Created by Than Dang on 5/24/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "AOWebViewDelegate.h"

#define kPrefix @"js2ios"
#define kFunctionName   @"functionname"
#define kSuccess    @"success"
#define kError      @"error"
#define kArguments  @"args"

@interface AOWebViewDelegate ()

@property (nonatomic, weak) id<WebViewInterface> webInterface;

@end

@implementation AOWebViewDelegate

- (id) initWithWebView:(UIWebView *)webView withWebViewInterface:(id<WebViewInterface>)webViewInterface {
    self.webView = webView;
    self.webInterface = webViewInterface;
    self.webView.delegate = self;
    return self;
}

- (void) createError:(NSError *__autoreleasing *)error withErrorCode:(int)code andMessage:(NSString *)message {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithInt:code] forKey:@"code"];
    [dict setValue:message forKey:@"message"];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    if (jsonError) {
        NSLog(@"error: %@", [jsonError localizedDescription]);
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self createError:error withMessage:jsonString];
}

- (void) loadPage:(NSString *)pageName fromFolder:(NSString *)folderName {
    NSRange range = [pageName rangeOfString:@"."];
    if (range.length) {
        if (folderName == nil) {
            folderName = @"wwwroot";
        }
        NSString *fileExtention = [pageName substringFromIndex:range.location + 1];
        NSString *fileName = [pageName substringToIndex:range.location];
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExtention inDirectory:folderName]];
        if (url) {
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [self.webView loadRequest:request];
        }
    }
}

- (void) callJSFunction:(NSString *)functionName args:(NSDictionary *)args {
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    if (jsonError) {
        NSLog(@"error: %@", [jsonError localizedDescription]);
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (jsonString == nil) {
        NSLog(@"jsonStr is null. count = %ld", (long)[args count]);
    }
    //Real calling
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", functionName, jsonString]];
}


#pragma mark - Private Method
- (void) callJSSuccessCallback:(NSString *)name withRetValue:(id)retValue forFunction:(NSString *)funcName {
    if (name) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name args:resultDict];
    } else {
        NSLog(@"Result of function: %@ = %@", funcName, retValue);
    }
}

- (void) callJSErrorCallback:(NSString *)funcName withMessage:(NSString *)message {
    if (funcName) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", funcName, message]];
    } else {
        NSLog(@"%@", message);
    }
    
}

- (void) createError:(NSError**) error withMessage:(NSString *) msg {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:msg forKey:NSLocalizedDescriptionKey];
    
    *error = [NSError errorWithDomain:@"JSiOSBridgeError" code:-1 userInfo:dict];
    
}

- (BOOL) processURL:(NSString *)url {
    NSString *urlStr = [NSString stringWithString:url];
    if ([[urlStr lowercaseString] hasPrefix:kPrefix]) {
        urlStr = [urlStr substringFromIndex:kPrefix.length];
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError = nil;
        NSDictionary *callInfo = [NSJSONSerialization JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
        if (jsonError) {
            return NO;
        }
        NSString *functionName = [callInfo objectForKey:kFunctionName];
        NSString *errorCallback = [callInfo objectForKey:kError];
        NSString *successCallback = [callInfo objectForKey:kSuccess];
        NSArray *argsArray = [callInfo objectForKey:kArguments];
        [self callFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        return NO;
    }
    return YES;
}

- (void) callFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback {
    NSError *error;
    
    id retVal = [self.webInterface processFunctionFromJS:name withArgs:args error:&error];
    
    if (error != nil)
    {
        NSString *resultStr = [NSString stringWithString:error.localizedDescription];
        [self callJSErrorCallback:errorCallback withMessage:resultStr];
        return;
    }
    
    [self callJSSuccessCallback:successCallback withRetValue:retVal forFunction:name];
    
}

#pragma mark - UIWebView Delegate
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    
    return [self processURL:urlStr];
}



@end
