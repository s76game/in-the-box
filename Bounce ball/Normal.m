//
//  Normal.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/12/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Normal.h"


@protocol GameSceneDelegate <NSObject>

-(void)showDifferentView;

@end

@interface Normal ()
@property BOOL contentCreated;

@property (nonatomic) id <sceneDelegate, resetSKScene, shareTimeDelegate> delegate;


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

-(void)initExplosion {

	explosion = [[SKEmitterNode alloc] init];
	explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"explode" ofType:@"sks"]];
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[explosion setParticleColor:[UIColor whiteColor]];
		[explosion setParticleTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"night_particle.png"]]];
	}
	else {
		[explosion setParticleColor:[UIColor redColor]];
		[explosion setParticleTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"particle.png"]]];
	}
	[explosion setNumParticlesToEmit:200];
	[explosion setParticleBirthRate:750];
	[explosion setParticleLifetime:0.5];
	[explosion setEmissionAngleRange:45];
	[explosion setParticleSpeed:100];
	[explosion setParticleSpeedRange:50];
	[explosion setXAcceleration:0];
	[explosion setYAcceleration:0];
	[explosion setParticleAlpha:0.8];
	[explosion setParticleAlphaRange:0.2];
	[explosion setParticleAlphaSpeed:-0.5];
	[explosion setParticleScale:0.25];
	[explosion setParticleScaleRange:0.4];
	[explosion setParticleScaleSpeed:-0.5];
	[explosion setParticleRotation:0];
	[explosion setParticleRotationRange:0];
	[explosion setParticleRotationSpeed:0];
	[explosion setPosition:ball.position];
	[self addChild:explosion];
}

- (void)createSceneContents
{
	[self screenSize];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pauseGame)
												 name:@"PauseGameScene"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(theAppIsActive:)
												 name:@"appIsActive" object:nil];
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		night = YES;
	}
	else {
		night = NO;
	}

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
	if (IPAD) {
		scoreiPad = 100;
		startiPad = 2;
		speediPad = 115;
	} else {
		scoreiPad = 50;
		startiPad = 1;
		speediPad = 15;
	}

	
	// Set up score
	score = [[UILabel alloc] initWithFrame:CGRectMake(0, scoreiPad/2, screenWidth, 50)];
	[self.view addSubview:score];
	scoreNumber = 0;
	score.text = @"Time";
	score.textAlignment = NSTextAlignmentCenter;
	[score setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:scoreiPad]];
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		score.textColor = [UIColor whiteColor];
	}
	else {
		score.textColor = [UIColor blueColor];
	}

	
	[speedUpTimer invalidate];
	[timer invalidate];
	
	// Set up background texture
	NSString *textureName;
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		textureName = @"night_background.png";
	}
	else {
		textureName = @"background.png";
	}
	
	SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@", textureName]];
	SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:self.view.frame.size];
	background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
	[self addChild:background];
	
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
	if (night) {
		[border setStrokeColor:[UIColor whiteColor]];
	}
	else {
		[border setStrokeColor:[UIColor blackColor]];
	}
	[border setLineWidth:0];
	
	[self addChild:border];
	
	ball = [self newBall];
	ball.position = CGPointMake(CGRectGetMidX(self.frame),                              CGRectGetMidY(self.frame));
	[self addChild:ball];
	
	// Start random direction code
	int smallest = 1;
	int largest = 2;
	x = (int)smallest + (int)arc4random() %(largest+1-smallest);
	y = (int)smallest + (int)arc4random() %(largest+1-smallest);
	
	switch (x) {
  case 1:
			x = speediPad*2;
			break;
  case 2:
			x = -speediPad*2;
			break;
  default:
			break;
	}
	switch (y) {
  case 1:
			y = speediPad*2;
			break;
  case 2:
			y = -speediPad*2;
			break;
  default:
			break;
	}
	
	
	pause = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pause addTarget:self action:@selector(pauseButton:) forControlEvents:UIControlEventTouchUpInside];
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[pause setBackgroundImage:[UIImage imageNamed:@"night_pause_button.png"] forState:UIControlStateNormal];
	}
	else {
		[pause setBackgroundImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
	}
	pause.frame = CGRectMake(screenWidth-50, 20, 50.0, 50.0);
	[self.view addSubview:pause];
	
	pause.hidden = YES;
	
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(tapToStart) userInfo:nil repeats:NO];
}

