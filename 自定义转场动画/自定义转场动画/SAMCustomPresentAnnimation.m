//  ViewController.m
//  自定义转场动画
//
//  Created by  Walle on 2017/5/13.
//  Copyright © 2017年 DreamTeam. All rights reserved.
//

#import "SAMCustomPresentAnnimation.h"

@interface SAMCustomPresentAnnimation()<UIViewControllerAnimatedTransitioning,CAAnimationDelegate>

@property(nonatomic,assign)BOOL isPresent;


//这里要使用weak弱引用，否则会导致循环引用
@property(nonatomic,weak)id<UIViewControllerContextTransitioning>transitionContext;


@end

@implementation SAMCustomPresentAnnimation

#pragma mark -UIViewControllerTransitioningDelegate 告诉系统谁来负责提供和接触转场

//由谁提供转场
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    //展现
    self.isPresent = YES;
    return self;
}


//由谁负责解除转场
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    //解除dismiss
    self.isPresent = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning转场动画细节执行

//返回动画的时长
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

//转场动画真正表演的舞台
/**真正负责执行转场动画的地方
 1.transitionContext：转场上下文，负责提供转场过程中的一切细节
 2.转场上下文会强引用控制器，需要注意循环引用
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //1.获取转场上下文的容器视图
    UIView *containView = transitionContext.containerView;
    //2获取转场上下文的目标视图
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    //(如果是present，toView是龙猫  如果是dismiss，fromview是龙猫)
    UIView *view = self.isPresent?toView:fromView;
    //3.将目标视图添加到容器视图
    [containView addSubview:view];
    
    //4.执行动画
    [self animationWithView:view];
    
    
    //5.非常重要：一定要完成转场,否则系统会一直等待完成转场，此时会拦截所有的交互时间
    
    //在执行动画过程中，应该拦截交互时间  只有动画完成之后才可以交互，应该讲完成转场方法放在动画完成的代理方法中
    //    [transitionContext completeTransition:YES];
    self.transitionContext = transitionContext;
}


#pragma mark - CAAnimationDelegate  动画开始和结束代理
//结束动画
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //动画完成之后解除转场
    [self.transitionContext completeTransition:YES];
}




- (void)animationWithView:(UIView *)view
{
    //1.创建形状图层ShapreLayer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    //2.创建圆形贝塞尔路径  参数是圆的外接矩形
    
    //圆起始矩形
    //圆的屏幕边距
    CGFloat mergin = 20;
    //圆的半径
    CGFloat radiu = 25;
    
    CGRect startRect = CGRectMake(view.bounds.size.width - mergin - radiu*2, mergin, radiu*2, radiu*2);
    UIBezierPath *startBezierPath = [UIBezierPath bezierPathWithOvalInRect:startRect];
    
    
    CGFloat sWidth = view.frame.size.width;
    CGFloat sHeight = view.frame.size.height;
    //结束圆的半径（屏幕的半径）
    
    CGFloat endRadius = sqrt(sWidth*sWidth + sHeight*sHeight);
    //使用缩进矩形创建结束圆的外接矩形 //第一个参数：原始矩形  第二个参数：X方向缩进的距离（+缩小  -放大） 第三个参数：Y方向缩进的距离
    CGRect endRect = CGRectInset(startRect, -(endRadius), -endRadius);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
    
    
    
    
    //3.设置形状图层的填充颜色  fillColor:填充圆  strokeColor:边框圆
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    //4.设置绘制好的贝塞尔路径为形状图层的路径
    shapeLayer.path = startBezierPath.CGPath;
    
    //5.将shape添加到视图中,addSublayer是在当前的图层上添加一个layer形状区域
    //    [self.view.layer addSublayer:shapeLayer];
    
    //6.设置shapelayer为控制器视图的遮罩图层
    //设置mask遮罩图层：1.会裁切图层，让图层只能看见shaprelayer的形状的区域 2.一旦将layer设置为遮罩图层之后，填充颜色就会无效
    view.layer.mask = shapeLayer;
    
    
    //使用核心动画实现layer图层的动画
    [self animationWithStartPath:startBezierPath EndPath:endPath ShapeLayer:shapeLayer];
    
    
    //注意：该动画只能作用于UIView，layer层的动画只能用核心动画
    //    [UIView animateWithDuration:10 animations:^{
    //        shapeLayer.path = endPath.CGPath;
    //    }];
}

- (void)animationWithStartPath:(UIBezierPath *)startPath EndPath:(UIBezierPath *)endPath ShapeLayer:(CAShapeLayer *)shapeLayer
{
    //1.创建核心动画  参数：动画改变的值
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    //2.动画基础参数
    basicAnimation.duration = [self transitionDuration:self.transitionContext];
    
    //设置代理
    basicAnimation.delegate = self;
    //3.动画  开始值和结束值
    
    //如果是present，动画是由小圆到大圆  如果是dismiss，动画由大圆到小圆
    if (self.isPresent == YES) {
        basicAnimation.fromValue = (__bridge id )(startPath.CGPath);
        basicAnimation.toValue = (__bridge id)(endPath.CGPath);
        
    }
    else
    {
        basicAnimation.fromValue = (__bridge id )(endPath.CGPath);
        basicAnimation.toValue = (__bridge id)(startPath.CGPath);
        
    }
    
    //4.设置动画执行完毕不恢复  1.设置填充模式为向前填充  2.设置动画完成移除属性removedOnCompletion为NO
    basicAnimation.fillMode = kCAFillModeForwards;
    basicAnimation.removedOnCompletion = NO;
    
    //4.执行动画   谁要执行动画就将动画添加到谁身上
    [shapeLayer addAnimation:basicAnimation forKey:nil];
}

@end
