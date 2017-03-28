//
//  MCWKWebView.h
//  MCWKWebViewDemo
//
//  Created by cyf on 2017/3/2.
//  Copyright © 2017年 mc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class SHWKWebView;

@interface MCWKWebView : WKWebView<WKScriptMessageHandler>


//webview加载的url地址
@property (nullable, nonatomic, copy) NSString *webViewRequestUrl;
//webview加载的参数
@property (nullable, nonatomic, copy) NSDictionary *webViewRequestParams;


#pragma mark - Load Url
/**
 *  加载网络HTML页面
 *
 *  @param relativeUrl html页面地址
 */
- (void)loadRequestWithRelativeUrl:(nonnull NSString *)relativeUrl;

/**
 *  加载本地HTML页面
 *
 *  @param htmlName html页面文件名称
 */
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName;

#pragma mark - View Method

/**
 *  @method 重新加载webview
 */
- (void)reloadWebView;

#pragma mark - JS Method Invoke

/**
 *  @method 调用JS方法（无返回值）
 *
 *  @param jsMethod JS方法名称
 */
- (void)callJSWithString:(nonnull NSString *)jsMethod;

/**
 *  @method 调用JS方法（可处理返回值）
 *
 *  @param jsMethod JS方法名称
 *  @param handler  回调block
 */
- (void)callJSWithString:(nonnull NSString *)jsMethod handler:(nullable void(^)(__nullable id response))handler;


@end
