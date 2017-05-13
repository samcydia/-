//  ViewController.m
//  自定义转场动画
//
//  Created by  Walle on 2017/5/13.
//  Copyright © 2017年 DreamTeam. All rights reserved.
//

#import "LMViewController.h"

#import "SAMCustomPresentAnnimation.h"


@interface LMViewController ()

@property(nonatomic,strong)SAMCustomPresentAnnimation *animation;



@end

@implementation LMViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    //1.设置转场样式为自定义
    self.modalPresentationStyle = UIModalPresentationCustom;
    //2.设置转场代理为动画器
    self.animation = [[SAMCustomPresentAnnimation alloc] init];
    self.transitioningDelegate = self.animation;
   
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

//点击界面实现事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //防止block循环引用
    //__weak typeof(self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
