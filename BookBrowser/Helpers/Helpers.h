//
//  Helpers.h
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helpers : NSObject

+ (NSString *)encodURLParameterString:(NSString *)string;
+ (CGSize) cellSizeForViewController:(UIViewController *)vc;
+ (void) centerView:(UIView *)v1 within:(UIView *)v2 direction:(NSLayoutAttribute)direction;

@end
