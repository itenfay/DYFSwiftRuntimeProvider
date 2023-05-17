//
//  RuntimeObjcSample.h
//
//  Created by chenxing on 2023/2/10.
//  Copyright © 2023 chenxing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DYFRuntimeProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface Teacher : NSObject
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;

- (void)eatWithFoods:(NSDictionary *)foods;
- (void)runWithStep:(NSInteger)step;
- (void)run2WithStep:(NSInteger)step;

+ (void)decInfo:(NSString *)name age:(NSInteger)age;
+ (void)decInfo2:(NSString *)name age:(NSInteger)age;

@end

@interface UIApplication (Pt)
@property (nonatomic, strong) Teacher *teacher;
@end

@interface RuntimeObjcSample : NSObject

- (void)test;

@end

@protocol OPActionDelegate <NSObject>
@required
- (void)walk:(int)step;

@end

@interface OPcx : NSObject <OPActionDelegate>
@property (nonatomic, readonly) int value;
@property (nonatomic, copy) NSString *name;
@end

NS_ASSUME_NONNULL_END


