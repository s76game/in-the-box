//
//  NormalStrategic.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 6/30/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "NormalStrategic.h"

@interface NormalStrategic ()
@property BOOL contentCreated;

@property (weak, nonatomic) id <sceneDelegate, resetSKScene> delegate;

@end


@implementation NormalStrategic

- (void)didMoveToView:(SKView *)view
{
	if (!self.contentCreated)
	{
		[self createSceneContents];
		self.contentCreated = YES;
		
	}
}

-(void)screenSize {
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	screenWidth = screenRect.size.width;
	screenHeight = screenRect.size.height;
}

- (void)createSceneContents
{
	[self screenSize];
	
	// Set up score
	score = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth/2)-25, 25, 300, 50)];
	[self.view addSubview:score];
	scoreNumber = 0;
	score.text = @"Time";
	[score setFont:[UIFont fontWithName:@"Prototype" size:25]];
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		score.textColor = [UIColor whiteColor];
	}
	
	
	
	// Set up background texture
	NSString *textureName;
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		textureName = @"nightbackgroundplain.png";
	}
	else {
		textureName = @"normalbackground.png";
	}

	SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@", textureName]];
	SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:self.view.frame.size];
	background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
	[self addChild:background];
	
	// Add start game button
	
	start = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[start addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
	start.frame = CGRectMake(((screenWidth/2)-65), 150, 130, 40);
	[start setBackgroundImage:[UIImage imageNamed:@"normalgo.png"] forState:UIControlStateNormal];
	[self.view addSubview:start];
	
	// Set up scene
	
	// Set up border physics
	self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
	self.physicsBody.categoryBitMask = edgeCategory;
	self.physicsBody.contactTestBitMask = edgeCategory;
	self.physicsWorld.contactDelegate = self;
	self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
	
	// Set up border graphics
	border = [SKShapeNode node];
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, 1, 1);
	CGPathAddLineToPoint(path, NULL, 1, (screenHeight-1));
	CGPathAddLineToPoint(path, NULL, (screenWidth-1), (screenHeight-1));
	CGPathAddLineToPoint(path, NULL, (screenWidth-1), 1);
	CGPathAddLineToPoint(path, NULL, 1, 1);
	
	border.path = path;
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[border setStrokeColor:[UIColor whiteColor]];
	}
	else {
		[border setStrokeColor:[UIColor blackColor]];
	}
	[border setLineWidth:5];
	
	[self addChild:border];
	
	
	
	ball = [self newBall];
	ball.position = CGPointMake(CGRectGetMidX(self.frame),                              CGRectGetMidY(self.frame));
	[self addChild:ball];
	
	remove = [SKAction removeFromParent];
	
	// Start random direction code
	int smallest = 1;
	int largest = 2;
	x = smallest + arc4random() %(largest+1-smallest);
	y = smallest + arc4random() %(largest+1-smallest);
	
	switch (x) {
  case 1:
			x = 15.0f;
			break;
  case 2:
			x = -15.0f;
			break;
  default:
			break;
	}
	switch (y) {
  case 1:
			y = 15.0f;
			break;
  case 2:
			y = -15.0f;
			break;
  default:
			break;
	}
	
	// Alloc cracked view image
	screenCrack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glassoverlay.png"]];
	screenCrack.frame = self.frame;
	
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (!gameOver && !dotDrawn && gameStarted) {
		
		[self removeLine];
		
		dotDrawn = YES;
		
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
		
		pos1x = positionInScene.x;
		pos1y = positionInScene.y;
		
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
		[self removeLine];
	
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
	
		pos2x = positionInScene.x;
		pos2y = positionInScene.y;
	
	
		NSString *textureName;
	
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			textureName = @"normalball.png";
		}
		else {
			textureName = @"normalball.png";
		}
	
	
		lines = [SKShapeNode node];
	
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, pos1x, pos1y);
		CGPathAddLineToPoint(path, NULL, pos2x, pos2y);
	
		lines.path = path;
		[lines setStrokeColor:[UIColor grayColor]];
		[lines setLineWidth:3];
	
		[self addChild:lines];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
		[self removeLine];
	
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
	
		pos2x = positionInScene.x;
		pos2y = positionInScene.y;

	
		NSString *textureName;
	
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			textureName = @"normalball.png";
		}
		else {
			textureName = @"normalball.png";
		}
	
	
		line = [[SKSpriteNode alloc] init];
		[self addChild:line];
		line.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(pos1x, pos1y) toPoint:CGPointMake(pos2x-line.position.x, pos2y-line.position.y)];
		line.physicsBody.dynamic = NO;
		line.physicsBody.categoryBitMask = lineCategory;
		line.physicsBody.collisionBitMask = ballCategory;
		line.physicsBody.contactTestBitMask = lineCategory;
		
		lines = [SKShapeNode node];
	
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, pos1x, pos1y);
		CGPathAddLineToPoint(path, NULL, pos2x, pos2y);
	
		lines.path = path;
		[lines setStrokeColor:[UIColor blackColor]];
		[lines setLineWidth:3];
	
		[self addChild:lines];
}


