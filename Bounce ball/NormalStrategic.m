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
	
	// Set starting goal size
	goalSize = 50*startiPad;
	
	gemSize = 25*startiPad;
	
	// Set up score
	score = [[UILabel alloc] initWithFrame:CGRectMake(0, scoreiPad/2, screenWidth, 50)];
	[self.view addSubview:score];
	scoreNumber = 0;
	score.text = @"Goals";
	score.textAlignment = NSTextAlignmentCenter;
	[score setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:scoreiPad]];
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		score.textColor = [UIColor whiteColor];
	}
	else {
		score.textColor = [UIColor blueColor];
	}
	
	previousCost = 1;
	triggered = 0;
	
	
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
	
	[speedUpTimer invalidate];
	[timer invalidate];
	
	// Set up scene
	
	// Set up border physics
	self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
	self.physicsBody.categoryBitMask = edgeCategory;
	self.physicsBody.contactTestBitMask = edgeCategory;
	self.physicsWorld.contactDelegate = self;
	self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
	
	
	ball = [self newBall];
	ball.position = CGPointMake(CGRectGetMidX(self.frame),                              CGRectGetMidY(self.frame));
	[self addChild:ball];
	
	[self spawnGoal];
	[self spawn];
	
	remove = [SKAction removeFromParent];
	
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
	pause.frame = CGRectMake(screenWidth-40, 20, 30.0, 30.0);
	[self.view addSubview:pause];
	
	pause.hidden = YES;
	
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(tapToStart) userInfo:nil repeats:NO];
}

-(void)tapToStart {
	if (!gameStarted && !self.scene.view.paused) {
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
	ballSprite.physicsBody.collisionBitMask = lineCategory | goalCategory | edgeCategory | pointGoalCategory;
	ballSprite.physicsBody.contactTestBitMask = lineCategory | goalCategory | edgeCategory | pointGoalCategory | gemCategory;
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
		[self playBounce];
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
		[self playGoal];
		[goal removeFromParent];
		[detect removeFromParent];
		[self spawnGoal];
		[self spawn];
		goalsHit = goalsHit + 1;
		score.text = [NSString stringWithFormat:@"%i", goalsHit];
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"goalsHit"]+1 forKey:@"goalsHit"];
	}
	else if ((firstBody.categoryBitMask & gemCategory) != 0) {
		[self playGoal];
		[gemSprite removeFromParent];
		[self spawn];
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]+1 forKey:@"gems"];
	}
	else {
		NSLog(@"Da fuq!");
	}
}

#pragma mark Game Over Code