-(void)tapToStart {
	if (!gameStarted) {
		tapToStart = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2-100, 75, 200, 75)];
		tapToStart.text = [NSString stringWithFormat:@"Tap to start"];
		tapToStart.textAlignment = NSTextAlignmentCenter;
		[tapToStart setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:25]];
		tapToStart.textColor = [UIColor grayColor];
		tapToStart.alpha = 0;
		[self.view addSubview:tapToStart];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelay:0.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		tapToStart.alpha = 1;
		[UIView commitAnimations];
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
	else if (!gameOver && !gameStarted) {
		[self start];
		pause.hidden = NO;
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
	[lines setLineWidth:5];
	
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
	[lines setLineWidth:5];
	
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
		textureName = @"night_ball.png";
	}
	else {
		textureName = @"ball.png";
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
	ballSprite.physicsBody.collisionBitMask = lineCategory | edgeCategory;
	ballSprite.physicsBody.contactTestBitMask = lineCategory | edgeCategory;
	return ballSprite;
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
	// Handle contacts between two physics bodies.
	
	SKPhysicsBody *firstBody;
	
	if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask)
	{
		firstBody = contact.bodyA;
	}
	else
	{
		firstBody = contact.bodyB;
	}
	
	
	if ((firstBody.categoryBitMask & lineCategory) != 0)
	{
		// Ball hits line
		[self playBounce];
		scoreNumber = scoreNumber + 1;
	}
	else {
		// Ball hits wall
		[self playExplosion];
		[self initExplosion];
		ball.hidden = YES;
		[ball.physicsBody setVelocity:CGVectorMake(0, 0)];
		[self gameOver];
	}
}

#pragma mark Game Over Code

-(void)gameOver {
	
	[self touchesEnded:nil withEvent:nil];
	
	[line removeFromParent];
	[lines removeFromParent];
	
	pos1x = nil;
	pos2x = nil;
	pos1y = nil;
	pos2y = nil;
	
	// Runs game center code block
	[self gameCenter];

	gameOver = YES;
	[self gameOverAnimation];
	pause.hidden = YES;
	[line removeFromParent];
	[lines removeFromParent];
}