- (SKSpriteNode *)newBall
{
	// Generates new ball
	
	NSString *textureName;
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		textureName = @"normalball.png";
	}
	else {
		textureName = @"normalball.png";
	}
	
	SKSpriteNode *ballSprite = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@", textureName]];
	ballSprite.size = CGSizeMake(75, 75);
	ballSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ballSprite.size.width/2];
	ballSprite.physicsBody.dynamic = YES;
	ballSprite.physicsBody.categoryBitMask = ballCategory;
	ballSprite.physicsBody.friction = 0;
	ballSprite.physicsBody.linearDamping = 0;
	ballSprite.physicsBody.angularDamping = 0;
	ballSprite.physicsBody.restitution = 1;
	ballSprite.physicsBody.collisionBitMask = lineCategory | edgeCategory;
	ballSprite.physicsBody.contactTestBitMask = lineCategory | edgeCategory;
	return ballSprite;
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
	// Handle contacts between two physics bodies.
	
	SKPhysicsBody *firstBody;
	SKPhysicsBody *secondBody;
	
	if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask)
	{
		firstBody = contact.bodyA;
		secondBody = contact.bodyB;
	}
	else
	{
		firstBody = contact.bodyB;
		secondBody = contact.bodyA;
	}
	
	
	if ((firstBody.categoryBitMask & lineCategory) != 0)
	{
		// Ball hits line
		[self removeLine];
		scoreNumber = scoreNumber + 1;
	}
	else {
		// Ball hits wall
		[ball.physicsBody setVelocity:CGVectorMake(0, 0)];
		[self gameOver];
	}
}

-(void)gameOver {
	[self removeLine];
	gameOver = YES;
	
	// Create game over UI
	[self.view addSubview:screenCrack];
	[self playSound];
	
	
	hits = [[UILabel alloc] init];
	[hits setText:[NSString stringWithFormat:@"%i/%0.1f = %0.3f", scoreNumber, gameTime, (scoreNumber / gameTime)]];
	hits.frame = CGRectMake(80.0, 310.0, 160.0, 40.0);
	hits.textAlignment = NSTextAlignmentCenter;
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[hits setBackgroundColor:[UIColor whiteColor]];
		[hits setTextColor:[UIColor blackColor]];
	}
	else {
		[hits setBackgroundColor:[UIColor blackColor]];
		[hits setTextColor:[UIColor whiteColor]];
	}
	[self.view addSubview:hits];
	
	menu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[menu addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
	[menu setTitle:@"Go back" forState:UIControlStateNormal];
	menu.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[menu setBackgroundColor:[UIColor whiteColor]];
		[menu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		[menu setBackgroundColor:[UIColor blackColor]];
	}
	[self.view addSubview:menu];
	
	replay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[replay addTarget:self action:@selector(restartButton:) forControlEvents:UIControlEventTouchUpInside];
	[replay setTitle:@"Restart game" forState:UIControlStateNormal];
	replay.frame = CGRectMake(80.0, 110.0, 160.0, 40.0);
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[replay setBackgroundColor:[UIColor whiteColor]];
		[replay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		[replay setBackgroundColor:[UIColor blackColor]];
	}
	
	[self.view addSubview:replay];
}

-(void)menuButton:(UIButton *)button {
	
	gameOver = NO;
	gameStarted = NO;
	gameTime = 0;
	
	[self removeElements];
	
	[self.view presentScene:nil];

	[self.delegate showDifferentView];
	
}

-(void)restartButton:(UIButton *)button {
	
	gameOver = NO;
	gameStarted = NO;
	gameTime = 0;
	
	[self removeElements];
	
	[self.view presentScene:nil];
	
	[self.delegate showScene];
}

-(void)removeElements {
	// Removes elements not in the scene
	[replay removeFromSuperview];
	[menu removeFromSuperview];
	[screenCrack removeFromSuperview];
	[score removeFromSuperview];
	[hits removeFromSuperview];
}

// Ball speed up method
- (void) speedUp:(NSTimer *)timer
{
	if (!gameOver) {
		[ball.physicsBody applyImpulse:CGVectorMake(2, 2)];
	}
}

// Start ball on user touch
// Done to avoid extremely low FPS at load of scene
-(void)start:(UIButton *)button {
	
	gameTime = 0;
	
	gameStarted = YES;
	// Remove button from parent
	[start removeFromSuperview];
	
	[ball.physicsBody applyImpulse:CGVectorMake(x, y)];
	//Calls ball speed up method
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(speedUp:) userInfo:nil repeats:YES];
	// Start Timer
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self
								   selector:@selector(timer:)
								   userInfo:nil
									repeats:YES];
}

-(void)playSound {
	
	// Create the sound ID
	NSString* path = [[NSBundle mainBundle]
					  pathForResource:@"break" ofType:@"mp3"];
	NSURL* url = [NSURL fileURLWithPath:path];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &breaking);
 
	// Play the sound
	AudioServicesPlaySystemSound(breaking);
}

-(void)removeLine {
	[line runAction:remove];
	[lines runAction:remove];
	dotDrawn = NO;
}

-(void)timer:(NSTimer *)timer {
	
	if (!gameOver) {
		
		gameTime = gameTime + 0.1;
		
		score.text = [NSString stringWithFormat:@"%.01f", gameTime];
		
	}
	
}




@end
