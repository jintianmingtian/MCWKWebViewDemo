//
//  MCWKWebView.m
//  MCWKWebViewDemo
//
//  Created by cyf on 2017/3/2.
//  Copyright © 2017年 mc. All rights reserved.
//

#import "MCWKWebView.h"

//这里可以统一设置WebView的访问域名，方便切换
#ifdef DEBUG
#   define BASE_URL_API    @"http://"   //测试环境
#else
#   define BASE_URL_API    @"http://"   //正式环境
#endif


@interface MCWKWebView () {
    
}

@property (nonatomic, strong) NSURL *baseUrl;

@end

@implementation MCWKWebView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.baseUrl = [NSURL URLWithString:BASE_URL_API];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        //这句是关闭系统自带的侧滑后退（历史浏览记录）
        //        self.allowsBackForwardNavigationGestures = YES;
        self.baseUrl = [NSURL URLWithString:BASE_URL_API];
    }
    
    return self;
}

#pragma mark - Load Url

- (void)loadRequestWithRelativeUrl:(NSString *)relativeUrl; {
    
    [self loadRequestWithRelativeUrl:relativeUrl params:nil];
}

- (void)loadRequestWithRelativeUrl:(NSString *)relativeUrl params:(NSDictionary *)params {
    
    NSURL *url = [self generateURL:relativeUrl params:params];
    
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

/**
 *  加载本地HTML页面
 *
 *  @param htmlName html页面文件名称
 *  params   参数
 */
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [self loadHTMLString:htmlCont baseURL:baseURL];
}

- (NSURL *)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    
    self.webViewRequestUrl = baseURL;
    self.webViewRequestParams = params;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:params];
    
    NSMutableArray* pairs = [NSMutableArray array];
    
    for (NSString* key in param.keyEnumerator) {
        NSString *value = [NSString stringWithFormat:@"%@",[param objectForKey:key]];
        
        
        NSString *charactersToEscape = @"!*'\"();:@&=+$,/?%#[]% ";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        NSString *escaped_value = [value stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    
    NSString *query = [pairs componentsJoinedByString:@"&"];
    baseURL = [baseURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString* url = @"";
    if ([baseURL containsString:@"?"]) {
        url = [NSString stringWithFormat:@"%@&%@",baseURL, query];
    }
    else {
        url = [NSString stringWithFormat:@"%@?%@",baseURL, query];
    }
    //绝对地址
    if ([url.lowercaseString hasPrefix:@"http"]) {
        return [NSURL URLWithString:url];
    }
    else {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseUrl, url]];
    }
}

/**
 *  重新加载webview
 */
- (void)reloadWebView {
    [self loadRequestWithRelativeUrl:self.webViewRequestUrl params:self.webViewRequestParams];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
}

#pragma mark - JS

- (void)callJSWithString:(NSString *)jsMethod {
    [self callJSWithString:jsMethod handler:nil];
}

- (void)callJSWithString:(NSString *)jsMethod handler:(void (^)(id _Nullable))handler {
    
    NSLog(@"call js:%@",jsMethod);
    [self evaluateJavaScript:jsMethod completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(response);
        }
    }];
}

@end
