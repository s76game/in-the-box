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

@property (weak, nonatomic) id <sceneDelegate, resetSKScene, shareGoalDelegate> delegate;

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
	
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
	if (IPAD) {
		scoreiPad = 50;
		startiPad = 2;
		speediPad = 115;
	} else {
		scoreiPad = 25;
		startiPad = 1;
		speediPad = 15;
	}
	
	// Set starting goal size
	goalSize = 50*startiPad;
	
	// Set up score
	score = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth/2)-150, scoreiPad, 300, 50)];
	[self.view addSubview:score];
	scoreNumber = 0;
	score.textAlignment = NSTextAlignmentCenter;
	score.text = @"Goals";
	[score setFont:[UIFont fontWithName:@"Prototype" size:scoreiPad]];
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
	start.frame = CGRectMake(((screenWidth/2)-65*startiPad), 150*startiPad, 130*startiPad, 40*startiPad);
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
			x = speediPad;
			break;
  case 2:
			x = -speediPad;
			break;
  default:
			break;
	}
	switch (y) {
  case 1:
			y = speediPad;
			break;
  case 2:
			y = -speediPad;
			break;
  default:
			break;
	}
	
	
	
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (!gameOver && gameStarted) {
		
		[line removeFromParent];
		[lines removeFromParent];
		
		touchStarted = YES;
		
		dotDrawn = YES;
		
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
		
		pos1x = positionInScene.x;
		pos1y = positionInScene.y;
	}
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (!gameOver && gameStarted && touchStarted) {
		
		[lines removeFromParent];
		
		dotDrawn = NO;
		
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
		
		pos2x = positionInScene.x;
		pos2y = positionInScene.y;
		
		lines = [SKShapeNode node];
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, pos1x, pos1y);
		CGPathAddLineToPoint(path, NULL, pos2x, pos2y);
		
		lines.path = path;
		CGPathRelease(path);
		lines.strokeColor = [UIColor grayColor];
		[lines setLineWidth:3];
		
		[self addChild:lines];
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (!gameOver && gameStarted && touchStarted) {
		
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"linesDrawn"]+1 forKey:@"linesDrawn"];
		
		[lines removeFromParent];
		
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
		
		pos2x = positionInScene.x;
		pos2y = positionInScene.y;
		
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
		if (night) {
			[lines setStrokeColor:[UIColor whiteColor]];
		}
		else {
			[lines setStrokeColor:[UIColor blackColor]];
		}
		[lines setLineWidth:3];
		
		[self addChild:lines];
		
		pos1x = 0;
		pos2x = 0;
		pos1y =	0;
		pos2y = 0;
		
		touchStarted = NO;
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
	ballSprite.size = CGSizeMake(75*startiPad, 75*startiPad);
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
		NSLog(@"Collision Issue");
	}
}

#pragma mark Game Over Code

-(void)gameOver {
	
	// Runs game center code block
	[self gameCenter];
	
	gameOver = YES;
	
	[self gameOverAnimation];
	
}

