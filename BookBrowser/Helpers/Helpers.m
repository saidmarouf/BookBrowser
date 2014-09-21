//
//  Helpers.m
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import "Helpers.h"
#import "BooksViewController.h"

@implementation Helpers

+ (NSString *)encodURLParameterString:(NSString *)string {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (CFStringRef)string,
                                                                                             NULL,
                                                                                             CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                                             kCFStringEncodingUTF8));
    return result;
}

+ (void) centerView:(UIView *)v1 within:(UIView *)v2 direction:(NSLayoutAttribute)direction {

    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                                 constraintWithItem:v1
                                                 attribute:direction
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:v2
                                                 attribute:direction
                                                 multiplier:1.0
                                                 constant:0];
    [v2 addConstraint:constraint];
}

/*
 Cell Helpers
 */

+ (CGSize) cellSizeForViewController:(UIViewController *)vc {
    
    NSUInteger width = CGRectGetWidth(vc.view.bounds);
    //experimented with sizes and spacing that approximate measurements to adaptive sizes - given the new iPhone 6 and 6+
    NSUInteger minCellWidth = 155;
    NSUInteger minCellHeight = 155;
    NSUInteger spacing = 10 + 2*collectionViewSpacing;
    NSUInteger landscape_spacing = 2*collectionViewSpacing;
    
    BOOL iPhoneLandscape = (vc.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact
                            && vc.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact);
    BOOL iPhonePlus = (vc.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
                       && vc.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact);
    BOOL iPad = (vc.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
                 && vc.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular);
    
    if(iPad || iPhonePlus || iPhoneLandscape) {
        //3 squares
        NSUInteger projectedCellWidth = floor((width - 2*landscape_spacing)/3.0);
        minCellHeight = projectedCellWidth;
        minCellWidth = projectedCellWidth;
    }
    else {
        //2 squares
        NSUInteger projectedCellWidth = floor((width - spacing)/2.0);
        minCellHeight = projectedCellWidth;
        minCellWidth = projectedCellWidth;
    }
    
    return CGSizeMake(minCellWidth, minCellHeight);
}

@end
