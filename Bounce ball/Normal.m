//
//  Normal.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/12/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Normal.h"

@interface Normal ()
@property BOOL contentCreated;

@property (weak, nonatomic) id <sceneDelegate, resetSKScene, shareTimeDelegate> delegate;


@end


@implementation Normal

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
	
	[speedUpTimer invalidate];
	[timer invalidate];
	
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

#pragma mark Game Over Code

-(void)gameOver {
	
	// Runs game center code block
	[self gameCenter];
	
	[self removeLine];
	gameOver = YES;
	
	[self gameOverAnimation];
	
}

-(void)gameOverAnimation {
	
	float highScore;
	
	screenCrack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glassoverlay.png"]];
	screenCrack.frame = self.frame;
	[self.view addSubview:screenCrack];
	[self playSound];
	
	postBackground = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
	postBackground.backgroundColor = [UIColor blackColor];
	postBackground.alpha = 0.75;
	[self.view addSubview:postBackground];
	
	currentScore = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight+170, 150, 75)];
	currentScore.text = @"TIME:";
	currentScore.textAlignment = NSTextAlignmentRight;
	[currentScore setFont:[UIFont fontWithName:@"Prototype" size:40]];
	currentScore.textColor = [UIColor whiteColor];
	[self.view addSubview:currentScore];
	
	bestScore = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight+245, 150, 75)];
	bestScore.text = @"BEST:";
	bestScore.textAlignment = NSTextAlignmentRight;
	[bestScore setFont:[UIFont fontWithName:@"Prototype" size:40]];
	bestScore.textColor = [UIColor whiteColor];
	[self.view addSubview:bestScore];
	
	highScore = [[NSUserDefaults standardUserDefaults] floatForKey:@"highScoreTime"];
	
	currentScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(currentScore.frame.origin.x+currentScore.frame.size.width+10, currentScore.frame.origin.y, 150, 75)];
	currentScoreNumber.text = [NSString stringWithFormat:@"%@", score.text];
	[currentScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:40]];
	currentScoreNumber.textColor = [UIColor blueColor];
	[self.view addSubview:currentScoreNumber];
	
	bestScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+10, bestScore.frame.origin.y, 150, 75)];
	
		// Parse High Score Data
		int minutesTimerHigh;
		int secondsTimerHigh;
	
		minutesTimerHigh = (int)highScore/60;
		secondsTimerHigh = (int)highScore-(minutesTimerHigh * 60);
	
	bestScoreNumber.text = [NSString stringWithFormat:@"%01d:%02d", minutesTimerHigh, secondsTimerHigh];
	[bestScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:40]];
	bestScoreNumber.textColor = [UIColor greenColor];
	[self.view addSubview:bestScoreNumber];

	
	if (gameTime >= highScore) {
		[[NSUserDefaults standardUserDefaults] setFloat:gameTime forKey:@"highScoreTime"];
		currentScoreNumber.textColor = [UIColor greenColor];
		// Minutes:Seconds
		bestScoreNumber.text = [NSString stringWithFormat:@"%01d:%02d", minutesTimer, secondsTimer];
	}
	
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
	
	share = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[share addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
	[share setBackgroundImage:[UIImage imageNamed:@"shareicon.png"] forState:UIControlStateNormal];
	share.frame = CGRectMake(menu.frame.origin.x+menu.frame.size.width-50-15, menu.frame.origin.y+menu.frame.size.height+15, 50, 50);
	[self.view addSubview:share];
	
	gameCenter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[gameCenter addTarget:self action:@selector(gameCenterButton:) forControlEvents:UIControlEventTouchUpInside];
	[gameCenter setBackgroundImage:[UIImage imageNamed:@"gcicon.png"] forState:UIControlStateNormal];
	gameCenter.frame = CGRectMake(80+15, menu.frame.origin.y+menu.frame.size.height+15, 50, 50);
	[self.view addSubview:gameCenter];
	
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
		 share.frame = CGRectMake(share.frame.origin.x, share.frame.origin.y-screenHeight, share.frame.size.width, share.frame.size.height);
	 }
					 completion:^(BOOL finished)
	 {
			// Completion Code
	 }];
	
	
	
}

-(void)shareButton:(UIButton *)button {
	[self.delegate showShareTime];
}

-(void)gameCenterButton:(UIButton *)button {
	
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"You must enable Game Center!"
														  message:@"Sign in through the Game Center app to enable all features"
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
	[title removeFromSuperview];
	[currentScoreNumber removeFromSuperview];
	[currentScore removeFromSuperview];
	[bestScoreNumber removeFromSuperview];
	[bestScore removeFromSuperview];
	[gameCenter removeFromSuperview];
	[share removeFromSuperview];
	[postBackground removeFromSuperview];
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
	
	gameTime = 0;
	
	gameStarted = YES;
	// Remove button from parent
	[start removeFromSuperview];
	
	[ball.physicsBody applyImpulse:CGVectorMake(x, y)];
	//Calls ball speed up method
	score.text = @"0:00";
	speedUpTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(speedUp:) userInfo:nil repeats:YES];
	// Start Timer
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0
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

	minutesTimer = gameTime/60;
	secondsTimer = gameTime-(minutesTimer * 60);
		
	gameTime = gameTime + 1;
	// Minutes:Seconds
	score.text = [NSString stringWithFormat:@"%01d:%02d", minutesTimer, secondsTimer];
	}
	
}


#pragma mark Game Center Achievement Code


// Checks all game center stuff
-(void)gameCenter {
	
#pragma mark Leaderboard
	GKScore *scores = [[GKScore alloc] initWithLeaderboardIdentifier:@"time"];
	scores.value = gameTime;
	
	NSLog(@"Attempt to report %@ of %lli", scores.leaderboardIdentifier, scores.value);
	[GKScore reportScores:@[scores] withCompletionHandler:^(NSError *error) {
		if (error != nil) {
			NSLog(@"%@", [error localizedDescription]);
		}
	}];
	
#pragma mark Achievements
	
	
	
	// Achievement: Afraid of the dark
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"] && gameTime <= 5) {
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