-(void)gameOverAnimation {
	
	int highScore;
	
#pragma mark Create Post Game UI
	
	screenCrack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glassoverlay.png"]];
	screenCrack.frame = self.frame;
	[self.view addSubview:screenCrack];
	[self playSound];
	
	postBackground = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
	postBackground.backgroundColor = [UIColor blackColor];
	postBackground.alpha = 0.75;
	[self.view addSubview:postBackground];
	
	currentScore = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight+170, 135, 75)];
	currentScore.text = @"GOALS:";
	currentScore.textAlignment = NSTextAlignmentRight;
	[currentScore setFont:[UIFont fontWithName:@"Prototype" size:40]];
	currentScore.textColor = [UIColor whiteColor];
	[self.view addSubview:currentScore];
	
	bestScore = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight+245, 135, 75)];
	bestScore.text = @"BEST:";
	bestScore.textAlignment = NSTextAlignmentRight;
	[bestScore setFont:[UIFont fontWithName:@"Prototype" size:40]];
	bestScore.textColor = [UIColor whiteColor];
	[self.view addSubview:bestScore];
	
	highScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreGoals"];
	
	currentScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(currentScore.frame.origin.x+currentScore.frame.size.width+10, currentScore.frame.origin.y, 100, 75)];
	currentScoreNumber.text = [NSString stringWithFormat:@"0"];
	[currentScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:40]];
	currentScoreNumber.textColor = [UIColor blueColor];
	[self.view addSubview:currentScoreNumber];
	
	bestScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+10, bestScore.frame.origin.y, 100, 75)];
	bestScoreNumber.text = [NSString stringWithFormat:@"%i", highScore];
	[bestScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:40]];
	bestScoreNumber.textColor = [UIColor greenColor];
	[self.view addSubview:bestScoreNumber];
	
	if (goalsHit >= highScore) {
		[[NSUserDefaults standardUserDefaults] setInteger:goalsHit forKey:@"highScoreGoals"];
		currentScoreNumber.textColor = [UIColor greenColor];
		bestScoreNumber.text = [NSString stringWithFormat:@"%i", goalsHit];
	}
	
	currentMedal = [[UIImageView alloc] initWithFrame:CGRectMake(currentScoreNumber.frame.origin.x+currentScoreNumber.frame.size.width-10, currentScoreNumber.frame.origin.y+10, 50, 50)];
	if (goalsHit >= 30) {
		currentMedal.image = [UIImage imageNamed:@"goldmedal.png"];
	}
	else if (goalsHit >= 20) {
		currentMedal.image = [UIImage imageNamed:@"silvermedal.png"];
	}
	else if (goalsHit >= 10 ) {
		currentMedal.image = [UIImage imageNamed:@"bronzemedal.png"];
	}
	else {
		currentMedal.image = nil;
	}
	[self.view addSubview:currentMedal];
	currentMedal.hidden = YES;
	
	
	bestMedal = [[UIImageView alloc] initWithFrame:CGRectMake(bestScoreNumber.frame.origin.x+bestScoreNumber.frame.size.width-10, bestScoreNumber.frame.origin.y+10, 50, 50)];
	if (highScore >= 30) {
		bestMedal.image = [UIImage imageNamed:@"goldmedal.png"];
	}
	else if (highScore >= 20) {
		bestMedal.image = [UIImage imageNamed:@"silvermedal.png"];
	}
	else if (highScore >= 10) {
		bestMedal.image = [UIImage imageNamed:@"bronzemedal.png"];
	}
	else {
		bestMedal.image = nil;
	}
	[self.view addSubview:bestMedal];
	
	title = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth/2)-150, screenHeight+50, 300, 75)];
	title.text = @"RESULTS:";
	title.textAlignment = NSTextAlignmentCenter;
	[title setFont:[UIFont fontWithName:@"Prototype" size:50]];
	title.textColor = [UIColor whiteColor];
	[self.view addSubview:title];

	replay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[replay addTarget:self action:@selector(restartButton:) forControlEvents:UIControlEventTouchUpInside];
	[replay setBackgroundImage:[UIImage imageNamed:@"postplaybutton.png"] forState:UIControlStateNormal];
	replay.frame = CGRectMake(80.0, screenHeight+375.0, 160.0, 50.0);
	[self.view addSubview:replay];
	
	menu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[menu addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
	[menu setBackgroundImage:[UIImage imageNamed:@"postmenubutton.png"] forState:UIControlStateNormal];
	menu.frame = CGRectMake(80.0, replay.frame.origin.y+replay.frame.size.height+15, 160.0, 50.0);
	[self.view addSubview:menu];
	
	gameCenter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[gameCenter addTarget:self action:@selector(gameCenterButton:) forControlEvents:UIControlEventTouchUpInside];
	[gameCenter setBackgroundImage:[UIImage imageNamed:@"gcicon.png"] forState:UIControlStateNormal];
	gameCenter.frame = CGRectMake(80+55, menu.frame.origin.y+menu.frame.size.height+15, 50, 50);
	[self.view addSubview:gameCenter];
	
	if (IPAD) {
		[self adjustInterface];
	}
	
	// Begin Animation
	
	[UIView animateWithDuration:1.0
						  delay:0.0
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^
	 {
		 postBackground.frame = CGRectMake(0, 0, screenWidth, screenHeight);
		 replay.frame = CGRectMake(replay.frame.origin.x, replay.frame.origin.y-screenHeight, replay.frame.size.width, replay.frame.size.height);
		 menu.frame = CGRectMake(menu.frame.origin.x, menu.frame.origin.y-screenHeight, menu.frame.size.width, menu.frame.size.height);
		 title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y-screenHeight, title.frame.size.width, title.frame.size.height);
		 bestScore.frame = CGRectMake(bestScore.frame.origin.x, bestScore.frame.origin.y-screenHeight, bestScore.frame.size.width, bestScore.frame.size.height);
		 currentScore.frame = CGRectMake(currentScore.frame.origin.x, currentScore.frame.origin.y-screenHeight, currentScore.frame.size.width, currentScore.frame.size.height);
		 bestScoreNumber.frame = CGRectMake(bestScoreNumber.frame.origin.x, bestScoreNumber.frame.origin.y-screenHeight, bestScoreNumber.frame.size.width, bestScoreNumber.frame.size.height);
		 currentScoreNumber.frame = CGRectMake(currentScoreNumber.frame.origin.x, currentScoreNumber.frame.origin.y-screenHeight, currentScoreNumber.frame.size.width, currentScoreNumber.frame.size.height);
		 gameCenter.frame = CGRectMake(gameCenter.frame.origin.x, gameCenter.frame.origin.y-screenHeight, gameCenter.frame.size.width, gameCenter.frame.size.height);
		 currentMedal.frame = CGRectMake(currentMedal.frame.origin.x, currentMedal.frame.origin.y-screenHeight, currentMedal.frame.size.width, currentMedal.frame.size.height);
		 bestMedal.frame = CGRectMake(bestMedal.frame.origin.x, bestMedal.frame.origin.y-screenHeight, bestMedal.frame.size.width, bestMedal.frame.size.height);
		 	 }
					 completion:^(BOOL finished)
	 {
			// Count up animation sqequence
		 
			float countUpTimer = 1.5 / (goalsHit - 1);
		 
			countingTimer = [NSTimer scheduledTimerWithTimeInterval:countUpTimer target:self selector:@selector(countAnimation) userInfo:nil repeats:YES];
	 }];
	
	
	
}

