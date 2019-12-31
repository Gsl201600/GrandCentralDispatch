//
//  ViewController.m
//  GrandCentralDispatch
//
//  Created by Yostar on 2019/12/31.
//  Copyright © 2019 Yostar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
// 一个接口的请求，依赖于另一个请求的结果
//    [self dispatchGroup];
//    [self dispatchBarrier];
//    [self dispatchSemaphore];
    
//  在异步线程中return一个字符串
    NSLog(@"%@",[self nameStr]);
    NSLog(@"next");
    
}

#pragma mark - 一个接口的请求，依赖于另一个请求的结果

// 使用GCD组队列中的dispatch_group_async和dispatch_group_notify
- (void)dispatchGroup{
    dispatch_queue_t queue = dispatch_queue_create("com.test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        // 请求1
        NSLog(@"11111");
    });
    
    dispatch_group_notify(group, queue, ^{
        // 请求2
        NSLog(@"2222222");
    });
}

//使用GCD的栅栏dispatch_barrier_async
- (void)dispatchBarrier{
    dispatch_queue_t queue = dispatch_queue_create("com.test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 请求1
        NSLog(@"11111");
    });
    
    dispatch_barrier_async(queue, ^{
        // 请求2
        NSLog(@"22222");
    });
}

//使用GCD的信号量dispatch_semaphore,信号量的初始值可以用来控制线程并发访问的最大数量。如果设置为 1 则为串行执行，达到 线程同步的目的
- (void)dispatchSemaphore{
    dispatch_queue_t queue = dispatch_queue_create("com.test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(queue, ^{
        NSLog(@"11111");
        // 请求1结束后 增加信号个数,dispatch_semaphore_signal()信号加1
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(queue, ^{
        // 无限等待,直到请求1结束 增加了信号量,大于0后才开始,dispatch_semaphore_wait()信号减1
        // 如果信号量的值 > 0，就让信号量的值减1，然后继续往下执行代码
        // 如果信号量的值 <= 0，就会休眠等待，直到信号量的值变成>0，就让信号量的值减1，然后继续往下执行代码
        // DISPATCH_TIME_FOREVER 这个是一直等待的意思
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 请求2开始
        NSLog(@"22222");
    });
}

#pragma mark - 在异步线程中return一个字符串

// 1.-----while循环等待阻塞线程方法-----
//- (NSString *)nameStr{
//    __block NSString *nameStr = @"小关";
//    __block BOOL isSleep = YES;
//
//    [self asyncRequestMethod:^(NSString *name) {
//        nameStr = name;
//        NSLog(@"1");
//        isSleep = NO;
//        NSLog(@"3");
//    }];
//
//    //while循环等待阻塞线程
//    while (isSleep) {
//        NSLog(@"4");
//    }
//
//    NSLog(@"2");
//
//    return nameStr;
//}
// -----while循环等待阻塞线程方法-end----

// 2.-----用信号量控制,异步改同步----
- (NSString *)nameStr{
    __block NSString *nameStr = @"小关";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self asyncRequestMethod:^(NSString *name) {
        nameStr = name;
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return nameStr;
}
// -----用信号量控制,异步改同步-end----

// 3.-----利用dispatch_group_t调度组,异步改同步-----
//- (NSString *)nameStr{
//    __block NSString *nameStr = @"小关";
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_enter(group);
//
//    [self asyncRequestMethod:^(NSString *name) {
//        nameStr = name;
//        dispatch_group_leave(group);
//    }];
//
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//
//    return nameStr;
//}
// -----用dispatch_group_t调度组,异步改同步-end----

- (void)asyncRequestMethod:(void(^)(NSString *name))successBlock{
    dispatch_queue_t queue = dispatch_queue_create("com.test", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (successBlock) {
            successBlock(@"小熊");
        }
    });
}

@end
