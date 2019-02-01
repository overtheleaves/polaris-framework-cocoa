//
//  BlockSelector.m
//  PolarisFramework
//
//  Created by overtheleaves on 31/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

#import "BlockSelector.h"
#import <objc/runtime.h>

@implementation BlockSelector
@end

void class_addMethodWithBlock(Class class, SEL newSelector, OBJCBlock block)
{
    IMP newImplementation = imp_implementationWithBlock(block);
    Method method = class_getInstanceMethod(class, newSelector);
    class_addMethod(class, newSelector, newImplementation, method_getTypeEncoding(method));
}