-(void)gameOverAnimation {
	
	float highScore;
	
#pragma mark Create Post Game UI

	
	postBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
	postBackground.image = [UIImage imageNamed:@"black_overlay.png"];
	postBackground.alpha = 0.75;
	[self.view addSubview:postBackground];
	
	bigImage = [[UIImageView alloc] initWithFrame:CGRectMake(25, screenHeight+20, screenWidth-50, screenWidth-50)];
	bigImage.image = [UIImage imageNamed:@"clockscore.png"];
	[self.view addSubview:bigImage];
	
	bestScore = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight+bigImage.frame.size.height+5, 135, 75)];
	bestScore.text = @"BEST:";
	bestScore.textAlignment = NSTextAlignmentRight;
	[bestScore setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:40]];
	bestScore.textColor = [UIColor whiteColor];
	[self.view addSubview:bestScore];
	
	highScore = [[NSUserDefaults standardUserDefaults] floatForKey:@"highScoreTime"];
	
	currentScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(bigImage.frame.origin.x+bigImage.frame.size.height/2-75/2, bigImage.frame.origin.y+bigImage.frame.size.width/2-100/2+70, 100, 75)];
	currentScoreNumber.text = [NSString stringWithFormat:@"%@", score.text];
	currentScoreNumber.textAlignment = NSTextAlignmentCenter;
	[currentScoreNumber setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:40]];
	currentScoreNumber.textColor = [UIColor greenColor];
	[self.view addSubview:currentScoreNumber];
	
	bestScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+10, bestScore.frame.origin.y, 100, 75)];
	
		// Parse High Score Data
		int minutesTimerHigh;
		int secondsTimerHigh;
	
		minutesTimerHigh = (int)highScore/60;
		secondsTimerHigh = (int)highScore-(minutesTimerHigh * 60);
	
	bestScoreNumber.text = [NSString stringWithFormat:@"%01d:%02d", minutesTimerHigh, secondsTimerHigh];
	[bestScoreNumber setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:40]];
	bestScoreNumber.textColor = [UIColor greenColor];
	[self.view addSubview:bestScoreNumber];

	
	if (gameTime >= highScore) {
		[[NSUserDefaults standardUserDefaults] setFloat:gameTime forKey:@"highScoreTime"];
		currentScoreNumber.textColor = [UIColor greenColor];
		// Minutes:Seconds
		bestScoreNumber.text = [NSString stringWithFormat:@"%01d:%02d", minutesTimer, secondsTimer];
	}
	
	
	// Start first row
	
	replay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[replay addTarget:self action:@selector(restartButton:) forControlEvents:UIControlEventTouchUpInside];
	[replay setBackgroundImage:[UIImage imageNamed:@"post_replay.png"] forState:UIControlStateNormal];
	replay.frame = CGRectMake(30.0, screenHeight+375.0, 75.0, 75.0);
	[self.view addSubview:replay];
	
	menu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[menu addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
	[menu setBackgroundImage:[UIImage imageNamed:@"post_exit.png"] forState:UIControlStateNormal];
	menu.frame = CGRectMake(screenWidth/2-75/2, replay.frame.origin.y, 75.0, 75.0);
	[self.view addSubview:menu];
	
	rate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[rate addTarget:self action:@selector(rateButton:) forControlEvents:UIControlEventTouchUpInside];
	[rate setBackgroundImage:[UIImage imageNamed:@"post_rate.png"] forState:UIControlStateNormal];
	rate.frame = CGRectMake(screenWidth-30.0-75, replay.frame.origin.y, 75.0, 75.0);
	[self.view addSubview:rate];
	
	
	// Start second row
	
	
	gameCenter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[gameCenter addTarget:self action:@selector(gameCenterButton:) forControlEvents:UIControlEventTouchUpInside];
	[gameCenter setBackgroundImage:[UIImage imageNamed:@"post_gamecenter.png"] forState:UIControlStateNormal];
	gameCenter.frame = CGRectMake(replay.frame.origin.x+replay.frame.size.width/2+10, menu.frame.origin.y+menu.frame.size.height, 75, 75);
	[self.view addSubview:gameCenter];
	
	share = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[share addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
	[share setBackgroundImage:[UIImage imageNamed:@"post_share.png"] forState:UIControlStateNormal];
	share.frame = CGRectMake(rate.frame.origin.x-rate.frame.size.width/2-10, menu.frame.origin.y+menu.frame.size.height, 75.0, 75.0);
	[self.view addSubview:share];
	
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
		 bestScore.frame = CGRectMake(bestScore.frame.origin.x, bestScore.frame.origin.y-screenHeight, bestScore.frame.size.width, bestScore.frame.size.height);
		 bestScoreNumber.frame = CGRectMake(bestScoreNumber.frame.origin.x, bestScoreNumber.frame.origin.y-screenHeight, bestScoreNumber.frame.size.width, bestScoreNumber.frame.size.height);
		 currentScoreNumber.frame = CGRectMake(currentScoreNumber.frame.origin.x, currentScoreNumber.frame.origin.y-screenHeight, currentScoreNumber.frame.size.width, currentScoreNumber.frame.size.height);
		 rate.frame = CGRectMake(rate.frame.origin.x, rate.frame.origin.y-screenHeight, rate.frame.size.width, rate.frame.size.height);
		 share.frame = CGRectMake(share.frame.origin.x, share.frame.origin.y-screenHeight, share.frame.size.width, share.frame.size.height);
		 bigImage.frame = CGRectMake(bigImage.frame.origin.x, bigImage.frame.origin.y-screenHeight, bigImage.frame.size.width, bigImage.frame.size.height);
		 gameCenter.frame = CGRectMake(gameCenter.frame.origin.x, gameCenter.frame.origin.y-screenHeight, gameCenter.frame.size.width, gameCenter.frame.size.height);
		 	 }
					 completion:^(BOOL finished)
	 {
}];
	
	
	
}

