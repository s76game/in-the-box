//
//  Normal.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/12/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "TimeBased.h"

@interface TimeBased ()
@end

@implementation TimeBased

-(void)didMoveToView:(SKView *)view {

	[self screenSize];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pauseButton)
												 name:@"resignActive"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(becomeActive)
												 name:@"becomeActive" object:nil];
	
	
	// Set default values/reset
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
		speediPad = 8;
	} else {
		scoreiPad = 50;
		startiPad = 1;
		speediPad = 1;
	}
	
	previousCost = 5;
	triggered = 0;
	
	[speedUpTimer invalidate];
	[timer invalidate];
	
	
	
	// Create score label
	score = [[UILabel alloc] initWithFrame:CGRectMake(0, scoreiPad/2, screenWidth, 75)];
	[self.view addSubview:score];
	scoreValue = 0;
	score.text = @"Time";
	score.textAlignment = NSTextAlignmentCenter;
	[score setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:scoreiPad]];
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		score.textColor = [UIColor whiteColor];
	}
	else {
		score.textColor = [UIColor blueColor];
	}
	
	// Create background texture
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
	
	// Create edge physics body
	self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
	self.physicsBody.categoryBitMask = edgeCategory;
	self.physicsBody.contactTestBitMask = edgeCategory;
	self.physicsWorld.contactDelegate = self;
	self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
	
	
	// Create ball
	ball = [self newBall];
	ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
	[self addChild:ball];
	
	[self spawn];
	[self setStartingDirection];
	
	UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(pauseButton)];
	tripleTap.numberOfTapsRequired = 3;
	[self.view addGestureRecognizer:tripleTap];
	
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(tapToStart) userInfo:nil repeats:NO];
}

-(void)screenSize {
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	screenWidth = screenRect.size.width;
	screenHeight = screenRect.size.height;
}

-(void)setStartingDirection {
	// Make ball start in random direction
	
	// speediPad*2 compensates for greater mass of iPad ball
	
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
}

-(void)tapToStart {
	if (!gameStarted && !self.scene.view.paused) {
		// Create label
		tapToStart = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2-100, 75*startiPad, 200, 75)];
		tapToStart.text = [NSString stringWithFormat:@"Tap to start"];
		tapToStart.textAlignment = NSTextAlignmentCenter;
		[tapToStart setFont:[UIFont fontWithName:@"DS-Digital-BoldItalic" size:25]];
		tapToStart.textColor = [UIColor grayColor];
		tapToStart.alpha = 0;
		[self.view addSubview:tapToStart];
		
		// Fade in animation
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelay:0.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		tapToStart.alpha = 1;
		[UIView commitAnimations];
	}
}

-(void)initExplosion {
	// Create explosion for when ball hits edge
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
	// Set animation effects
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
		// Remove previous real/fake lines
		[line removeFromParent];
		[lines removeFromParent];

		touchStarted = YES;
		dotDrawn = YES;
		
		// Get touch location
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
		pos1x = positionInScene.x;
		pos1y = positionInScene.y;
	}
	else if (!gameOver && !gameStarted) {
		// Start game
		[self start];
	}
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!gameOver && gameStarted && touchStarted) {
		// Remove previous fake line
		[lines removeFromParent];
		
		dotDrawn = NO;

		// Get touch location
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
		pos2x = positionInScene.x;
		pos2y = positionInScene.y;
	
		// Create fake line
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
		// Remove fake lines
		[lines removeFromParent];
		
		// Get touch location
		UITouch* touch = [touches anyObject];
		CGPoint positionInScene = [touch locationInNode:self];
		pos2x = positionInScene.x;
		pos2y = positionInScene.y;

		// Create real line
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
		
		// Reset values
		pos1x = 0;
		pos2x = 0;
		pos1y =	0;
		pos2y = 0;
		touchStarted = NO;
		
		// Update lines drawn achievement
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"linesDrawn"]+1 forKey:@"linesDrawn"];
	}
}


-(SKSpriteNode *)newBall {
	// Generates new ball skin
	
	NSString *textureName;
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		textureName = @"night_ball.png";
	}
	else {
		textureName = @"ball.png";
	}
	
	// Create physics body ball
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
	ballSprite.physicsBody.contactTestBitMask = lineCategory | edgeCategory | gemCategory;
	return ballSprite;
}


-(void)didBeginContact:(SKPhysicsContact *)contact {
	// Physics bodies begin contact
	
	// Assign contact pseudo variables to bodies
	SKPhysicsBody *firstBody;
	if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
		firstBody = contact.bodyA;
	}
	else {
		firstBody = contact.bodyB;
	}
	
	// Determine which bodies made contact
	if ((firstBody.categoryBitMask & lineCategory) != 0) {
		// Ball contacts line
		[self playBounce];
		scoreValue = scoreValue + 1;
		[self spawn];
	}
	else if ((firstBody.categoryBitMask & edgeCategory) != 0) {
		// Ball contacts wall
		[ball.physicsBody setVelocity:CGVectorMake(0, 0)];
		[self gameOver];
	}
	else if ((firstBody.categoryBitMask & gemCategory) != 0) {
		// Body contacts gem
		[self playGoal];
		[gemSprite removeFromParent];
		gemSpawned = NO;
		[self spawn];
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]+1 forKey:@"gems"];
	}
}

