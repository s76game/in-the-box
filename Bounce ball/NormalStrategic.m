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
	
	// Set starting goal size
	goalSize = 50;
	
	// Set up score
	score = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth/2)-25, 25, 100, 50)];
	[self.view addSubview:score];
	scoreNumber = 0;
	score.text = @"Goals Hit";
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
	
	[self spawnGoal];
	
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
	
	
	if (!gameOver && gameStarted) {
		
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
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (!gameOver && gameStarted) {
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"linesDrawn"]+1 forKey:@"linesDrawn"];

	
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
	ballSprite.physicsBody.collisionBitMask = lineCategory | goalCategory | edgeCategory | pointGoalCategory;
	ballSprite.physicsBody.contactTestBitMask = lineCategory | goalCategory | edgeCategory | pointGoalCategory;
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
	}
	else if ((firstBody.categoryBitMask & edgeCategory) != 0)
	{
		// Ball hits wall
		[ball.physicsBody setVelocity:CGVectorMake(0, 0)];
		[self gameOver];
	}
	else if ((firstBody.categoryBitMask & goalCategory) != 0)
	{
		// Ball hits goal
		[goal removeFromParent];
		[detect removeFromParent];
		[self spawnGoal];
		goalsHit = goalsHit + 1;
		score.text = [NSString stringWithFormat:@"%i", goalsHit];
		if (!goalSize <= 10) {
			goalSize = goalSize - 2;
		}
		else {
			NSLog(@"Ball would be too small");
		}
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"goalsHit"]+1 forKey:@"goalsHit"];
	}
	else {
		// Should never get here
		NSLog(@"Alpha");
		
	}
}

-(void)gameOver {
	
	// Runs game center code block
	[self gameCenter];
	
	[self removeLine];
	gameOver = YES;
	
	// Create game over UI
	[self.view addSubview:screenCrack];
	[self playSound];
	
	
	hits = [[UILabel alloc] init];
	totalScore = goalsHit;
	[hits setText:[NSString stringWithFormat:@"Score: %i goals", (int)totalScore]];
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
	goalsHit = 0;
	
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
	
	[timer invalidate];
	[speedUpTimer invalidate];
	
	[self.delegate showScene];
}

-(void)removeElements {
	// Removes elements not in the scene
	[replay removeFromSuperview];
	[menu removeFromSuperview];
	[screenCrack removeFromSuperview];
	[score removeFromSuperview];
	[hits removeFromSuperview];
	[goal removeFromParent];
	[detect removeFromParent];
}

// Ball speed up method
- (void) speedUp:(NSTimer *)timer
{
	int xImpluse;
	int yImpluse;
	
	if (ball.physicsBody.velocity.dx > 0) {
		xImpluse = 2;
	}
	else {
		xImpluse = -2;
	}
	
	if (ball.physicsBody.velocity.dy > 0) {
		yImpluse = 2;
	}
	else {
		yImpluse = -2;
	}
	
	if (!gameOver) {
		[ball.physicsBody applyImpulse:CGVectorMake(xImpluse, yImpluse)];
	}
}

// Start ball on user touch
// Done to avoid extremely low FPS at load of scene
-(void)start:(UIButton *)button {
	
	goalsHit = 0;
	
	gameStarted = YES;
	// Remove button from parent
	[start removeFromSuperview];
	
	[ball.physicsBody applyImpulse:CGVectorMake(x, y)];
	//Calls ball speed up method
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(speedUp:) userInfo:nil repeats:YES];
	// Start Timer
	[NSTimer scheduledTimerWithTimeInterval:1.0
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
		
		int minutesTimer;
		int secondsTimer;
		
		minutesTimer = gameTime/60;
		secondsTimer = gameTime-(minutesTimer * 60);
		
		gameTime = gameTime + 1;

		goalTimeString = [NSString stringWithFormat:@"%01d:%02d", minutesTimer, secondsTimer];
	}
	
}

