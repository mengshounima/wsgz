//
//  MyAnnotation.h
//  TMapDemo
//
//  Created by  on 13-1-14.
//  Copyright 2013 Tianditu Inc All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAnnotation.h"

@interface MyAnnotation : NSObject <TAnnotation> {
    NSString *_title;
    CLLocationCoordinate2D _coordinate;
}
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