-(void)adjustInterface {
	
	bestScore.frame = CGRectMake(20, screenHeight+450, 270, 150);
	[bestScore setFont:[UIFont fontWithName:@"Prototype" size:80]];
	currentScoreNumber.frame = CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+20, bestScore.frame.origin.y, 200, 150);
	[currentScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:80]];
	bestScoreNumber.frame = CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+20, bestScore.frame.origin.y, 200, 150);
	[bestScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:80]];
	replay.frame = CGRectMake((screenWidth/2)-160, screenHeight+650, 320, 100);
	menu.frame = CGRectMake((screenWidth/2)-160, replay.frame.origin.y+replay.frame.size.height+30, 320, 100);
	gameCenter.frame = CGRectMake(menu.frame.origin.x+120, menu.frame.origin.y+menu.frame.size.height+30, 100, 100);
	
}

-(void)countAnimation {
	countingAnimation = countingAnimation +1;
	
	if(countingAnimation <= (gameTime-1)) {
		
		// Parse High Score Data
		int minutesTimerCount;
		int secondsTimerCount;
		
		minutesTimerCount = (int)countingAnimation/60;
		secondsTimerCount = (int)countingAnimation-(minutesTimerCount * 60);
		
		currentScoreNumber.text = [NSString stringWithFormat:@"%01d:%02d", minutesTimerCount, secondsTimerCount];
	}
	else {
		countingAnimation = 0;
		[countingTimer invalidate];
	}
}

#pragma mark Buttons

-(void)shareButton:(UIButton *)button {
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"shareTime" object:self];
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

-(void)rateButton:(UIButton *)button {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appsto.re/us/i1fu1.i"]];
}

-(void)menuButton:(UIButton *)button {
	
	gameOver = NO;
	gameStarted = NO;
	gameTime = 0;
	
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
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"showScene" object:self];
}

#pragma mark Pause Menu Interface

-(void)pauseButton:(UIButton *)button {
	NSLog(@"Pause");
	self.scene.view.paused = YES;
	[self createPauseMenuInterface];
	pause.hidden = YES;
}

-(void)createPauseMenuInterface {
	
	pauseBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	pauseBackground.image = [UIImage imageNamed:@"black_overlay.png"];
	pauseBackground.alpha = 0.75;
	[self.view addSubview:pauseBackground];
	
	bigPauseImage = [[UIImageView alloc] initWithFrame:CGRectMake(75, 75, screenWidth-150, screenWidth-150)];
	bigPauseImage.image = [UIImage imageNamed:@"pause_icon.png"];
	[self.view addSubview:bigPauseImage];
	
	pauseRestart = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pauseRestart addTarget:self action:@selector(pauseRestart) forControlEvents:UIControlEventTouchUpInside];
	[pauseRestart setBackgroundImage:[UIImage imageNamed:@"pause_restart.png"] forState:UIControlStateNormal];
	pauseRestart.frame = CGRectMake(30.0, screenHeight-275.0, 75.0, 75.0);
	[self.view addSubview:pauseRestart];
	
	pauseExit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pauseExit addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
	[pauseExit setBackgroundImage:[UIImage imageNamed:@"pause_exit.png"] forState:UIControlStateNormal];
	pauseExit.frame = CGRectMake(210, pauseRestart.frame.origin.y, 75.0, 75.0);
	[self.view addSubview:pauseExit];
	
	pauseContinue = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pauseContinue addTarget:self action:@selector(removePauseMenuInterface) forControlEvents:UIControlEventTouchUpInside];
	[pauseContinue setBackgroundImage:[UIImage imageNamed:@"pause_resume.png"] forState:UIControlStateNormal];
	pauseContinue.frame = CGRectMake(120, pauseRestart.frame.origin.y, 75.0, 75.0);
	[self.view addSubview:pauseContinue];
	
}