#pragma mark - Game Over Code

-(void)gameOver {
	
	gameOver = YES;
	
	// Check to see if revive can be afforded
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"gems"] >= previousCost*2 ) {
		
		// Create revive interface
		
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
		[continueButton addTarget:self action:@selector(endGame) forControlEvents:UIControlEventTouchUpInside];
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
		
		gemCount = [[UILabel alloc] initWithFrame:CGRectMake(reviveAngel.frame.origin.x+reviveAngel.frame.size.height/2-100/2, reviveAngel.frame.origin.y-reviveAngel.frame.size.height+100, 100, 75)];
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
		
		if (IPAD) {
			// Adjust for iPad interface
			[self adjustInterfacePause];
		}
		
		
		[UIView animateWithDuration:1.0
							  delay:0.0
							options: UIViewAnimationOptionCurveEaseOut
						 animations:^ {
			 reviveButton.frame = CGRectMake(reviveButton.frame.origin.x, reviveButton.frame.origin.y-screenHeight, reviveButton.frame.size.width, reviveButton.frame.size.height);
			 continueButton.frame = CGRectMake(continueButton.frame.origin.x, continueButton.frame.origin.y-screenHeight, continueButton.frame.size.width, continueButton.frame.size.height);
			 reviveAngel.frame = CGRectMake(reviveAngel.frame.origin.x, reviveAngel.frame.origin.y-screenHeight, reviveAngel.frame.size.width, reviveAngel.frame.size.height);
			 gemCountImage.frame = CGRectMake(gemCountImage.frame.origin.x, gemCountImage.frame.origin.y-screenHeight, gemCountImage.frame.size.width, gemCountImage.frame.size.height);
			 gemCostImage.frame = CGRectMake(gemCostImage.frame.origin.x, gemCostImage.frame.origin.y-screenHeight, gemCostImage.frame.size.width, gemCostImage.frame.size.height);
			 gemCost.frame = CGRectMake(gemCost.frame.origin.x, gemCost.frame.origin.y-screenHeight, gemCost.frame.size.width, gemCost.frame.size.height);
			 gemCount.frame = CGRectMake(gemCount.frame.origin.x, gemCount.frame.origin.y-screenHeight, gemCount.frame.size.width, gemCount.frame.size.height);
		 }
		completion:nil];
	}
	else {
		// Revive can't be afforded
		[self endGame];
		
	}
}

-(void)adjustInterfacePause {
	reviveButton.frame = CGRectMake(reviveButton.frame.origin.x, reviveButton.frame.origin.y+150, reviveButton.frame.size.width, reviveButton.frame.size.height);
	continueButton.frame = CGRectMake(continueButton.frame.origin.x, continueButton.frame.origin.y+150, continueButton.frame.size.width, continueButton.frame.size.height);
	reviveAngel.frame = CGRectMake(reviveAngel.frame.origin.x, reviveAngel.frame.origin.y+150, reviveAngel.frame.size.width, reviveAngel.frame.size.height);
	gemCountImage.frame = CGRectMake(gemCountImage.frame.origin.x, gemCountImage.frame.origin.y+150, gemCountImage.frame.size.width, gemCountImage.frame.size.height);
	gemCostImage.frame = CGRectMake(gemCostImage.frame.origin.x, gemCostImage.frame.origin.y+150, gemCostImage.frame.size.width, gemCostImage.frame.size.height);
	gemCost.frame = CGRectMake(gemCost.frame.origin.x, gemCost.frame.origin.y+150, gemCost.frame.size.width, gemCost.frame.size.height);
	gemCount.frame = CGRectMake(gemCount.frame.origin.x, gemCount.frame.origin.y+150, gemCount.frame.size.width, gemCount.frame.size.height);

}