-(void)adjustInterface {
	
	currentScore.frame = CGRectMake(20, screenHeight+340, 270, 150);
	[currentScore setFont:[UIFont fontWithName:@"Prototype" size:80]];
	bestScore.frame = CGRectMake(20, screenHeight+450, 270, 150);
	[bestScore setFont:[UIFont fontWithName:@"Prototype" size:80]];
	currentScoreNumber.frame = CGRectMake(currentScore.frame.origin.x+currentScore.frame.size.width+20, currentScore.frame.origin.y, 200, 150);
	[currentScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:80]];
	bestScoreNumber.frame = CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+20, bestScore.frame.origin.y, 200, 150);
	[bestScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:80]];
	currentMedal.frame = CGRectMake(currentScoreNumber.frame.origin.x+currentScoreNumber.frame.size.width+20, currentScoreNumber.frame.origin.y+20, 100, 100);
	bestMedal.frame = CGRectMake(bestScoreNumber.frame.origin.x+bestScoreNumber.frame.size.width+20, bestScoreNumber.frame.origin.y+20, 100, 100);
	title.frame = CGRectMake((screenWidth/2)-300, screenHeight+50, 600, 150);
	[title setFont:[UIFont fontWithName:@"Prototype" size:100]];
	replay.frame = CGRectMake((screenWidth/2)-160, screenHeight+650, 320, 100);
	menu.frame = CGRectMake((screenWidth/2)-160, replay.frame.origin.y+replay.frame.size.height+30, 320, 100);
	gameCenter.frame = CGRectMake(menu.frame.origin.x+30, menu.frame.origin.y+menu.frame.size.height+30, 100, 100);
	
}