-(void)gameOver {
	
	gameOver = YES;
	
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"gems"] >= previousCost*2 ) {
		
		pause.hidden = YES;
		
		reviveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[reviveButton addTarget:self action:@selector(revive) forControlEvents:UIControlEventTouchUpInside];
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			[reviveButton setBackgroundImage:[UIImage imageNamed:@"night_revive.png"] forState:UIControlStateNormal];
		}
		else {
			[reviveButton setBackgroundImage:[UIImage imageNamed:@"revive.png"] forState:UIControlStateNormal];
		}
		reviveButton.frame = CGRectMake(screenWidth/2-(163.3/2), screenHeight+375.0, 163.3, 45.0);
		[self.view addSubview:reviveButton];
		
		continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[continueButton addTarget:self action:@selector(reviveContinue) forControlEvents:UIControlEventTouchUpInside];
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			[continueButton setBackgroundImage:[UIImage imageNamed:@"night_continue.png"] forState:UIControlStateNormal];
		}
		else {
			[continueButton setBackgroundImage:[UIImage imageNamed:@"continue.png"] forState:UIControlStateNormal];
		}
		continueButton.frame = CGRectMake(screenWidth/2-(163.3/2), screenHeight+375+55, 163.3, 45.0);
		[self.view addSubview:continueButton];
		
		reviveAngel = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth/2)-(250/2), screenHeight+150, 250, 175)];
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			reviveAngel.image = [UIImage imageNamed:@"night_angel.png"];
		}
		else {
			reviveAngel.image = [UIImage imageNamed:@"angel.png"];
		}
		[self.view addSubview:reviveAngel];
		
		gemCount = [[UILabel alloc] initWithFrame:CGRectMake(reviveAngel.frame.origin.x+reviveAngel.frame.size.height/2-100/2, reviveAngel.frame.origin.y-reviveAngel.frame.size.height+75, 100, 75)];
		gemCount.text = [NSString stringWithFormat:@"%li", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]];
		gemCount.textAlignment = NSTextAlignmentRight;
		[gemCount setFont:[UIFont fontWithName:@"DINbekBlack" size:40]];
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			gemCount.textColor = [UIColor whiteColor];
		}
		else {
			gemCount.textColor = [UIColor blackColor];
		}
		[self.view addSubview:gemCount];
		
		gemCost = [[UILabel alloc] initWithFrame:CGRectMake(reviveAngel.frame.origin.x+reviveAngel.frame.size.height/2-100/2, reviveAngel.frame.origin.y+reviveAngel.frame.size.height-50, 100, 75)];
		gemCost.text = [NSString stringWithFormat:@"%i", previousCost*2];
		gemCost.textAlignment = NSTextAlignmentRight;
		[gemCost setFont:[UIFont fontWithName:@"DINbekBlack" size:40]];
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			gemCost.textColor = [UIColor whiteColor];
		}
		else {
			gemCost.textColor = [UIColor blackColor];
		}
		[self.view addSubview:gemCost];
		
		gemCountImage = [[UIImageView alloc] initWithFrame:CGRectMake(gemCount.frame.origin.x+gemCount.frame.size.width, gemCount.frame.origin.y+15, 50, 43)];
		gemCountImage.image = [UIImage imageNamed:@"gem.png"];
		[self.view addSubview:gemCountImage];
		
		gemCostImage = [[UIImageView alloc] initWithFrame:CGRectMake(gemCost.frame.origin.x+gemCost.frame.size.width, gemCost.frame.origin.y+15, 50, 43)];
		gemCostImage.image = [UIImage imageNamed:@"gem.png"];
		[self.view addSubview:gemCostImage];
		
		
		[UIView animateWithDuration:1.0
							  delay:0.0
							options: UIViewAnimationOptionCurveEaseOut
						 animations:^
		 {
			 reviveButton.frame = CGRectMake(reviveButton.frame.origin.x, reviveButton.frame.origin.y-screenHeight, reviveButton.frame.size.width, reviveButton.frame.size.height);
			 continueButton.frame = CGRectMake(continueButton.frame.origin.x, continueButton.frame.origin.y-screenHeight, continueButton.frame.size.width, continueButton.frame.size.height);
			 reviveAngel.frame = CGRectMake(reviveAngel.frame.origin.x, reviveAngel.frame.origin.y-screenHeight, reviveAngel.frame.size.width, reviveAngel.frame.size.height);
			 gemCountImage.frame = CGRectMake(gemCountImage.frame.origin.x, gemCountImage.frame.origin.y-screenHeight, gemCountImage.frame.size.width, gemCountImage.frame.size.height);
			 gemCostImage.frame = CGRectMake(gemCostImage.frame.origin.x, gemCostImage.frame.origin.y-screenHeight, gemCostImage.frame.size.width, gemCostImage.frame.size.height);
			 gemCost.frame = CGRectMake(gemCost.frame.origin.x, gemCost.frame.origin.y-screenHeight, gemCost.frame.size.width, gemCost.frame.size.height);
			 gemCount.frame = CGRectMake(gemCount.frame.origin.x, gemCount.frame.origin.y-screenHeight, gemCount.frame.size.width, gemCount.frame.size.height);
		 }
						 completion:^(BOOL finished)
		 {
		 }];
		
	}
	else {
		
		[self endGame];
		
	}
}

