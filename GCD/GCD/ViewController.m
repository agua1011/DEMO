//
//  ViewController.m
//  GCD
//
//  Created by Summer on 2017/4/24.
//  Copyright © 2017年 Summer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // GCD编程的核心就是dispatch队列，dispatch block的执行都会放到某个队列中执行
    // The main queue(主线程串行队列)，与主线程功能相同，提交至main queue的任务会在主线程中执行
    // main queue可以通过 dispatch_get_main_queue() 获得
    // dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // [self syncMain];
    
    //[self asyncMain];
    
    
    // Global queue(全局并发队列)，由整个线程共享，有高、中(默认)、低、后台四个优先级别
    // global queue可以通过 dispatch_get_global_queue(<#long identifier#>, <#unsigned long flags#>) 获得
    /*
     耗时的操作,比如读取网络数据,IO,数据库读写等, 我们会在另一个线程中处理这些操作, 然后通知主线程更新界面
     1.获取全局并发队列
     //程序默认的队列级别，一般不要修改,
     DISPATCH_QUEUE_PRIORITY_DEFAULT == 0
     dispatch_queue_t globalQueue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     //HIGH
     dispatch_queue_t globalQueue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
     //LOW
     dispatch_queue_t globalQueue3 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
     //BACKGROUND
     dispatch_queue_t globalQueue4 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    */
    
    // [self updateUI];
    
    //[self syncGlobal];
    
    
    // Custom queue(自定义队列)，可以为串行，也可以为并行
    // custom queue可以通过dispatch_queue_create(<#const char * _Nullable label#>, <#dispatch_queue_attr_t  _Nullable attr#>) 获得
    
    // 自定义串行队列
    // [self getSerialQueue];
    
    // [self serialQueueSync];
    
    // [self serialQueueSync2];
    
    // [self serialQueueSync3];
    
    // 自定义并发队列
    //[self getConCurrentQueue];
    
    // [self conCurrentQueue];
    
    // [self conCurrentQueue2];
    
    // [self conCurrentQueue3];
    
    // Group queue(队列组)，将多线程分组，最大的好处就是可以获知所有的线程完成情况
    // group queue可以通过调用 dispatch_group_create() 来获取，通过 dispatch_group_notify(<#dispatch_group_t  _Nonnull group#>, <#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)，可以直接监听组里所有线程完成情况
    // 1.使用场景: 同时下载多个图片,所有图片下载完成之后,去更新UI (需要回到主线程) 或者去处理其他任务 (可以是其他线程队列)
    // 2.原理: 使用函数 dispatch_group_create 创建 dispatch group , 然后使用函数 dispatch_group_async 来将要执行的block 任务提交到一个 dispatch queue. 同时将他们添加到一个组, 等要执行的block 任务全部执行完毕之后,使用 dispatch_group_notify 函数接收完成时的消息
    
   // [self groupQueue];
    
    // dispatch 其他用法
    [self dispatchOthers];
}

#pragma mark - 主线程串行队列同步执行任务，在主线程运行时会产生死锁，程序一直处于等待状态，block中代码将执行不到
- (void)syncMain
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        NSLog(@"sync");
    });
    
    // 主线程串行队列由系统默认生成的，所以无法调用dispatch_resume()和dispatch_suspend()来控制执行继续或中断。
}

#pragma mark - 主线程串行队列异步执行任务，在主线程运行，不会产生死锁。
- (void)asyncMain
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        NSLog(@"async");
    });
}

#pragma mark - 全局并发队列同步执行任务,在主线程会导致页面卡顿
- (void)syncGlobal
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"current task");
    dispatch_sync(globalQueue, ^{
        sleep(2.0);
        NSLog(@"sleep 2.0s");
    });
    NSLog(@"next task");
    
    //依次输出: "current task" "sleep 2.0s","next task",2s之后才会执行block后面的代码,会造成页面卡顿
}

#pragma mark - 从子线程异步返回主线程更新UI
- (void)updateUI
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行,不会造成卡顿
    dispatch_async(globalQueue, ^{
        // 子线程异步实现下载任务，防止主线程卡顿
        NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
        NSError *error;
        NSString *htmlData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (htmlData != nil) {
            // 回到主线程更新UI
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                NSLog(@"主线程更新UI");
            });
        } else {
            NSLog(@"下载失败");
        }
    });
}

#pragma mark - 多个全局并发队列，不会造成界面卡顿
- (void)asyncGlobalMoreTask
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"current task");
    dispatch_async(globalQueue, ^{
        NSLog(@"最先加入全局并发队列");
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"次加入全局并发队列");
    });
    NSLog(@"next task");
    /*
     异步线程的执行顺序是不确定的,几乎同步执行,全局并发队列有系统默认生成,，所以无法调用dispatch_resume()和dispatch_suspend()来控制执行继续或中断。
     */
}

#pragma mark - 获取自定义串行队列
- (void)getSerialQueue
{
    // dispatch_queue_create(const char *label, dispatch_queue_attr_t attr)函数中第一个参数是给这个queue起的标识，这个在调试的可以看到是哪个队列在执行，或者在crash日志中，也能做为提示。第二个是需要创建的队列类型，是串行的还是并发的
    dispatch_queue_t serialQueue = dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"%s",dispatch_queue_get_label(serialQueue));
}

#pragma mark - 自定义串行队列同步执行任务
- (void)serialQueueSync
{
    dispatch_queue_t serialQueue = dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"current task");
    dispatch_sync(serialQueue, ^{
        NSLog(@"最先加入自定义串行队列");
        sleep(2);
    });
    dispatch_sync(serialQueue, ^{
        NSLog(@"次加入自定义串行队列");
        sleep(2);
    });
    NSLog(@"next task");
    
    /*
     当前线程等待串行队列中的子线程执行完成之后再执行，串行队列中先进来的子线程先执行任务，执行完成后，再执行队列中后面的任务。
     */
}

