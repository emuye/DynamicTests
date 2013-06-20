//
//  ViewController.h
//  Dynamic Tests
//
//  Created by Emuye Reynolds on 6/19/13.
//  Copyright (c) 2013 Emuye Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
@private
//    UIDynamicAnimator *_animator;
//    UICollisionBehavior *_collision;
    UIGravityBehavior *_gravity;
    UICollectionView *_collectionView;
}

@property ( nonatomic, readwrite, assign ) UIButton *refreshButton;

@end
