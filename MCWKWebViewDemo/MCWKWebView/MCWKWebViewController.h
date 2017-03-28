//
//  MCWKWebViewController.h
//  MCWKWebViewDemo
//
//  Created by cyf on 2017/3/2.
//  Copyright © 2017年 mc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCWKWebView.h"
#import "TFHpple.h"  //使用的的时候请引入 libXml2.2.tdb
#import "TFHppleElement.h"


@interface MCWKWebViewController : UIViewController<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) MCWKWebView *webView;

/**
 *  webView 地址
 */
@property (nonatomic, copy) NSString *url;

/**
 *  是否显示加载进度 (默认YES)
 */
@property (nonatomic, assign) BOOL shouldShowProgress;

/**
 *  是否支持滚动（默认YES）
 */
@property (nonatomic, assign) BOOL scrollEnabled;

/**
 *  @method  设置 navigation 标题 和 左右 item 的标题
 *  @param  title       navigationtitle
 *  @param  leftTitle   设置左边Item标题
 *  @param  rightTitle  设置右边Item标题
 */
- (void)setNarItemWithTitle:(NSString *)title withLeftTitle:(NSString *)leftTitle withRightTitle:(NSString *)rightTitle;

/**
 *  @method  设置 navigation 标题 和 左右 item 的图片
 *  @param  title       navigationtitle
 *  @param  leftImage   设置左边Item图片
 *  @param  rightImage  设置右边Item图片
 */
- (void)setNarItemWithTitle:(NSString*)title withLeftImage:(NSString*)leftImage withRightImage:(NSString*)rightImage;

@end