-(void)pauseRestart {
	[self removePauseMenuInterface];
	[self restartButton:pauseRestart];
}

-(void)removePauseMenuInterface {
	[pauseBackground removeFromSuperview];
	[bigPauseImage removeFromSuperview];
	[pauseRestart removeFromSuperview];
	[pauseExit removeFromSuperview];
	[pauseContinue removeFromSuperview];
	
	self.scene.view.paused = NO;
	pause.hidden = NO;
}


#pragma mark Deal with appDidResignActive and appDidBecomeActive
-(void)pauseGame {
	[self pauseButton:nil];
}

-(void)theAppIsActive:(NSNotification *)note
{
	self.view.paused = YES;
	SKAction *pauseTimer= [SKAction sequence:@[
											   [SKAction waitForDuration:0.1],
											   [SKAction performSelector:@selector(pauseTimerfun)
																onTarget:self]
											   
											   ]];
	[self runAction:pauseTimer withKey:@"pauseTimer"];
}

-(void) pauseTimerfun
{
	self.view.paused = YES;
	
}



-(void)removeElements {
	// Removes elements not in the scene
	[replay removeFromSuperview];
	[menu removeFromSuperview];
	[rate removeFromSuperview];
	[score removeFromSuperview];
	[share removeFromSuperview];
	[currentScoreNumber removeFromSuperview];
	[bestScoreNumber removeFromSuperview];
	[bestScore removeFromSuperview];
	[gameCenter removeFromSuperview];
	[postBackground removeFromSuperview];
	[explosion removeFromParent];
	[bigImage removeFromSuperview];
	pause.hidden = YES;
}

// Ball speed up method
- (void) speedUp:(NSTimer *)timer
{
	int xImpluse;
	int yImpluse;
	if (ball.physicsBody.velocity.dx > 0) {
		if (IPAD) {
			xImpluse = 25;
		}
		else {
			xImpluse = 2;
		}
	}
	else {
		if (IPAD) {
			xImpluse = -25;
		}
		else {
			xImpluse = -2;
		}
	}
	
	if (ball.physicsBody.velocity.dy > 0) {
		if (IPAD) {
			yImpluse = 25;
		}
		else {
			yImpluse = 2;
		}
	}
	else {
		if (IPAD) {
			yImpluse = -25;
		}
		else {
			yImpluse = -2;
		}
	}
	
	if (!gameOver) {
		[ball.physicsBody applyImpulse:CGVectorMake(xImpluse, yImpluse)];
	}
}

// Start ball on user touch
// Done to avoid extremely low FPS at load of scene
-(void)start {
	
	gameTime = 0;
	[tapToStart removeFromSuperview];
	gameStarted = YES;
	
	[ball.physicsBody applyImpulse:CGVectorMake(35, 35)];
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


#pragma mark Sounds

-(void)playBounce {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		SystemSoundID soundID;
		NSString *soundFile = [[NSBundle mainBundle]
							   pathForResource:@"bounce_sound" ofType:@"mp3"];
		AudioServicesCreateSystemSoundID((__bridge  CFURLRef)
										 [NSURL fileURLWithPath:soundFile], & soundID);
		AudioServicesPlaySystemSound(soundID);
	}
	else {
		NSLog(@"***Bouncing Sound***");
	}
}

-(void)playExplosion {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		SystemSoundID soundID;
		NSString *soundFile = [[NSBundle mainBundle]
							   pathForResource:@"end_noise" ofType:@"mp3"];
		AudioServicesCreateSystemSoundID((__bridge  CFURLRef)
										 [NSURL fileURLWithPath:soundFile], & soundID);
		AudioServicesPlaySystemSound(soundID);
	}
	else {
		NSLog(@"***Explosion Sound***");
	}
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

