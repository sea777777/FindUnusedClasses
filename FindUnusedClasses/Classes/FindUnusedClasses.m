//
//  FindUnusedClasses.m
//  wojiubuxinle
//
//  Created by 刘彦超 on 2020/9/2.
//  Copyright © 2020 刘彦超. All rights reserved.
//

#import "FindUnusedClasses.h"
#import <dlfcn.h>
#import <libkern/OSAtomicQueue.h>
#import <pthread.h>
#import <objc/message.h>
#import <objc/runtime.h>



static OSQueueHead queue = OS_ATOMIC_QUEUE_INIT;

static BOOL collectFinished = NO;

typedef struct {
    void *pc;
    void *next;
} PCNode;


@implementation FindUnusedClasses



+ (NSArray *)findAllClasses:(Class)notSystemClass{
    
    int numClasses;
    Class * classes = NULL;
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    NSMutableArray *classArr = [NSMutableArray new];

    struct dl_info dlInfo;
     
    //利用 dlInfo 存放一个自定义类（notSystemClass）的路径
    dladdr((__bridge void *)notSystemClass, &dlInfo);
    const char *userLibraryPath = dlInfo.dli_fname;
    
    if (numClasses > 0 )
    {
        //重新分配空间
        classes = (Class *)realloc(classes, sizeof(Class) * numClasses);
       
        //获取 register 的所有类列表
        numClasses = objc_getClassList(classes, numClasses);
        
        for (int i = 0; i < numClasses; i++) {
            Class cls = classes[i];
            
            struct dl_info currentClassInfo = {0};
            dladdr((__bridge void *)cls, &currentClassInfo);
            
            if (currentClassInfo.dli_fname != NULL && userLibraryPath == currentClassInfo.dli_fname) {
                NSString *clsName = NSStringFromClass(cls);
                clsName = [clsName stringByReplacingOccurrencesOfString:@"PodsDummy_" withString:@""];
                [classArr addObject:clsName];
            }
        }
        free(classes);
    }
    return classArr;
}


void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                         uint32_t *stop) {
    static uint32_t N;
    if (start == stop || *start) return;
    printf("INIT: %p %p\n", start, stop);
    
    for (uint32_t *x = start; x < stop; x++){
        *x = ++N;
    }
}



void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    if (collectFinished || !*guard) {
        return;
    }
    
    *guard = 0;
    void *PC = __builtin_return_address(0);
    PCNode *node = malloc(sizeof(PCNode));
    *node = (PCNode){PC, NULL};
    OSAtomicEnqueue(&queue, node, offsetof(PCNode, next));
}



+ (NSArray *)allUnusedClasses:(Class)notSystemClass{
    
    if (!notSystemClass) return nil;
    
    collectFinished = YES;
    
    NSMutableArray <NSString *> *calledClasses = [NSMutableArray array];
    while (YES) {
        PCNode *node = OSAtomicDequeue(&queue, offsetof(PCNode, next));
        if (node == NULL) {
            break;
        }
        Dl_info info = {0};
        dladdr(node->pc, &info);
        if (info.dli_sname) {
            NSString *name = @(info.dli_sname);
            BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
            if (isObjc) { //swift 后面会支持，暂时只支持objc
                NSRange range = [name rangeOfString:@" "];
                name = [name substringWithRange:NSMakeRange(2, range.location - 2)];
                if (![calledClasses containsObject:name]) {
                    [calledClasses addObject:name];
                }
            }
        }
    }
    if (calledClasses.count == 0) {
        return nil;
    }
    
    NSArray *allClassArray = [FindUnusedClasses findAllClasses:notSystemClass];
    NSMutableArray *clsArray = [allClassArray mutableCopy];
    [clsArray removeObjectsInArray:calledClasses];
    NSLog(@"unused Classes：----- %@",clsArray);
    return clsArray;
}



@end