-(void)spawnGoal {
//	goal = [SKSpriteNode spriteNodeWithImageNamed:@"goal.png"];
//	goal.size = CGSizeMake(150, 75);
//	goal.position = [self chooseLocation];
//	goal.zRotation = M_PI*2*(arc4random() / (float)UINT32_MAX);
//	goal.color = [UIColor brownColor];
//	[self addChild:goal];
//	goal.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"goal.png"] alphaThreshold:0.5 size:CGSizeMake(150, 75)];
//	goal.physicsBody.dynamic = NO;
//	goal.physicsBody.categoryBitMask = goalCategory;
//	goal.physicsBody.collisionBitMask = ballCategory;
//	goal.physicsBody.contactTestBitMask = goalCategory;
//	
//	detect = [SKSpriteNode node];
//	detect.zRotation = goal.zRotation;
//	[self addChild:detect];
//	detect.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:goal.position	toPoint:goal.position];
//	detect.physicsBody.dynamic = NO;
//	detect.physicsBody.categoryBitMask = pointGoalCategory;
//	detect.physicsBody.collisionBitMask = ballCategory;
//	detect.physicsBody.contactTestBitMask = pointGoalCategory;
//	
//	CGPoint anchor = CGPointMake(100, 100);
//	SKPhysicsJointFixed* fixedJoint = [SKPhysicsJointFixed jointWithBodyA:goal.physicsBody
//																	bodyB:detect.physicsBody
//																   anchor:anchor];
//	[self.scene.physicsWorld addJoint:fixedJoint];
	
	goal = [SKSpriteNode spriteNodeWithImageNamed:@"goalCircle.png"];
	goal.size = CGSizeMake(goalSize, goalSize);
	goal.position = [self chooseLocation];
	[self addChild:goal];
	
	float goalSizes = (float)goalSize / 2.0;
	
	goal.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:goalSizes];
	goal.physicsBody.dynamic = NO;
	goal.physicsBody.categoryBitMask = goalCategory;
	goal.physicsBody.collisionBitMask = ballCategory;
	goal.physicsBody.contactTestBitMask = goalCategory;
	
	
	
	
	
}

-(CGPoint)chooseLocation {
	
	kMinDistanceFromBall = 50;
	
	CGFloat goalWidth = goal.size.width;
	CGFloat goalHeight = goal.size.height;
	
	CGFloat maxX = screenWidth - goalWidth;
	CGFloat maxY = screenHeight - goalHeight;
	
	CGFloat dx = MAX(maxX-kMinDistanceFromBall-ball.position.x, 0) + MAX(ball.position.x-kMinDistanceFromBall, 0);
	CGFloat dy = MAX(maxY-kMinDistanceFromBall-ball.position.y, 0) + MAX(ball.position.y-kMinDistanceFromBall, 0);
	
	CGFloat newX = ball.position.x + MIN(maxX-ball.position.x, kMinDistanceFromBall) + skRand(0, dx);
	CGFloat newY = ball.position.y + MIN(maxY-ball.position.y, kMinDistanceFromBall) + skRand(0, dy);
	
	if (newX > maxX) {
		newX -= maxX;
	}
	
	if (newY > maxY) {
		newY -= maxY;
	}
	
	return CGPointMake(newX+goalWidth/2, newY+goalHeight/2);
}

#pragma mark Game Center Code


// Checks all game center stuff
-(void)gameCenter {
	// Achievement: Afraid of the dark
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"] && totalScore == 0) {
		[self achievementComplete:@"afraid_dark" percentComplete:100];
	}
	
	// Achievement: Nocturnal
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		
		float nocturnal = gameTime * 4;
		
		if (nocturnal > 100) {
			nocturnal = 100;
		}
		
		[self achievementComplete:@"nocturnal" percentComplete:nocturnal];
	}
	
	// Achievement: Artist
	[self achievementComplete:@"artist" percentComplete:[[NSUserDefaults standardUserDefaults] integerForKey:@"linesDrawn"] * .1];
	
	// Achievement: Balling
	[self achievementComplete:@"balling" percentComplete:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]];
	
	// Achievement: Goal
	[self achievementComplete:@"goal" percentComplete:[[NSUserDefaults standardUserDefaults] integerForKey:@"goalsHit"] * .1];

	
	// Achievement: Survivor
	float survivor = gameTime / 60;
	
	if (survivor >= 2) {
		[self achievementComplete:@"survivor" percentComplete:100];
	}
	else {
		[self achievementComplete:@"survivor" percentComplete:survivor * 60];
	}
	
	
	
}

- (void)achievementComplete:(NSString *)achievementID percentComplete: (int)percent {
	GKAchievement *achievement1 = [[GKAchievement alloc] initWithIdentifier: [NSString stringWithFormat:@"%@", achievementID]];
	achievement1.percentComplete = percent;
	achievement1.showsCompletionBanner = YES;
	NSArray *achievementsToComplete = [NSArray arrayWithObjects:achievement1, nil];
	NSLog(@"Attempt to report %@", achievement1.identifier);
	[GKAchievement reportAchievements: achievementsToComplete withCompletionHandler:^(NSError *error)
	 {
		 if (error != nil)
		 {
			 NSLog(@"Error in reporting achievements: %@", error);
		 }
	 }];
}


@end