#pragma mark Revive Shit

-(void)revive {
	
	previousCost = previousCost*2;
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]-previousCost forKey:@"gems"];
	
	gemCount.text = [NSString stringWithFormat:@"%li", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]];
	
	[UIView animateWithDuration:1.0
						  delay:0.25
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^
	 {
		 reviveButton.frame = CGRectMake(reviveButton.frame.origin.x, reviveButton.frame.origin.y-screenHeight, reviveButton.frame.size.width, reviveButton.frame.size.height);
		 continueButton.frame = CGRectMake(continueButton.frame.origin.x, continueButton.frame.origin.y-screenHeight, continueButton.frame.size.width, continueButton.frame.size.height);
		 reviveAngel.frame = CGRectMake(reviveAngel.frame.origin.x, reviveAngel.frame.origin.y-screenHeight, reviveAngel.frame.size.width, reviveAngel.frame.size.height);
		 gemCountImage.frame = CGRectMake(gemCountImage.frame.origin.x, gemCountImage.frame.origin.y-screenHeight, gemCountImage.frame.size.width, gemCountImage.frame.size.height);
		 gemCostImage.frame = CGRectMake(gemCostImage.frame.origin.x, gemCostImage.frame.origin.y-screenHeight, gemCostImage.frame.size.width, gemCostImage.frame.size.height);
		 gemCost.frame = CGRectMake(gemCost.frame.origin.x, gemCost.frame.origin.y-screenHeight, gemCost.frame.size.width, gemCost.frame.size.height);
		 gemCount.frame = CGRectMake(gemCount.frame.origin.x, gemCount.frame.origin.y-screenHeight, gemCount.frame.size.width, gemCount.frame.size.height);
		 
		 ball.position = CGPointMake(screenWidth/2, screenHeight/2);
	 }
					 completion:^(BOOL finished)
	 {
	 }];
	
	triggered = 1;
	gameOver = NO;
	[self performSelector:@selector(restart) withObject:self afterDelay:2];
}

-(void)restart {
	triggered = 0;
	pause.hidden = NO;
	[ball.physicsBody applyImpulse:CGVectorMake(25, 25)];
	
}

-(void)reviveContinue {
	if (triggered == 0) {
		triggered = 1;
		[self endGame];
	}
	
}


-(void)endGame {
	
	[reviveButton removeFromSuperview];
	[continueButton removeFromSuperview];
	[reviveAngel removeFromSuperview];
	[gemCount removeFromSuperview];
	[gemCostImage removeFromSuperview];
	[gemCountImage removeFromSuperview];
	[gemCost removeFromSuperview];
	
	[self initExplosion];
	ball.hidden = YES;
	
	[self touchesEnded:nil withEvent:nil];
	
	[line removeFromParent];
	[lines removeFromParent];
	
	pos1x = nil;
	pos2x = nil;
	pos1y = nil;
	pos2y = nil;
	
	// Runs game center code block
	[self gameCenter];
	
	[self gameOverAnimation];
	pause.hidden = YES;
	
}

