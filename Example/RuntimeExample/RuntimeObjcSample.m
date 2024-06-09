//
//  RuntimeObjcSample.m
//
//  Created by Tenfay on 2023/2/10.
//  Copyright © 2023 Tenfay. All rights reserved.
//

#import "RuntimeObjcSample.h"

static NSString *kTeacherKey = @"TeacherKey";

@implementation UIApplication (Pt)

- (Teacher *)teacher
{
    return (Teacher *)[DYFRuntimeProvider getAssociatedObject:self key:&kTeacherKey];
}

- (void)setTeacher:(Teacher *)teacher
{
    [DYFRuntimeProvider setAssociatedObject:self key:&kTeacherKey value:teacher policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

@end

@implementation Teacher

- (void)eatWithFoods:(NSDictionary *)foods
{
    NSLog(@"========%@ eat foods: %@", _name, foods);
}

- (void)runWithStep:(NSInteger)step
{
    NSLog(@"========%s 1 %@ runs %ld steps", __func__, _name, step);
}

- (void)run2WithStep:(NSInteger)step
{
    NSLog(@"========%s 2 %@ runs %ld steps", __func__, _name, step);
}

+ (void)decInfo:(NSString *)name age:(NSInteger)age
{
    NSLog(@"========decInfo name: %@, age: %ld", name, age);
}

+ (void)decInfo2:(NSString *)name age:(NSInteger)age
{
    NSLog(@"========decInfo2 name: %@, age: %ld", name, age);
}

@end

void rt_eatWithFoods2(id self, SEL _cmd, NSDictionary *foods)
{
    NSLog(@"========%@, %@ eat foods: %@", self, NSStringFromSelector(_cmd), foods);
}

@interface RuntimeObjcSample ()

@end

#define TFLogMessageFormat(m) ([NSString stringWithFormat:@"[F: %s, M: %s, L: %d] %@",  __FILE__, __PRETTY_FUNCTION__, __LINE__, (m)])

@implementation RuntimeObjcSample

- (void)run
{
    SEL eatSel = NSSelectorFromString(@"rt_eatWithFoods:");
    [DYFRuntimeProvider addMethodWithClass:Teacher.class selector:eatSel impSelector:@selector(eatWithFoods:)];
    
    SEL eatSel2 = NSSelectorFromString(@"eatWithFoods2:");
    [DYFRuntimeProvider addMethodWithClass:Teacher.class selector:eatSel2 imp:(IMP)rt_eatWithFoods2 types:"v@:@"];
    
    [DYFRuntimeProvider replaceMethodWithClass:Teacher.class selector:@selector(runWithStep:) targetSelector:@selector(run2WithStep:)];
    //[DYFRuntimeProvider exchangeMethodWithClass:Teacher.class selector:@selector(runWithStep:) anotherSelector:@selector(run2WithStep:)];
    //[DYFRuntimeProvider exchangeClassMethodWithClass:Teacher.class selector:@selector(decInfo:age:) anotherSelector:@selector(decInfo2:age:)];
    [DYFRuntimeProvider swizzleMethodWithClass:Teacher.class selector:@selector(runWithStep:) swizzledSelector:@selector(run2WithStep:)];
    [DYFRuntimeProvider swizzleClassMethodWithClass:Teacher.class selector:@selector(decInfo:age:) swizzledSelector:@selector(decInfo2:age:)];
    
    NSArray *clsMethods = [DYFRuntimeProvider getClassMethodListWithClass:UIView.class];
    NSLog(@"========UIView.clsMethods: %@", clsMethods);
    
    NSArray *instMethods = [DYFRuntimeProvider getMethodListWithClass:UITableView.class];
    NSLog(@"========UITableView.instMethods: %@", instMethods);
    
    NSArray *properties = [DYFRuntimeProvider getPropertyListWithClass:UIButton.class];
    NSLog(@"========UIButton.properties: %@", properties);
    
    NSArray *ivars = [DYFRuntimeProvider getIvarListWithClass:UIButton.class];
    NSLog(@"========UIButton.ivars: %@", ivars);
    
    Teacher *teacher = (Teacher *)[DYFRuntimeProvider asObjectWithDictionary:@{@"name": @"高粟", @"age": @26, @"address": @"xx市xx"} forClass:Teacher.class];
    if (teacher) {
        NSLog(@"========teacher: %@, %@, %ld, %@", teacher, teacher.name, (long)teacher.age, teacher.address);
    }
    
    Teacher *teacher2 = [[Teacher alloc] init];
    [DYFRuntimeProvider asObjectWithDictionary:@{@"name": @"高粟", @"age": @26, @"address": @"xx市xx"} forObject:teacher2];
    NSLog(@"========teacher2: %@, %@, %ld, %@", teacher2, teacher2.name, (long)teacher2.age, teacher2.address);
    
    NSDictionary *dict = [DYFRuntimeProvider asDictionaryWithObject:teacher];
    NSLog(@"========dict: %@", dict);
    
    NSString *teacherName = [DYFRuntimeProvider getInstanceVarWithName:@"_name" forObject:teacher];
    NSLog(@"========teacher name: %@", teacherName);
    [DYFRuntimeProvider setInstanceVarWithName:@"_name" value:@"李想" forObject:teacher];
    NSLog(@"========teacher newName: %@", teacher.name);
    
    UIApplication.sharedApplication.teacher = teacher2;
    NSLog(@"========teacher: %@", UIApplication.sharedApplication.teacher);
    
    if ([teacher respondsToSelector:eatSel]) {
        [teacher performSelector:eatSel withObject:@{@"name": @"meat", @"number": @1}];
    }
    
    if ([teacher respondsToSelector:eatSel2]) {
        [teacher performSelector:eatSel2 withObject:@{@"name": @"meat", @"number": @1}];
    }
    
    [teacher runWithStep:50];
    [teacher run2WithStep:100];
    
    [Teacher decInfo:@"David" age:40];
    [Teacher decInfo2:@"Liming" age:28];
}

@end

@implementation OPcx

- (instancetype)initWithValue:(int)value
{
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (void)walk:(int)step
{
    NSAssert(step > 0, @"Steps must be more than zero.");
    NSLog(@"%@ walks %d steps", _name, step);
}

@end
