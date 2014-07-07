//
//  NightScene.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/28/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "NightScene.h"

@interface NightScene ()
@property BOOL contentCreated;
@property (nonatomic, copy) void (^gameOverBlock)(BOOL didWin);

@end

@implementation NightScene

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
	
	// Create game start button
	go = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[go addTarget:self action:@selector(gameStart:) forControlEvents:UIControlEventTouchUpInside];
	[go setBackgroundImage:[UIImage imageNamed:@"normalgo.png"] forState:UIControlStateNormal];
	go.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
	[go setBackgroundColor:[UIColor whiteColor]];
	[go setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
	[self.view addSubview:go];
	
	
	// Set up score label
	score = [[UILabel alloc] initWithFrame:CGRectMake(((screenHeight/2)+150), 25, 300, 100)];
	[self.view addSubview:score];
	scoreNumber = 0;
	score.text = @"Time";
	[score setTextAlignment:NSTextAlignmentLeft];
	score.textColor = [UIColor whiteColor];
	[score setFont:[UIFont systemFontOfSize:25]];
	
	
	
	// Set up background texture
	SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"nightbackground2.png"];
	SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:self.view.frame.size];
	background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
	[self addChild:background];
	
	// Set up scene
	
	self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
	self.physicsBody.categoryBitMask = edgeCategory;
	self.physicsBody.contactTestBitMask = edgeCategory;
	self.physicsWorld.contactDelegate = self;
	self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
	
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
			x = 10.0f;
			break;
  case 2:
			x = -10.0f;
			break;
  default:
			break;
	}
	switch (y) {
  case 1:
			y = 10.0f;
			break;
  case 2:
			y = -10.0f;
			break;
  default:
			break;
	}
	
	// Alloc cracked view image
	screenCrack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glassoverlay.png"]];
	screenCrack.frame = self.frame;
	
	// Add light to scene
	light =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light.png"]];
	light.frame = CGRectMake(0, 0, self.frame.size.width, 100);
	[self.view addSubview:light];
	NSLog(@"Added light");
	
}

-(void)gameStart:(UIButton *)button{
	[ball.physicsBody applyImpulse:CGVectorMake(x, y)];
	NSLog(@"Game Started");
	NSLog(@"%@", NSStringFromCGPoint(ball.position));
	// Remove button
	[go removeFromSuperview];
	// Calls animation for light
	[self lightAnimation];
	//Calls ball speed up method
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(speedUp:) userInfo:nil repeats:YES];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (!gameOver) {
		if (!dotDrawn) {
			
			dotDrawn = YES;
		
			[self removeLine];
		
			UITouch* touch = [touches anyObject];
			CGPoint positionInScene = [touch locationInNode:self];
		
			pos1x = positionInScene.x;
			pos1y = positionInScene.y;
		
			pos2x = positionInScene.x;
			pos2y = positionInScene.y;
		
			line = [[SKSpriteNode alloc] init];
			line.color = [UIColor whiteColor];
			[line setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"normalball.png"]]];
			line.size = CGSizeMake(20, 20);
			line.position = CGPointMake(pos2x, pos2y);
			[self addChild:line];
			line.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
			line.physicsBody.dynamic = NO;
			line.physicsBody.categoryBitMask = lineCategory;
			line.physicsBody.collisionBitMask = ballCategory;
			line.physicsBody.contactTestBitMask = lineCategory;
		}
	}
}


- (SKSpriteNode *)newBall
{
	// Generates new ball
	SKSpriteNode *ballSprite = [SKSpriteNode spriteNodeWithImageNamed:@"nightball2.png"];
	ballSprite.size = CGSizeMake(50, 50);
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
		score.text = [NSString stringWithFormat:@"%i",scoreNumber];
	}
	else {
		// Ball hits wall
		[ball.physicsBody setVelocity:CGVectorMake(0, 0)];
		[self gameOver];
	}
}

-(void)gameOver {
	[self removeLine];
	NSLog(@"Game Over");
	gameOver = YES;
	
	// Create game over UI
	[self.view addSubview:screenCrack];
	[self playSound];
	
	menu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[menu addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
	[menu setTitle:@"Go to menu" forState:UIControlStateNormal];
	menu.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
	[menu setBackgroundColor:[UIColor whiteColor]];
	[menu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
	[self.view addSubview:menu];
	
	replay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[replay addTarget:self action:@selector(restartButton:) forControlEvents:UIControlEventTouchUpInside];
	[replay setTitle:@"Restart game" forState:UIControlStateNormal];
	replay.frame = CGRectMake(80.0, 110.0, 160.0, 40.0);
	[replay setBackgroundColor:[UIColor whiteColor]];
	[replay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
	[self.view addSubview:replay];
}

-(void)menuButton:(UIButton *)button {
	
	NSLog(@"%i", scoreNumber);
	
}

-(void)restartButton:(UIButton *)button {
	
	NSLog(@"%i", scoreNumber);
	
	// Removes elements not in the scene
	[replay removeFromSuperview];
	[menu removeFromSuperview];
	[screenCrack removeFromSuperview];
	[score removeFromSuperview];
	gameOver = NO;
	
	// Restarts the scene
	SKScene *nextScene = [[NightScene alloc] initWithSize:self.size];
	SKTransition *doors = [SKTransition doorsOpenHorizontalWithDuration:0.5];
	[self.view presentScene:nextScene transition:doors];
}

// Ball speed up method
- (void) speedUp:(NSTimer *)timer
{
	if (!gameOver) {
		[ball.physicsBody applyImpulse:CGVectorMake(2, 2)];
		NSLog(@"Speed increased");
	}
}



-(void)lightAnimation {
	[UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
		light.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.2 delay:0.5 options:0 animations:^{
			light.alpha = 1.0f;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.2 delay:0.5 options:0 animations:^{
				light.alpha = 0.0f;
			} completion:^(BOOL finished) {
				NSLog(@"Light animation completed");
			}];
		}];
	}];
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
	dotDrawn = NO;
}


@end
