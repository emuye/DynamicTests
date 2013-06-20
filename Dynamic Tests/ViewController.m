//
//  ViewController.m
//  Dynamic Tests
//
//  Created by Emuye Reynolds on 6/19/13.
//  Copyright (c) 2013 Emuye Reynolds. All rights reserved.
//

#import "ViewController.h"

@interface DynamicCollectionViewFlowLayout : UICollectionViewFlowLayout
@property ( readwrite, nonatomic, retain ) UIDynamicAnimator *animator;
@property ( readwrite, nonatomic, retain ) UICollisionBehavior *collision;
@property ( readwrite, nonatomic, retain ) UIGravityBehavior *gravity;
@property ( readwrite, nonatomic, retain ) UIAttachmentBehavior *attachment;
@property ( readwrite, nonatomic, retain ) UIPushBehavior *push;

- (void)panBeganForItemAtIndexPath:(NSIndexPath *)indexPath translation:(CGPoint)translation;
- (void)panChangedForItemAtIndexPath:(NSIndexPath *)indexPath translation:(CGPoint)translation;
- (void)panEndedForItemAtIndexPath:(NSIndexPath *)indexPath translation:(CGPoint)translation;

@end

@interface ViewController () <UICollectionViewDataSource, UIDynamicAnimatorDelegate>
@end

@implementation ViewController

@synthesize
refreshButton = _refreshButton;

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    float blockSize = 59;
//    
//    UIView *block1 = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, blockSize, blockSize )];
//    block1.backgroundColor = [UIColor redColor];
//    [self.view addSubview:block1];
//    
//    UIView *block2 = [[UIView alloc] initWithFrame:CGRectMake( 0, self.view.bounds.size.height - blockSize, blockSize, blockSize)];
//    block2.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:block2];
//    
//    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//    
//    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[block1]];
//    gravity.yComponent = 1.0f;
//    [_animator addBehavior:gravity];
//    
////    gravity = [[UIGravityBehavior alloc] initWithItems:@[block2]];
////    gravity.yComponent = -1.0f;
////    [_animator addBehavior:gravity];
//    
//    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[block1, block2]];
//    collision.collisionMode = UICollisionBehaviorModeBoundaries;
//    [collision addBoundaryWithIdentifier:@"block2" forPath:[UIBezierPath bezierPathWithRect:block2.frame]];
//    [_animator addBehavior:collision];
//    
//    //    UIDynamicItemBehavior *spring = [[UIDynamicItemBehavior alloc] initWithItems:@[block1, block2]];
//    //    spring.elasticity = 5.0f;
//    //    [_animator addBehavior:spring];
//    
//    //    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[block1] mode:UIPushBehaviorModeInstantaneous];
//    //    [push setYComponent:1];
//    //    [_animator addBehavior:push];
//    
//    //    push = [[UIPushBehavior alloc] initWithItems:@[block2] mode:UIPushBehaviorModeInstantaneous];
//    //    [push setYComponent:-1];
//    //    [_animator addBehavior:push];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DynamicCollectionViewFlowLayout *grid = [[DynamicCollectionViewFlowLayout alloc] init];
    grid.itemSize = CGSizeMake( 50, 50 );
    
    float padding = 20;
    grid.sectionInset = UIEdgeInsetsMake( padding, padding, padding, padding );
    
    _refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_refreshButton setTitle:@"refresh" forState:UIControlStateNormal];
    _refreshButton.frame = CGRectMake( 10, 10, 100, 40 );
    [_refreshButton addTarget:self action:@selector(refreshSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_refreshButton];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake( 0, 50, self.view.bounds.size.width, self.view.bounds.size.height  - 50) collectionViewLayout:grid];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    ((DynamicCollectionViewFlowLayout *)_collectionView.collectionViewLayout).animator.delegate = self;
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator
{
    _refreshButton.tintColor = [UIColor greenColor];
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator
{
    _refreshButton.tintColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundView.backgroundColor = indexPath.row % 2 == 0 ? [UIColor redColor] : [UIColor blueColor];
    cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor redColor] : [UIColor blueColor];
    cell.tag = indexPath.row;
    UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, 50, 50 )];
    number.text = [NSString stringWithFormat:@"%d", indexPath.row];
    number.tag = 1;
    number.textColor = [UIColor whiteColor];
    number.textAlignment = NSTextAlignmentCenter;
    [[cell contentView] addSubview:number];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(itemPanned:)];
    [cell addGestureRecognizer:panGestureRecognizer];
    
     return cell;
}
     
