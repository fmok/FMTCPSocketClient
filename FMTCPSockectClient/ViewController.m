//
//  ViewController.m
//  FMTCPSockectClient
//
//  Created by fm on 2017/3/8.
//  Copyright © 2017年 wangjiuyin. All rights reserved.
//

#import "ViewController.h"
#import "AsyncSocket.h"

@interface ViewController ()<AsyncSocketDelegate>

@property (nonatomic, weak) IBOutlet UITextField *hostTextField;
@property (nonatomic, weak) IBOutlet UITextField *portTextField;
@property (nonatomic, weak) IBOutlet UITextView *clientTextView;
@property (nonatomic, weak) IBOutlet UITextField *sendTextField;

@property (nonatomic, strong) AsyncSocket *tcpSocket;
@property (nonatomic, strong) NSMutableArray *connectHostArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.hostTextField.text = @"172.16.1.8";
    self.portTextField.text = @"8888";
}

#pragma mark - Private methods
- (void)addMessage:(NSString *)str
{
    self.clientTextView.text = [self.clientTextView.text stringByAppendingFormat:@"%@\n\n\n",str];
    [self.clientTextView scrollRangeToVisible:[self.clientTextView.text rangeOfString:str options:NSBackwardsSearch]];
}

#pragma mark - AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    [self addMessage:[NSString stringWithFormat:@"连接上%@\nlocal:%@",host,sock]];
    [self.connectHostArr addObject:host];
    
    [self.tcpSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    [self addMessage:[NSString stringWithFormat:@"断开连接:%@ ",sock]];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *msg = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
    NSLog(@"读到的数据：%@",msg);
    [self addMessage:[NSString stringWithFormat:@"收到数据：%@",msg]];
    [self.tcpSocket readDataWithTimeout: -1 tag: 0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self addMessage:[NSString stringWithFormat:@"发送了:%@", self.sendTextField.text]];
}

#pragma mark - Actions
- (IBAction)doConnect:(id)sender
{
    NSError *error;
    BOOL isConnect = [self.tcpSocket connectToHost:self.hostTextField.text onPort:[self.portTextField.text intValue] withTimeout:-1 error:&error];
    if (isConnect) {
        NSLog(@"连接成功");
    }else {
        NSLog(@"连接失败");
    }
//    [self.tcpScoket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    [self.tcpSocket readDataWithTimeout:-1 tag:0];
}

- (IBAction)sendAction:(id)sender {
    [self.view endEditing:YES];
    NSData *data = [self.sendTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.tcpSocket writeData:data withTimeout:-1 tag:0];
}

#pragma mark - getter & setter
- (AsyncSocket *)tcpSocket
{
    if (!_tcpSocket) {
        _tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    return _tcpSocket;
}

- (NSMutableArray *)connectHostArr
{
    if (!_connectHostArr) {
        _connectHostArr = [[NSMutableArray alloc] init];
    }
    return _connectHostArr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