-(void)gameOverAnimation {
	
	int highScore;
	
#pragma mark Create Post Game UI
	
	[self playExplosion];
	
	postBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
	postBackground.image = [UIImage imageNamed:@"black_overlay.png"];
	postBackground.alpha = 0.75;
	[self.view addSubview:postBackground];
	
	bigImage = [[UIImageView alloc] initWithFrame:CGRectMake(25, screenHeight+20, screenWidth-50, screenWidth-50)];
	bigImage.image = [UIImage imageNamed:@"goalscore.png"];
	[self.view addSubview:bigImage];
	
	bestScore = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight+bigImage.frame.size.height+5, 135, 75)];
	bestScore.text = @"BEST:";
	bestScore.textAlignment = NSTextAlignmentRight;
	[bestScore setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:40]];
	bestScore.textColor = [UIColor whiteColor];
	[self.view addSubview:bestScore];
	
	highScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreGoals"];
	
	currentScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(bigImage.frame.origin.x+bigImage.frame.size.height/2-75/2, bigImage.frame.origin.y+bigImage.frame.size.width/2-100/2, 100, 75)];
	currentScoreNumber.text = [NSString stringWithFormat:@"%@", score.text];
	currentScoreNumber.textAlignment = NSTextAlignmentCenter;
	[currentScoreNumber setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:100]];
	currentScoreNumber.textColor = [UIColor greenColor];
	[self.view addSubview:currentScoreNumber];
	
	bestScoreNumber = [[UILabel alloc] initWithFrame:CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+10, bestScore.frame.origin.y, 100, 75)];
	bestScoreNumber.text = [NSString stringWithFormat:@"%i", highScore];
	[bestScoreNumber setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:40]];
	bestScoreNumber.textColor = [UIColor greenColor];
	[self.view addSubview:bestScoreNumber];
	
	if (goalsHit >= highScore) {
		[[NSUserDefaults standardUserDefaults] setInteger:goalsHit forKey:@"highScoreGoals"];
		currentScoreNumber.textColor = [UIColor greenColor];
		bestScoreNumber.text = [NSString stringWithFormat:@"%i", goalsHit];
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
	
	if(countingAnimation <= goalsHit) {
		
		currentScoreNumber.text = [NSString stringWithFormat:@"%i", countingAnimation];
	}
	else {
		countingAnimation = 0;
		[countingTimer invalidate];
	}
}

#pragma mark Buttons

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

-(void)rateButton:(UIButton *)button {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appsto.re/us/i1fu1.i"]];
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
	
	triggered = 0;
	
	gameOver = NO;
	gameStarted = NO;
	gameTime = 0;
	
	[self removeElements];
	
	[self.view presentScene:nil];
	
	NSLog(@"Alpha");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"showScene" object:self];
	NSLog(@"alpha 2");
}

#pragma mark Deal with appDidResignActive and appDidBecomeActive
-(void)pauseGame {
	[self pauseButton:nil];
}

-(void)theAppIsActive:(NSNotification *)note
{
	self.view.paused = YES;
	SKAction *pauseTimer= [SKAction sequence:@[
											   [SKAction performSelector:@selector(pauseTimerfun)
																onTarget:self]
											   
											   ]];
	[self runAction:pauseTimer withKey:@"pauseTimer"];
}

-(void) pauseTimerfun
{
	self.view.paused = YES;
	
}

#pragma mark Pause Menu Interface

-(void)pauseButton:(UIButton *)button {
	NSLog(@"Pause");
	self.view.paused = YES;
	[self createPauseMenuInterface];
	pause.hidden = YES;
}

-(void)createPauseMenuInterface {
	
	pauseBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	pauseBackground.image = [UIImage imageNamed:@"black_overlay.png"];
	pauseBackground.alpha = 0.75;
	[self.view addSubview:pauseBackground];
	
	bigPauseImage = [[UIImageView alloc] initWithFrame:CGRectMake(75, 75, screenWidth-150, screenWidth-110)];
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
	pauseContinue.hidden = YES;
	pauseContinue.enabled = NO;
	[self.view addSubview:pauseContinue];
	
	
	[self performSelector:@selector(showResume) withObject:self afterDelay:2];
}