- (void)itemPanned:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ( ((DynamicCollectionViewFlowLayout *)_collectionView.collectionViewLayout).animator.delegate  == nil )
    {
        ((DynamicCollectionViewFlowLayout *)_collectionView.collectionViewLayout).animator.delegate = self;
    }

    UIView *cell = gestureRecognizer.view;
    CGPoint translation = [gestureRecognizer translationInView:[cell superview]];

    switch ( [gestureRecognizer state] ) {
        case UIGestureRecognizerStateBegan:
            [(DynamicCollectionViewFlowLayout *)_collectionView.collectionViewLayout panBeganForItemAtIndexPath:[NSIndexPath indexPathForRow:cell.tag inSection:0] translation:translation];
            break;
            
        case UIGestureRecognizerStateChanged:
            [(DynamicCollectionViewFlowLayout *)_collectionView.collectionViewLayout panChangedForItemAtIndexPath:[NSIndexPath indexPathForRow:cell.tag inSection:0] translation:translation];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [(DynamicCollectionViewFlowLayout *)_collectionView.collectionViewLayout panEndedForItemAtIndexPath:[NSIndexPath indexPathForRow:cell.tag inSection:0] translation:translation];
            break;

    }
    
    [gestureRecognizer setTranslation:CGPointZero inView:[cell superview]];
}

- (void)refreshSelected
{
    ((DynamicCollectionViewFlowLayout *)_collectionView.collectionViewLayout).animator = nil;
    [_collectionView.collectionViewLayout invalidateLayout];
}

@end

@implementation DynamicCollectionViewFlowLayout

@synthesize
animator = _animator,
collision = _collision,
gravity = _gravity,
attachment = _attachment,
push = _push;

- (void)prepareLayout
{
    [super prepareLayout];
    
    if ( !_animator )
    {
        _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
                
        CGSize contentSize = [self collectionViewContentSize];
        NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake( 0, 0, contentSize.width, contentSize.height )];
        
        UIDynamicItemBehavior *resistance = [[UIDynamicItemBehavior alloc] initWithItems:items];
        resistance.resistance = 1;
        resistance.angularResistance = 1;
        [_animator addBehavior:resistance];

        UIDynamicItemBehavior *spring = [[UIDynamicItemBehavior alloc] initWithItems:items];
        spring.elasticity = 0.5;
        [_animator addBehavior:spring];

        _collision = [[UICollisionBehavior alloc] initWithItems:items];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        [_animator addBehavior:_collision];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [_animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_animator layoutAttributesForCellAtIndexPath:indexPath];
}

- (void)panBeganForItemAtIndexPath:(NSIndexPath *)indexPath translation:(CGPoint)translation
{
    UICollectionViewLayoutAttributes *item = [self layoutAttributesForItemAtIndexPath:indexPath];
    
    [_animator removeBehavior:_attachment];
    _attachment = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    _attachment.length = 0;
    [_animator addBehavior:_attachment];
}

- (void)panChangedForItemAtIndexPath:(NSIndexPath *)indexPath translation:(CGPoint)translation
{
    UICollectionViewLayoutAttributes *item = [self layoutAttributesForItemAtIndexPath:indexPath];
    CGPoint center = item.center;
    center.x += translation.x;
    center.y += translation.y;
    [_attachment setAnchorPoint:center];
}

- (void)panEndedForItemAtIndexPath:(NSIndexPath *)indexPath translation:(CGPoint)translation
{
    UICollectionViewLayoutAttributes *item = [self layoutAttributesForItemAtIndexPath:indexPath];

    [_animator removeBehavior:_attachment];
    
    [_animator removeBehavior:_gravity];
    _gravity = [[UIGravityBehavior alloc] initWithItems:@[item]];
    _gravity.yComponent = 0.5;
    [_animator addBehavior:_gravity];
    
//    UIDynamicItemBehavior *spring = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
//    spring.elasticity = 0.5;
//    [_animator addBehavior:spring];
}

@end
