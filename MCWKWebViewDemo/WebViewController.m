//
//  WebViewController.m
//  MCWKWebViewDemo
//
//  Created by cyf on 2017/3/2.
//  Copyright © 2017年 mc. All rights reserved.
//
/*
 
 */

#import "WebViewController.h"
#import "HZPhotoBrowserConfig.h"
#import "HZPhotoBrowser.h"

@interface WebViewController ()<HZPhotoBrowserDelegate>
@property (nonatomic, retain) NSMutableArray * showPhotourlarr;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showPhotourlarr = [NSMutableArray array];
    [self setNarItemWithTitle:@"" withLeftImage:@"back_icon" withRightImage:@""];

    [self.webView loadRequestWithRelativeUrl:@"http://m.ishangzu.com/hz/app/article/399"];
    
    // Do any additional setup after loading the view.
    
    
}

#pragma mark - 页面加载完成注入JS 
- (void)injectionOfJs:(MCWKWebView *)webView{
    
    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'" completionHandler:nil];
    
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var imgElement = document.getElementsByTagName(\"img\");\
    for(var i=0;i<imgElement.length;i++){\
    imgElement[i].addEventListener(\"click\", function(e){\
    var self = this;\
    if(e.target.parentElement.nodeName!='A'){\
    document.location=\"myweb:imageClick:\"+self.src;\
    }\
    });\
    };\
    };";

    [webView evaluateJavaScript:jsGetImages completionHandler:nil];
    
    [webView evaluateJavaScript:@"getImages()" completionHandler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
    }
    
    NSString *requestString = navigationAction.request.URL.absoluteString;
    NSLog(@"------requestString == %@",requestString);
    //hasPrefix 判断创建的字符串内容是否以myweb:imageClick:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSLog(@"我是图片");
        decisionHandler(WKNavigationActionPolicyCancel);
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        [self.showPhotourlarr removeAllObjects];
        [self.showPhotourlarr  addObject:imageUrl];
        [self  showimg];//  展示大图
        return;
    }
    
    //containsString 判断创建的字符串内容是否包含 itunes.apple.com 字符
    if ([requestString containsString:@"itunes.apple.com"]) {
        NSURL *url = navigationAction.request.URL;
        UIApplication *app = [UIApplication sharedApplication];
        NSLog(@"url.absoluteString == %@", url.absoluteString);
        if ([app canOpenURL:url]) {
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 解析好的html 数据
- (void)parsingData:(TFHpple *)data{
    NSLog(@"%@", data);
}


#pragma  mark - 查看大图
- (void)showimg {
    HZPhotoBrowser *browserVc = [[HZPhotoBrowser alloc] init];
    browserVc.sourceImagesContainerView = self.view; // 原图的父控件
    browserVc.imageCount = self.showPhotourlarr.count; // 图片总数
    browserVc.currentImageIndex = 0;// 当前图片索引
    browserVc.delegate = self;
    [browserVc show];
}

#pragma mark - photobrowser代理方法
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    if (self.showPhotourlarr !=nil)
    {
        //    NSString *urlStr = [ self.photourlarr[index]  stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        //    UIImage *img =[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]]];
        UIImage *img =[UIImage imageNamed:@"whiteplaceholder"];
        return img;
    }else
    {
        return nil;
    }
}

- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    NSString *urlStr = [self.showPhotourlarr[index]  stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    NSLog(@"%@",self.showPhotourlarr[index]);
    return [NSURL URLWithString:urlStr];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
