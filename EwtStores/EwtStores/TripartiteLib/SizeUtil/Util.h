//
//  Util.h
//  Util
//
//  Created by Harry on 12/31/11.
//  Copyright (c) 2014 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

//循环1000次，两者之间巨大的性能差距了，在测试环境中，结果：c函数的耗时仅是第一种方法的5%
// 方法1：使用NSFileManager来实现获取文件大小
+ (long long) fileSizeAtPath1:(NSString*) filePath;
// 方法1：使用unix c函数来实现获取文件大小
+ (long long) fileSizeAtPath2:(NSString*) filePath;


// 方法1：循环调用fileSizeAtPath1
+ (long long) folderSizeAtPath1:(NSString*) folderPath;
// 方法2：循环调用fileSizeAtPath2
+ (long long) folderSizeAtPath2:(NSString*) folderPath;
// 方法2：在folderSizeAtPath2基础之上，去除文件路径相关的字符串拼接工作
+ (long long) folderSizeAtPath3:(NSString*) folderPath;

@end