-(void)showResume {
	
	pauseContinue.alpha = 0;
	pauseContinue.hidden = NO;
	
	[UIView animateWithDuration:1.5
						  delay:1.0
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^
	 {
		 pauseContinue.alpha = 1;
	 }
					 completion:^(BOOL finished)
	 {
		 pauseContinue.enabled = YES;
	 }];
	
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


-(void)removeElements {
	// Removes elements not in the scene
	[replay removeFromSuperview];
	[menu removeFromSuperview];
	[rate removeFromSuperview];
	[score removeFromSuperview];
	[share removeFromSuperview];
	[goal removeFromParent];
	[detect removeFromParent];
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
}

// Start ball on user touch
// Done to avoid extremely low FPS at load of scene
-(void)start {
	
	self.scene.paused = NO;
	
	[tapToStart removeFromSuperview];
	
	goalsHit = 0;
	
	score.text = @"0";
	
	gameStarted = YES;
	
	[ball.physicsBody applyImpulse:CGVectorMake(25, 25)];
	//Calls ball speed up method
	speedUpTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(speedUp:) userInfo:nil repeats:YES];
	// Start Timer
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0
											 target:self
										   selector:@selector(timer:)
										   userInfo:nil
											repeats:YES];
}

-(void)timer:(NSTimer *)timer {
	
	if (!gameOver) {
		
		minutesTimer = gameTime/60;
		secondsTimer = gameTime-(minutesTimer * 60);
		
		gameTime = gameTime + 1;
		// Minutes:Seconds
	}
	
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

-(void)playGoal {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		SystemSoundID soundID;
		NSString *soundFile = [[NSBundle mainBundle]
							   pathForResource:@"goal_contact" ofType:@"mp3"];
		AudioServicesCreateSystemSoundID((__bridge  CFURLRef)
										 [NSURL fileURLWithPath:soundFile], & soundID);
		AudioServicesPlaySystemSound(soundID);
	}
	else {
		NSLog(@"***Goal Sound***");
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

#pragma mark Spawning Methods

-(void)spawn {
	int i = arc4random() % 25;
	if (i == 1) {
		[self spawnGem];
	}
}

-(void)spawnGoal {
	
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		goal = [SKSpriteNode spriteNodeWithImageNamed:@"night_goal.png"];
	}
	else {
		goal = [SKSpriteNode spriteNodeWithImageNamed:@"goal.png"];
	}
	goal.size = CGSizeMake(goalSize, goalSize);
	goal.position = [self chooseLocationGoal];
	[self addChild:goal];
	
	float goalSizes = (float)goalSize / 2.0;
	
	goal.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:goalSizes];
	goal.physicsBody.dynamic = NO;
	goal.physicsBody.categoryBitMask = goalCategory;
	goal.physicsBody.collisionBitMask = ballCategory;
	goal.physicsBody.contactTestBitMask = goalCategory;
	
}

-(CGPoint)chooseLocationGoal {
	
	kMinDistanceFromBall = 50;
	
	CGFloat goalWidth = goal.size.width;
	CGFloat goalHeight = goal.size.height;
	
	CGFloat maxX = screenWidth - goalWidth*2;
	CGFloat maxY = screenHeight - goalHeight*2;
	
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


-(void)spawnGem {
	
	gemSprite = [SKSpriteNode spriteNodeWithImageNamed:@"gem.png"];
	gemSprite.size = CGSizeMake(gemSize, gemSize);
	gemSprite.position = [self chooseLocationGem];
	[self addChild:gemSprite];
	
	float gemSizes = (float)gemSize / 2.0;
	
	gemSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:gemSizes];
	gemSprite.physicsBody.dynamic = NO;
	gemSprite.physicsBody.categoryBitMask = gemCategory;
	gemSprite.physicsBody.collisionBitMask = ballCategory;
	gemSprite.physicsBody.contactTestBitMask = gemCategory;
	
}

-(CGPoint)chooseLocationGem {
	
	kMinDistanceFromBall = 50;
	
	CGFloat gemWidth = gemSprite.size.width;
	CGFloat gemHeight = gemSprite.size.height;
	
	CGFloat maxX = screenWidth - gemWidth*3;
	CGFloat maxY = screenHeight - gemHeight*3;
	
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
	
	return CGPointMake(newX+gemWidth/2, newY+gemHeight/2);
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
