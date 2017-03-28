//
//  MCWKWebViewController.m
//  MCWKWebViewDemo
//
//  Created by cyf on 2017/3/2.
//  Copyright © 2017年 mc. All rights reserved.
//

#import "MCWKWebViewController.h"
#define     HEADER_HEIGHT               64

// 配置 progressView 颜色
#define PROGRESSVIEW_TINT_COLOR  [UIColor colorWithRed:255/255.0 green:21/255.0 blue:42/255.0 alpha:1/1.0]

@interface MCWKWebViewController (){
    
    BOOL _isWebViewOnceFinishLoad; //webview是否曾经成功加载成功过
    BOOL _isWebViewReloadOperation; //webview是否是重新加载
    
    NSMutableDictionary *_backDict;
}
@property (strong, nonatomic) UIProgressView *progressView; //进度条


@end

@implementation MCWKWebViewController

//懒加载
- (UIProgressView *)progressView{
    if (!_progressView) {
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, CGRectGetWidth(self.view.bounds), 2)];
        self.progressView.tintColor = PROGRESSVIEW_TINT_COLOR;
    }
    return _progressView;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _shouldShowProgress = YES;
        _scrollEnabled = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"加载中";
    [self setupWebView];
    
    
    if (self.url.length) {
        [self.webView loadRequestWithRelativeUrl:self.url];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.webView.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    NSLog(@"dealloc --- %@",NSStringFromClass([self class]));
    if (self.shouldShowProgress) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

/**
 *  显示下拉刷新头（默认YES）
 */
- (BOOL)shouldShowRefreshHeader {
    return YES;
}


- (void)setupWebView {
    
    // 选择CSS
    NSString *css = @"body{-webkit-user-select:auto;-webkit-user-drag:auto;}";
     // CSS选中样式
    NSMutableString *javascript = [NSMutableString string];
    [javascript appendString:@"var style = document.createElement('style');"];
    [javascript appendString:@"style.type = 'text/css';"];
    [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];
    [javascript appendString:@"style.appendChild(cssContent);"];
    [javascript appendString:@"document.body.appendChild(style);"];
    
    // javascript注入
    WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:noneSelectScript];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    configuration.allowsInlineMediaPlayback = YES;
    configuration.requiresUserActionForMediaPlayback = NO;
    _webView = [[MCWKWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) configuration:configuration];
    _webView.scrollView.scrollEnabled = _scrollEnabled;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [self.view addSubview:_webView];
    
    if (self.shouldShowProgress) {
        [self.view addSubview:self.progressView];
        
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == self.webView) {
            CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
            if (newprogress == 1) {
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            }else {
                self.progressView.hidden = NO;
                [self.progressView setProgress:newprogress animated:YES];
            }
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}


#pragma mark - WKNavigationDelegate
/**
 *  可以指定配置对象、导航动作对象、window特性
 *
 *  @param webView    实现该代理的webview
 *  navigation 当前navigation
 */

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

/**
 *  页面开始加载时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    
    
    
    NSLog(@"%s：%@", __FUNCTION__,webView.URL);
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
    
    _isWebViewOnceFinishLoad = YES;
    _isWebViewReloadOperation = NO;
    [self injectionOfJs:_webView];
    [self parsingHTML:_webView];
}

/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%s%@", __FUNCTION__,error);
    
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSLog(@"%s", __FUNCTION__);
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


#pragma mark - WKUIDelegate

/**
 *  处理js里的alert
 *
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
//    }]];
//    
//    [self presentViewController:alert animated:YES completion:nil];
}

/**
 *  处理js里的confirm
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
   
}

#pragma mark - systemNavigationBar
- (void)setNarItemWithTitle:(NSString*)title withLeftImage:(NSString*)leftImage withRightImage:(NSString*)rightImage {
    
    self.navigationItem.title = title;
    
    if (leftImage.length > 0) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 44, 44);
        [leftBtn setImage:[UIImage imageNamed:leftImage] forState:UIControlStateNormal];
        //        __weak typeof(self) weakSelf = self;
        [leftBtn addTarget:self action:@selector(leftMethod) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    if (rightImage.length > 0) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 44, 44);
        [rightBtn setImage:[UIImage imageNamed:rightImage] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightMethod) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)setNarItemWithTitle:(NSString *)title withLeftTitle:(NSString *)leftTitle withRightTitle:(NSString *)rightTitle {
    
    self.navigationItem.title = title;
    if (leftTitle.length > 0) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 44, 44);
        [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
        [leftBtn addTarget:self action:@selector(leftMethod) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    if (rightTitle.length > 0) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 44, 44);
        [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightMethod) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)leftMethod {
    if (_webView.canGoBack) {
        [_webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightMethod {
    
    
}

/**
 *  加载完成注入JS
 */
- (void)injectionOfJs:(MCWKWebView *)webView{
    
}

/**
 *  解析HTML
 */
- (void)parsingHTML:(MCWKWebView *)webView{
    NSString *lJs = @"document.documentElement.innerHTML";//获取当前网页的html
    __weak typeof(self)weafSelf = self;

    [webView evaluateJavaScript:lJs completionHandler:^(id _Nullable currentHTML, NSError * _Nullable error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *data = [currentHTML dataUsingEncoding:NSUTF8StringEncoding];
                TFHpple * dataHpple = [[TFHpple alloc] initWithHTMLData:data];
                [weafSelf parsingData:dataHpple];
            });
        });
    }];
    
    
    
}

/**
 *  解析好的数据
 */
- (void)parsingData:(TFHpple *)data{
    
}

@end
