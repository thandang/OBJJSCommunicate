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
#import "SSZipArchive.h"

@interface ViewController () <WebViewInterface, SSZipArchiveDelegate> {
    __weak IBOutlet UIWebView *myWebView;
    __weak IBOutlet UITextField *txtInput;

    __weak IBOutlet UILabel *lblName;

    __weak IBOutlet UITextField *txtFirstname;

    __weak IBOutlet UITextField *txtLastname;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom Delegate
- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error {
    if ([name compare:@"loadList" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSArray *listElements = @[@"Item 1", @"Item 2"];

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:listElements options:0 error:nil];

        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        return result;
    } else if ([name compare:@"updateLabel" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        //Return callback
        NSArray *listName = @[txtFirstname.text, txtLastname.text];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:listName options:0 error:nil];
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return result;
    }

    return nil;
}



- (IBAction)btnClicked:(id)sender {
    NSDictionary *dict = @{@"newListItem":txtInput.text};
    [self.webViewDelegate callJSFunction:@"addToList" args:dict];
}


- (IBAction)callNativeFunction:(id)sender {
    NSDictionary *dict = [NSDictionary dictionary];
    [self.webViewDelegate callJSFunction:@"showValueInNative" args:dict];
}

- (IBAction)unzip:(id)sender {
    NSString *zipPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"wwwroot" ofType:@"zip"];

    NSString *outputPath = [self _cachesPath:nil];

    [SSZipArchive unzipFileAtPath:zipPath toDestination:outputPath delegate:self];
}


#pragma mark - Unzip Delegate
- (void) zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:unzippedPath]) {
        NSError *error = nil;
        NSArray *itemRootObject = [fileManager contentsOfDirectoryAtPath:unzippedPath error:&error];
        NSString *root;
        for (NSInteger l = 0; l < itemRootObject.count; l++) {
            NSString *rootName = itemRootObject[l];
            if ([rootName rangeOfString:@"wwwroot"].location != NSNotFound) {
                root = rootName;
                break;
            }
        }
        NSString *desPath = nil;
        if (root) {
            desPath = [unzippedPath stringByAppendingString:[NSString stringWithFormat:@"/%@", root]];
        } else {
            desPath = unzippedPath;
        }
        NSArray *items = items = [fileManager contentsOfDirectoryAtPath:desPath error:&error];

        NSString *path = @"";
        if (!error) {
            for (NSInteger i = 0; i < items.count; i++) {
                NSString *item = items[i];
                if ([item rangeOfString:@"index.html"].location != NSNotFound) {
                    path = [desPath stringByAppendingFormat:@"/%@",item];
                    break;
                }
            }
        } else {
            NSLog(@"error: %@", error);
        }
        [self.webViewDelegate loadPageWithPath:path];
    }
}

#pragma mark - Private
- (NSString *)_cachesPath:(NSString *)directory {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
                      stringByAppendingPathComponent:@"com.apide.test"];
    if (directory) {
        path = [path stringByAppendingPathComponent:directory];
        NSLog(@"Path: %@", path);
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return path;
}



@end