-(void)revive {
	// Double previous cost
	previousCost = previousCost*2;
	NSLog(@"%i", previousCost);
	
	// Update gem count
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]-previousCost forKey:@"gems"];
	gemCount.text = [NSString stringWithFormat:@"%li", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]];
	
	[UIView animateWithDuration:1.0
						  delay:0.25
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^ {
		 reviveButton.frame = CGRectMake(reviveButton.frame.origin.x, reviveButton.frame.origin.y-screenHeight, reviveButton.frame.size.width, reviveButton.frame.size.height);
		 continueButton.frame = CGRectMake(continueButton.frame.origin.x, continueButton.frame.origin.y-screenHeight, continueButton.frame.size.width, continueButton.frame.size.height);
		 reviveAngel.frame = CGRectMake(reviveAngel.frame.origin.x, reviveAngel.frame.origin.y-screenHeight, reviveAngel.frame.size.width, reviveAngel.frame.size.height);
		 gemCountImage.frame = CGRectMake(gemCountImage.frame.origin.x, gemCountImage.frame.origin.y-screenHeight, gemCountImage.frame.size.width, gemCountImage.frame.size.height);
		 gemCostImage.frame = CGRectMake(gemCostImage.frame.origin.x, gemCostImage.frame.origin.y-screenHeight, gemCostImage.frame.size.width, gemCostImage.frame.size.height);
		 gemCost.frame = CGRectMake(gemCost.frame.origin.x, gemCost.frame.origin.y-screenHeight, gemCost.frame.size.width, gemCost.frame.size.height);
		 gemCount.frame = CGRectMake(gemCount.frame.origin.x, gemCount.frame.origin.y-screenHeight, gemCount.frame.size.width, gemCount.frame.size.height);

		 ball.position = CGPointMake(screenWidth/2, screenHeight/2);
	}
	completion:nil];
	
	triggered = 1;
	gameOver = NO;
	[self performSelector:@selector(restart) withObject:self afterDelay:2];
}

-(void)restart {
	// Restart game from middle
	triggered = 0;
	[ball.physicsBody applyImpulse:CGVectorMake(25*speediPad, 25*speediPad)];
	
}

-(void)endGame {
	if (!gameEnded) {
		gameEnded = YES;
		
		// Remove revive interface
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
	
		[self gameCenter];
		[self gameOverAnimation];
	}
}


#pragma mark - Create Post Game UI

-(void)gameOverAnimation {
	
	float highScore;
	
	[self playExplosion];

	// Create interface
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
	
	// Start first row buttons
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
		share.enabled = NO;
		share.alpha = 0.5;
	}
	
	// Fly in animation
	[UIView animateWithDuration:1.0
						  delay:0.0
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^ {
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
	completion:nil];
}

-(void)adjustInterface {
	// Adjust post game interface for iPad
	[bestScore setFont:[UIFont fontWithName:@"Prototype" size:80]];
	[currentScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:80]];
	[currentScoreNumber setFrame:CGRectMake(bigImage.frame.origin.x+bigImage.frame.size.height/2-150/2-20, bigImage.frame.origin.y+bigImage.frame.size.width/2-200/2+175, 200, 150)];
	[bestScoreNumber setFont:[UIFont fontWithName:@"Prototype" size:80]];
	[bestScore setFrame:CGRectMake(screenWidth/2-100*(startiPad*2), bigImage.frame.origin.y+bigImage.frame.size.height+5, 100*(startiPad*2), 75)];
	[bestScoreNumber setFrame:CGRectMake(bestScore.frame.origin.x+bestScore.frame.size.width+10, bestScore.frame.origin.y, 100*startiPad, 75)];
	[menu setFrame:CGRectMake(menu.frame.origin.x, bestScore.frame.origin.y+bestScore.frame.size.height+10, menu.frame.size.width, menu.frame.size.height)];
	[replay setFrame:CGRectMake(menu.frame.origin.x-75-15, menu.frame.origin.y, replay.frame.size.width, replay.frame.size.height)];
	[rate setFrame:CGRectMake(menu.frame.origin.x+75+15, menu.frame.origin.y, rate.frame.size.width, rate.frame.size.height)];
	[share setFrame:CGRectMake(menu.frame.origin.x+45, menu.frame.origin.y+menu.frame.size.height, share.frame.size.width, share.frame.size.height)];
	[gameCenter setFrame:CGRectMake(menu.frame.origin.x-45, menu.frame.origin.y+menu.frame.size.height, gameCenter.frame.size.width, gameCenter.frame.size.height)];
	
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

#pragma mark - Buttons

-(void)shareButton:(UIButton *)button {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"shareTime" object:self];
}

-(void)gameCenterButton:(UIButton *)button {
	
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Game Center Not Logged In"
														  message:@"Please login for Game Center use"
														 delegate:nil
												cancelButtonTitle:@"Ok"
												otherButtonTitles:nil];
		[message show];
	}
	else {
		GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
		if (gameCenterController != nil) {
			gameCenterController.gameCenterDelegate = self;
			gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
			UIViewController *vc = self.view.window.rootViewController;
			[vc presentViewController: gameCenterController animated: YES completion:nil];
		}
	}
	
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
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
	gameEnded = NO;
	
	[self removeElements];
	
//	[self.view presentScene:nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"GameOverNotification" object:self];
}


