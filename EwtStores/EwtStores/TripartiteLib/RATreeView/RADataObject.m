
//The MIT License (MIT)
//
//Copyright (c) 2013 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RADataObject.h"

#define RADATANAME      @"RADataName"
#define RADATAID        @"RADataId"
#define RADATACHILDRED  @"RADataChildren"
#define RADATACHOICE    @"RADataIschoice"

@implementation RADataObject

- (id)initWithName:(NSString *)name children:(NSArray *)children
{
  self = [super init];
  if (self) {
    self.children = children;
    self.name = name;
  }
  return self;
}

- (id)initWithName:(NSString *)name pId:(NSString *)pId children:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.children = array;
        self.name = name;
        self.pId = pId;
    }
    return self;
}

- (id)initWithName:(NSString *)name pId:(NSString *)pId isChoice:(BOOL)choice children:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.children = array;
        self.name = name;
        self.pId = pId;
        self.isChoice = choice;
    }
    return self;
}

+ (id)dataObjectWithName:(NSString *)name children:(NSArray *)children
{
  return [[self alloc] initWithName:name children:children];
}

+ (id)dataObjectWithName:(NSString *)name pId:(NSString *)pId children:(NSArray *)children
{
    return [[self alloc] initWithName:name pId:pId children:children];
}

+ (id)dataObjectWithName:(NSString *)name pId:(NSString *)pId isChoice:(BOOL)choice children:(NSArray *)children
{
    return [[self alloc] initWithName:name pId:pId isChoice:choice children:children];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name      forKey:RADATANAME];
    [aCoder encodeObject:self.pId       forKey:RADATAID];
    [aCoder encodeObject:self.children  forKey:RADATACHILDRED];
    [aCoder encodeBool:  self.isChoice  forKey:RADATACHOICE];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.name       =   [aDecoder decodeObjectForKey:RADATANAME];
        self.pId        =   [aDecoder decodeObjectForKey:RADATAID];
        self.children   =   [aDecoder decodeObjectForKey:RADATACHILDRED];
        self.isChoice   =   [aDecoder decodeBoolForKey:RADATACHOICE];
    }
    return self;
}

@end
