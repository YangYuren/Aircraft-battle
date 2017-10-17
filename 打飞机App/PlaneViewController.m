//
//  PlaneViewController.m
//  打飞机App
//
//  Created by Yang on 2017/10/16.
//  Copyright © 2017年 Tucodec. All rights reserved.
//

#import "PlaneViewController.h"

@interface PlaneViewController ()
@property (nonatomic,strong) NSMutableArray * dijiArr;
@property (nonatomic,strong) NSMutableArray * zidanArr;
@property (nonatomic,strong) NSMutableArray * boomArr;
@property (nonatomic,strong) UIImageView *bg1;
@property (nonatomic,strong) UIImageView *bg2;
@property (nonatomic,strong) UIImageView *zhanji;
@property (nonatomic,assign) CGPoint location;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) UIButton * btn;
@property (nonatomic,strong) UILabel * scoreLabel;
@end

@implementation PlaneViewController
int speed = 0;
int moveBg = 0;
bool orMove=NO;
int score = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    //测试大招
    [self Dazhao];
}
//影藏导航栏
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)Dazhao{//点击释放大招
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn = btn;
    [btn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(10, 20, 60, 32)];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
-(void)test{
    self.btn.selected = !self.btn.selected;
    //取消之前的延迟事件
    if(self.btn.selected){
        [self stopTimer];
    }else{
        [self restartTimer];
    }
}

-(void)initUI{
    [self.view addSubview:self.bg1];
    [self.view addSubview:self.bg2];
    [self.view addSubview:self.zhanji];
    [self.view addSubview:self.scoreLabel];
    [self initData];
    //更新所有数据计时器
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:weakSelf selector:@selector(upDate) userInfo:nil repeats:YES];
}
-(void)initData{
    //创建敌机
    for (int i = 0; i<10; i++) {//重复使用10台敌机
        UIImageView *diji = [[UIImageView alloc]init];
        //diji.frame = CGRectMake(10, i*25, 20, 20);//显示复用飞机数字
        diji.image = [UIImage imageNamed:@"diji.png"];
        diji.tag = 5;//5为非激活状态,6为激活状态
        [self.view addSubview:diji];
        [self.dijiArr addObject:diji];
    }
    //创建子弹
    for (int i = 0; i<20; i++) {//重复使用20发子弹
        UIImageView *zidan = [[UIImageView alloc]init];
        zidan.image = [UIImage imageNamed:@"zidan.png"];
        zidan.tag = 5;//5为非激活状态,6为激活状态
        [self.view addSubview:zidan];
        [self.zidanArr addObject:zidan];
    }
    //创建爆炸
    for (int i = 0 ; i<25; i++) {
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.animationImages = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"bz1.png"],[UIImage imageNamed:@"bz2.png"],[UIImage imageNamed:@"bz3.png"],[UIImage imageNamed:@"bz4.png"],[UIImage imageNamed:@"bz5.png"], nil];
        imgView.animationDuration = .5;
        imgView.animationRepeatCount = 1;
        [self.boomArr addObject:imgView];
    }
}
#pragma mark --- Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    orMove =NO;
    if (self.zhanji ==[touch view]) {
        self.location = [touch locationInView:self.zhanji];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{//战机的位置
    UITouch *touch = [touches anyObject];
    if (self.zhanji == [touch view]) {
        CGPoint point = [touch locationInView:self.zhanji];
        float dx = point.x-_location.x;
        float dy = point.y-_location.y;
        CGPoint center = self.zhanji.center;
        center.x+=dx;
        center.y+=dy;
        if(center.x<25){
            center.x = 25;
        }
        if(center.y>([UIScreen mainScreen].bounds.size.height-30)){
            center.y = [UIScreen mainScreen].bounds.size.height-30;
        }
        self.zhanji.center = center;
        orMove =YES;
    }
}
#pragma mark --- private Methods
//计时器事件
- (void)upDate{
    if (speed%8 == 0) {
        [self finDiji];
        [self findZidan];
    }
    speed++;
    [self bgMove];//背景移动
    [self moveDiji];//敌机移动
    [self moveZidan];//子弹移动
    [self jiZhong];//击中敌机
    [self isGameOver];//是否游戏结束
}
//背景移动
- (void)bgMove{
    moveBg += 5;
    if (moveBg == 565) {
        moveBg = 0;
    }
    self.bg1.frame = CGRectMake(0, moveBg, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.bg2.frame = CGRectMake(0, moveBg - [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}
//判断子弹是否击中敌机
- (void)jiZhong{
    for (UIImageView *imgView in self.zidanArr) {
        if (imgView.tag == 6) {
            for (UIImageView *imgView1 in self.dijiArr) {
                if (imgView1.tag == 6) {
                    if (CGRectIntersectsRect(imgView.frame, imgView1.frame)) {
                        ++score;
                        [self.scoreLabel setText:[NSString stringWithFormat:@"分数:%d",score]];
                        for (UIImageView *imgView2 in self.boomArr) {
                            if (![imgView2 isAnimating]) {
                                imgView2.frame = imgView1.frame;
                                imgView1.frame = CGRectZero;
                                imgView1.tag = 5;
                                imgView.frame = CGRectZero;
                                imgView.tag = 5;
                                [self.view addSubview:imgView2];
                                [imgView2 startAnimating];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}
//判断战机是否击中敌机
-(void)isGameOver{
    for (UIImageView *imgView1 in self.dijiArr) {
        if (imgView1.tag == 6) {
            if (CGRectIntersectsRect(self.zhanji.frame, imgView1.frame)) {
                [self deathMethods];
                //分数为0
                score =0;
                [self.scoreLabel setText:@"分数:0"];
                [self stopTimer];
                self.zhanji.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-25, [UIScreen mainScreen].bounds.size.width-30, 50, 60);
                self.btn.selected = YES;
                [self boom];
                [self boomzidan];
                for (UIImageView *imgView2 in self.boomArr) {
                    if (![imgView2 isAnimating]) {// 碰到的敌机爆炸
                        imgView2.frame = imgView1.frame;
                        imgView1.frame = CGRectZero;
                        imgView1.tag = 5;
                        [self.view addSubview:imgView2];
                        [imgView2 startAnimating];
                        break;
                    }
                }
            }
        }
    }
    
}
//激活敌机
- (void)finDiji{
    for (UIImageView *imgView in self.dijiArr) {
        if (imgView.tag == 5) {
            imgView.tag =6;
            CGFloat x =arc4random()%300;
            if(x<20){
                x = 20;
            }
            imgView.frame = CGRectMake(x, -20, 20, 20);
            break;
        }
    }
}
//敌机移动
- (void)moveDiji{
    for (UIImageView *imgView in self.dijiArr) {
        if (imgView.tag ==6) {
            CGRect rect = imgView.frame;
            rect.origin.y+=5;
            if (rect.origin.y > [UIScreen mainScreen].bounds.size.height) {//超出屏幕的时候
                imgView.tag =5;//未激活状态
                rect.origin.y = -20;
            }
            imgView.frame = rect;
        }
    }
}
//激活子弹
- (void)findZidan{
    for (UIImageView *imgView in self.zidanArr) {
        if (imgView.tag ==5) {
            imgView.tag =6;
            imgView.frame = CGRectMake(_zhanji.center.x-3,_zhanji.center.y-35, 6, 12);//随着战机位置变化
            break;
        }
    }
}
//移动子弹
- (void)moveZidan{
    for (UIImageView *imgView in self.zidanArr) {
        if (imgView.tag == 6) {
            CGRect rect = imgView.frame;
            rect.origin.y-=5;
            if (rect.origin.y <-12) {
                //rect.origin.y =_zhanji.center.y-25;
                imgView.frame = CGRectMake(_zhanji.center.x-3,_zhanji.center.y-35, 6, 12);
                imgView.tag = 5;
            }
            imgView.frame = rect;
        }
    }
}
//全部飞机爆炸,即单击飞机全屏爆炸(大招)
- (void)boom{
    for (UIImageView *imgView in self.dijiArr) {
        for (UIImageView *imgView1 in self.boomArr) {
            if (![imgView1 isAnimating]) {
                imgView1.frame = imgView.frame;
                imgView.frame = CGRectZero;
                imgView.tag = 5;
                [self.view addSubview:imgView1];
                [imgView1 startAnimating];
                break;
            }
        }
    }
    orMove =NO;
}
//移除全部子弹
-(void)boomzidan{
    for(UIImageView * imgView in self.zidanArr){
        imgView.image = [UIImage imageNamed:@"zidan.png"];
        imgView.tag = 5;//5为非激活状态,6为激活状态
        imgView.frame = CGRectZero;
    }
}
//游戏结束
-(void)deathMethods{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"游戏结束" message:[NSString stringWithFormat:@"分数:%d",score] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
//停止计时
-(void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}
-(void)restartTimer{
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:weakSelf selector:@selector(upDate) userInfo:nil repeats:YES];
}
#pragma mark --- lazy
-(NSMutableArray *)dijiArr{
    if(!_dijiArr){
        _dijiArr = [[NSMutableArray alloc]init];
    }
    return _dijiArr;
}
-(NSMutableArray *)boomArr{
    if(!_boomArr){
        _boomArr = [[NSMutableArray alloc]init];
    }
    return _boomArr;
}
-(NSMutableArray *)zidanArr{
    if(!_zidanArr){
        _zidanArr = [[NSMutableArray alloc]init];
    }
    return _zidanArr;
}
-(UIImageView *)bg1{
    if(!_bg1){
        _bg1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, moveBg, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _bg1.image = [UIImage imageNamed:@"bg.png"];
    }
    return _bg1;
}
-(UIImageView *)bg2{
    if(!_bg2){
        _bg2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, moveBg-480, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _bg2.image = [UIImage imageNamed:@"bg.png"];
    }
    return _bg2;
}
-(UIImageView *)zhanji{
    if(!_zhanji){
        //创建战机
        _zhanji= [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-25, [UIScreen mainScreen].bounds.size.width-30, 50, 60)];
        _zhanji.animationImages = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"plane1.png"],[UIImage imageNamed:@"plane2.png"], nil];
        _zhanji.userInteractionEnabled = YES;
        _zhanji.animationDuration = 0.2;
        [_zhanji startAnimating];
    }
    return _zhanji;
}
-(UILabel *)scoreLabel{
    if(!_scoreLabel){
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-100, 20, 80, 32);
        _scoreLabel.text =@"分数:0";
    }
    return _scoreLabel;
}
#pragma mark --- dealloc
-(void)dealloc{
    NSLog(@"销毁了");
}
@end