-(void)restartButton:(UIButton *)button {
	
	gameEnded = NO;
	triggered = 0;
	gameOver = NO;
	gameStarted = NO;
	gameTime = 0;
	
	[self removeElements];
	
//	[self.view presentScene:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"showScene" object:self];
}

-(void)becomeActive {
	SKAction *pauseTimer= [SKAction sequence:@[
											   [SKAction performSelector:@selector(delayedUnpause) onTarget:self]
											   ]];
	[self runAction:pauseTimer withKey:@"pauseTimer"];
}

-(void)delayedUnpause {
	self.scene.paused = YES;
	
}

#pragma mark - Pause Menu Interface

-(void)pauseButton {
	self.scene.paused = YES;
	[self createPauseMenuInterface];
}

-(void)createPauseMenuInterface {
	
	pauseBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	pauseBackground.image = [UIImage imageNamed:@"black_overlay.png"];
	pauseBackground.alpha = 0.75;
	[self.view addSubview:pauseBackground];
	
	bigPauseImage = [[UIImageView alloc] initWithFrame:CGRectMake(75, 75, screenWidth-150, screenWidth-110)];
	bigPauseImage.image = [UIImage imageNamed:@"pause_icon.png"];
	[self.view addSubview:bigPauseImage];
	
	pauseContinue = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pauseContinue addTarget:self action:@selector(removePauseMenuInterface) forControlEvents:UIControlEventTouchUpInside];
	[pauseContinue setBackgroundImage:[UIImage imageNamed:@"pause_resume.png"] forState:UIControlStateNormal];
	pauseContinue.frame = CGRectMake(bigPauseImage.frame.origin.x+(bigPauseImage.frame.size.width/2)-((75*startiPad)/2), bigPauseImage.frame.origin.y+bigPauseImage.frame.size.height+(40*startiPad), 75.0*startiPad, 75.0*startiPad);
	pauseContinue.alpha = .5;
	pauseContinue.enabled = NO;
	[self.view addSubview:pauseContinue];
	
	pauseRestart = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pauseRestart addTarget:self action:@selector(pauseRestart) forControlEvents:UIControlEventTouchUpInside];
	[pauseRestart setBackgroundImage:[UIImage imageNamed:@"pause_restart.png"] forState:UIControlStateNormal];
	pauseRestart.frame = CGRectMake(pauseContinue.frame.origin.x-(15*startiPad)-(75*startiPad), pauseContinue.frame.origin.y, 75.0*startiPad, 75.0*startiPad);
	[self.view addSubview:pauseRestart];
	
	pauseExit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pauseExit addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
	[pauseExit setBackgroundImage:[UIImage imageNamed:@"pause_exit.png"] forState:UIControlStateNormal];
	pauseExit.frame = CGRectMake(pauseContinue.frame.origin.x+(15*startiPad)+(75*startiPad), pauseContinue.frame.origin.y, 75.0*startiPad, 75.0*startiPad);
	[self.view addSubview:pauseExit];
	
	
	[self performSelector:@selector(showResume) withObject:self afterDelay:1];
}

-(void)showResume {
	[UIView animateWithDuration:0.75
						  delay:0.5
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^ {
		 pauseContinue.alpha = 1;
	}
	completion:^(BOOL finished) {
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
	self.scene.paused = NO;
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
}

-(void)start {
	self.scene.paused = NO;
	
	gameTime = 0;
	score.text = @"0:00";
	[tapToStart removeFromSuperview];
	gameStarted = YES;
	
	// Start ball moving
	[ball.physicsBody applyImpulse:CGVectorMake(25*speediPad, 25*speediPad)];
	
	// Start timer for score
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}

-(void)timer:(NSTimer *)timer {
	if (!gameOver && !self.view.scene.paused) {
		minutesTimer = gameTime/60;
		secondsTimer = gameTime-(minutesTimer * 60);
		
		gameTime = gameTime + 1;
		// Minutes:Seconds
		score.text = [NSString stringWithFormat:@"%01d:%02d", minutesTimer, secondsTimer];
	}
}

#pragma mark - Sounds

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
		NSLog(@"***Goal***");
	}
}

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
		NSLog(@"***Bouncing***");
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
		NSLog(@"***Explosion***");
	}
}


#pragma mark - Spawning Methods

-(void)spawn {
	int i = arc4random() % 75;
	if (i == 1 && !gemSpawned) {
		[self spawnGem];
	}
}

-(void)spawnGem {
	
	int gemSize = 25 * startiPad;
	
	gemSprite = [SKSpriteNode spriteNodeWithImageNamed:@"gem.png"];
	gemSprite.size = CGSizeMake(gemSize, gemSize-(4*startiPad));
	gemSprite.position = [self chooseLocationGem];
	[self addChild:gemSprite];
	gemSpawned = YES;
	
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



#pragma mark - Game Center

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

-(void)achievementComplete:(NSString *)achievementID percentComplete: (int)percent {
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

