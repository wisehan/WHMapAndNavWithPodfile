//
//  WHHomeViewController.m
//  WHBaiduMapAndNavigation
//
//  Created by mac on 2017/3/23.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "WHHomeViewController.h"
#import "WHBaiduNaviViewController.h"

@interface WHHomeViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>{
    BMKLocationService *_locationService;
    BMKMapView *_mapView;
    BMKLocationViewDisplayParam *param;
}

//@property (nonatomic, assign) BMKMapView *mapView;

@end

@implementation WHHomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAllView];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)initAllView{
    self.title = @"HOME_Map";
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc]init];
    barItem.target = self;
    barItem.action = @selector(customLocationAccuracyCircle);
    barItem.title = @"自定义精度圈";
    self.navigationItem.rightBarButtonItem = barItem;
    
    //基本地图
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 375, 603)];
    self.view = _mapView;
    [_mapView addSubview:_startLocation];
    [_mapView addSubview:_startFollowing];
    [_mapView addSubview:_startFollowHeading];
    [_mapView addSubview:_stopLocation];
    [_mapView addSubview:_GoToNavigation];
    
    //切换地图类型：卫星和普通
//    [_mapView setMapType:BMKMapTypeSatellite];
//    [_mapView setMapType:BMKMapTypeStandard];
    
    //------定位------
    //初始化BMKLocationService
    _locationService = [[BMKLocationService alloc]init];
    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locationService.delegate = self;

    //设置地图缩放级别3-21，越大越详细，能见地图范围越少
    [_mapView setZoomLevel:10];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locationService.delegate = nil;
}

//自定义精度圈
- (void)customLocationAccuracyCircle {
    param = [[BMKLocationViewDisplayParam alloc] init];
    param.accuracyCircleStrokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
    param.accuracyCircleFillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
    param.isAccuracyCircleShow = YES;
    [_mapView updateLocationViewWithParam:param];
}

#pragma 四种定位状态
- (IBAction)startLocationClick:(UIButton *)sender {
    //设置地图缩放级别3-21，越大越详细，能见地图范围越少
    [_mapView setZoomLevel:17];
    
    //仅获取当前位置经纬度并不能跳转到当前位置
    NSLog(@"进入普通定位态");
    param.isAccuracyCircleShow = NO;
    [_locationService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    [_startLocation setEnabled:NO];
    [_startLocation setAlpha:0.6];
    [_stopLocation setEnabled:YES];
    [_stopLocation setAlpha:1.0];
    [_startFollowHeading setEnabled:YES];
    [_startFollowHeading setAlpha:1.0];
    [_startFollowing setEnabled:YES];
    [_startFollowing setAlpha:1.0];
}
- (IBAction)startFollowingClick:(UIButton *)sender {
    //设置地图缩放级别3-21，越大越详细，能见地图范围越少
    [_mapView setZoomLevel:17];
    
    //能定位并且能跳转到当前位置
    NSLog(@"进入跟随态");
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    
    
}
- (IBAction)startFollowHeadingClick:(UIButton *)sender {
    //设置地图缩放级别3-21，越大越详细，能见地图范围越少
    [_mapView setZoomLevel:17];

    //能定位并且能跳转到当前位置
    NSLog(@"进入罗盘态");
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    _mapView.showsUserLocation = YES;
}
- (IBAction)stopLocationClick:(UIButton *)sender {
    [_locationService stopUserLocationService];
    _mapView.showsUserLocation = NO;
    [_stopLocation setEnabled:NO];
    [_stopLocation setAlpha:0.6];
    [_startFollowHeading setEnabled:NO];
    [_startFollowHeading setAlpha:0.6];
    [_startFollowing setEnabled:NO];
    [_startFollowing setAlpha:0.6];
    [_startLocation setEnabled:YES];
    [_startLocation setAlpha:1.0];
}

#pragma push到导航界面
- (IBAction)buttonToNavigation:(UIButton *)sender {
    WHBaiduNaviViewController *naviVC = [[WHBaiduNaviViewController alloc] init];
    [self.navigationController pushViewController:naviVC animated:YES];
    
}

#pragma 实现相关delegate 处理位置信息更新
/**
 *在地图View将要启动定位时，会调用此函数
 * mapView 地图View
 */
- (void)willStartLocatingUser{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
//    NSLog(@"heading is %@",userLocation.heading);
    [_mapView updateLocationData:userLocation];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
}

/**
 *在地图View停止定位后，会调用此函数
 * mapView 地图View
 */
- (void)didStopLocatingUser{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 * mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"location error");
}


- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
