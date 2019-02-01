//
//  BlockSelector.h
//  PolarisFramework
//
//  Created by overtheleaves on 31/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface BlockSelector : NSObject

@end

typedef void (^OBJCBlock)(id foo);

void class_addMethodWithBlock(Class class, SEL newSelector, OBJCBlock block);
