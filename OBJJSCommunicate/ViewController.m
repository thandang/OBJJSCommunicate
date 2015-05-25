//
//  ViewController.m
//  OBJJSCommunicate
//
//  Created by Than Dang on 5/23/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "ViewController.h"
#import "AOWebViewDelegate.h"
#import "WebViewInterface.h"

@interface ViewController () <WebViewInterface> {
    
    __weak IBOutlet UIWebView *myWebView;
    
    __weak IBOutlet UITextField *txtInput;
    
}

@property AOWebViewDelegate   *webViewDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webViewDelegate = [[AOWebViewDelegate alloc] initWithWebView:myWebView withWebViewInterface:self];
    myWebView.scrollView.scrollEnabled = NO;
    
    [self.webViewDelegate loadPage:@"index.html" fromFolder:@"wwwroot"];
//    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"wwwroot"] isDirectory:NO]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom Delegate
- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error {
//    if ([name compare:@"loadList" options:NSCaseInsensitiveSearch] == NSOrderedSame)
//    {
//        NSArray *listElements = @[@"Item 1", @"Item 2"];
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:listElements options:0 error:nil];
//        
//        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        
//        return result;
//    }
    
    return nil;
}



- (IBAction)btnClicked:(id)sender {
    NSDictionary *dict = @{@"newListItem":txtInput.text};
    [self.webViewDelegate callJSFunction:@"addToList" args:dict];
}



@end