#pragma mark - 自定义串行队列嵌套执行同步任务，产生死锁
- (void)serialQueueSync2
{
    dispatch_queue_t serialQueue = dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{   //该代码段后面的代码都不会执行，程序被锁定在这里
        NSLog(@"会执行的代码");
        dispatch_sync(serialQueue, ^{
            NSLog(@"代码不执行");
        });
    });
    /****************    注意不要嵌套使用同步执行的串行队列任务    ****************/
}

#pragma mark - 异步执行串行队列，嵌套同步执行串行队列，同步执行的串行队列中的任务将不会被执行，其他程序正常执行
- (void)serialQueueSync3
{
    dispatch_queue_t serialQueue = dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serialQueue, ^{
        NSLog(@"会执行的代码");
        dispatch_sync(serialQueue, ^{
            NSLog(@"代码不执行");
        });
    });
    /****************    注意不要嵌套使用同步执行的串行队列任务    ****************/
}


#pragma mark - 自定义并发队列
- (void)getConCurrentQueue
{
    // 获取自定义并发队列
    dispatch_queue_t conCurrentQueue = dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"%s",dispatch_queue_get_label(conCurrentQueue));
}

#pragma mark - 自定义并发队列同步执行任务
- (void)conCurrentQueue
{
    dispatch_queue_t conCurrentQueue = dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"current task");
    dispatch_sync(conCurrentQueue, ^{
        NSLog(@"先加入队列");
    });
    dispatch_sync(conCurrentQueue, ^{
        NSLog(@"次加入队列");
    });
    NSLog(@"next task");
    
    //任务自上而下依次执行
}
#pragma mark - 自定义并发队列嵌套执行同步任务（任务不会产生死锁，程序正常执行）
- (void)conCurrentQueue2
{
    dispatch_queue_t conCurrentQueue = dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"current task");
    dispatch_sync(conCurrentQueue, ^{
        NSLog(@"先加入队列");
        dispatch_sync(conCurrentQueue, ^{
            NSLog(@"次加入队列");
        });
    });
    NSLog(@"next task");
}

#pragma mark - 自定义并发队列执行异步任务
- (void)conCurrentQueue3
{
    dispatch_queue_t conCurrentQueue =   dispatch_queue_create("MrLiu.serialQueue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"current task");
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"先加入队列");
    });
    dispatch_async(conCurrentQueue, ^{
        NSLog(@"次加入队列");
    });
    NSLog(@"next task");
    
    // 异步执行任务，开启新的子线程，不影响当前线程任务的执行，并发队列中的任务，几乎是同步执行的，输出顺序不确定
}

#pragma mark - 队列组
- (void)groupQueue
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_group_t groupQueue = dispatch_group_create();
    NSLog(@"current task");
    dispatch_group_async(groupQueue, globalQueue, ^{
        NSLog(@"并行任务1");
    });
    dispatch_group_async(groupQueue, globalQueue, ^{
        NSLog(@"并行任务2");
    });
    dispatch_group_notify(groupQueue, mainQueue, ^{
        NSLog(@"groupQueue中的任务 都执行完成,回到主线程更新UI");
    });
    NSLog(@"next task");
    
    // 输出顺序
    // 1.current task
    // 2.next task
    // 3.并行任务1
    // 4.并行任务2
    // groupQueue中的任务 都执行完成,回到主线程更新UI
}

#pragma mark - group wait
- (void)groupWait
{
    dispatch_group_t groupQueue = dispatch_group_create();
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    dispatch_queue_t conCurrentGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"current task");
    dispatch_group_async(groupQueue, conCurrentGlobalQueue, ^{
        
        long isExecuteOver = dispatch_group_wait(groupQueue, delayTime);
        if (isExecuteOver) {
            NSLog(@"wait over");
        } else {
            NSLog(@"not over");
        }
        NSLog(@"并行任务1");
    });
    dispatch_group_async(groupQueue, conCurrentGlobalQueue, ^{
        NSLog(@"并行任务2");
    });
}

#pragma mark - dispatch其他用法
- (void)dispatchOthers
{
    // GCD中一些系统提供的常用dispatch方法
    
    // 1.dispatch_after 延时添加到队列
    dispatch_time_t delayTime3 = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
    dispatch_time_t delayTime2 = dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSLog(@"current task");
    dispatch_after(delayTime3, mainQueue, ^{
        NSLog(@"3秒之后添加到队列");
    });
    dispatch_after(delayTime2, mainQueue, ^{
        NSLog(@"2秒之后添加到队列");
    });
    NSLog(@"next task");
    // dispatch_after 只是延时提交block,并不是延时后立即执行,并不能做到精准控制
    
    /*
     第一个参数一般是DISPATCH_TIME_NOW，表示从现在开始
     第二个参数是延时的具体时间
     延时1秒可以写成如下几种：
     NSEC_PER_SEC----每秒有多少纳秒
     dispatch_time(DISPATCH_TIME_NOW, 1NSEC_PER_SEC);
     USEC_PER_SEC----每秒有多少毫秒（注意是指在纳秒的基础上）
     dispatch_time(DISPATCH_TIME_NOW, 1000USEC_PER_SEC); //SEC---毫秒
     NSEC_PER_USEC----每毫秒有多少纳秒。
     dispatch_time(DISPATCH_TIME_NOW, USEC_PER_SEC*NSEC_PER_USEC);SEC---纳秒
     */
}



@end