-(void)countAnimation {
	countingAnimation = countingAnimation +1;
	
	if(countingAnimation <= goalsHit) {
		
		currentScoreNumber.text = [NSString stringWithFormat:@"%i", countingAnimation];
	}
	else {
		countingAnimation = 0;
		[countingTimer invalidate];
		currentMedal.hidden = NO;
	}
}

-(void)shareButton:(UIButton *)button {
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"shareGoal" object:self];
}

-(void)gameCenterButton:(UIButton *)button {
	
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Game Center not enabled!"
														  message:@"Please login for Game Center use"
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		[message show];
	} else {
		GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
		if (gameCenterController != nil)
		{
			gameCenterController.gameCenterDelegate = self;
			gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
			UIViewController *vc = self.view.window.rootViewController;
			[vc presentViewController: gameCenterController animated: YES completion:nil];
		}
	}
	
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
	
	UIViewController *vc = self.view.window.rootViewController;
	[vc dismissViewControllerAnimated:YES completion:nil];
}

-(void)menuButton:(UIButton *)button {
	
	gameOver = NO;
	gameStarted = NO;
	goalsHit = 0;
	
	[self removeElements];
	
	[self.view presentScene:nil];

	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"GameOverNotification" object:self];
	
}

-(void)restartButton:(UIButton *)button {
	
	gameOver = NO;
	gameStarted = NO;
	gameTime = 0;
	
	[self removeElements];
	
	[self.view presentScene:nil];
	
	[timer invalidate];
	[speedUpTimer invalidate];
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"showScene" object:self];
}

-(void)removeElements {
	// Removes elements not in the scene
	[replay removeFromSuperview];
	[menu removeFromSuperview];
	[screenCrack removeFromSuperview];
	[score removeFromSuperview];
	[goal removeFromParent];
	[detect removeFromParent];
	[title removeFromSuperview];
	[currentScoreNumber removeFromSuperview];
	[currentScore removeFromSuperview];
	[bestScoreNumber removeFromSuperview];
	[bestScore removeFromSuperview];
	[gameCenter removeFromSuperview];
	[postBackground removeFromSuperview];
	[currentMedal removeFromSuperview];
	[bestMedal removeFromSuperview];
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
	
	score.text = @"0";
	
	gameStarted = YES;
	// Remove button from parent
	[start removeFromSuperview];
	
	[ball.physicsBody applyImpulse:CGVectorMake(x, y)];
	//Calls ball speed up method
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(speedUp:) userInfo:nil repeats:YES];
}

-(void)playSound {
	
	SystemSoundID soundID;
	NSString *soundFile = [[NSBundle mainBundle]
						   pathForResource:@"break" ofType:@"mp3"];
	AudioServicesCreateSystemSoundID((__bridge  CFURLRef)
									 [NSURL fileURLWithPath:soundFile], & soundID);
	AudioServicesPlaySystemSound(soundID);
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


#pragma mark Game Center Achievement Code


// Checks all game center stuff
-(void)gameCenter {
	
#pragma mark Leaderboard
	GKScore *scores = [[GKScore alloc] initWithLeaderboardIdentifier:@"score"];
	scores.value = goalsHit;
	
	NSLog(@"Attempt to report %@ of %lli", scores.leaderboardIdentifier, scores.value);
	[GKScore reportScores:@[scores] withCompletionHandler:^(NSError *error) {
		if (error != nil) {
			NSLog(@"%@", [error localizedDescription]);
		}
	}];
	
#pragma mark Achievements

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
