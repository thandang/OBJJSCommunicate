//
//  AOWebViewDelegate.h
//  OBJJSCommunicate
//
//  Created by Than Dang on 5/24/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WebViewInterface.h"

@interface AOWebViewDelegate : NSObject <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;


- (id) initWithWebView:(UIWebView *)webView withWebViewInterface:(id<WebViewInterface>)webViewInterface;
- (void) loadPage:(NSString *)pageName fromFolder:(NSString *)folderName;
- (void) loadPageWithPath:(NSString *)path;
- (void) createError:(NSError **)error withErrorCode:(int)code andMessage:(NSString *)message;
- (void) callJSFunction:(NSString *)functionName args:(NSDictionary *)args;

@end
