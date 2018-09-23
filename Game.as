package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;

	/**
	 * This is the controller class for the entire Game.
	 */
	public class Game extends MovieClip {

		/** Boolean flag to check if game has started. */
		var startGame: Boolean = false;

		/** Boolean flag to check for game over. */
		var isGameOver: Boolean = false;

		/** Flag to check if game over sound has already played. */
		var gameOverSoundPlayed: Boolean = false;

		/** Checks if the double shot powerup has been picked up. */
		var doubleShotPower: Boolean = false;

		/** Checks if the triple shot powerup has been picked up. */
		var tripleShotPower: Boolean = false;

		/** Checks if the repeated shot powerup has been picked up. */
		var repeatedShotPower: Boolean = false;

		/** Checks for when the difficulty increases. */
		var increaseDifficulty: Boolean = false;

		/** This array should only hold Snow objects. */
		var snowflakes: Array = new Array();

		/** The number frames to wait before spawning the next Snow object. */
		var delaySpawn: int = 0;

		/** The number frames to wait before spawning the next Bullet object. */
		var delayBullets: int = 0;

		/** The number frames to wait before spawning the next powerup object. */
		var delayPowerUps: int = (Math.random() * 240 + 240); // 10 to 20 seconds;

		/** Helps determine which powerup will spawn. */
		var powerSelector: int = 0;

		/** Tracks the score of the game. */
		var score: int = 0;

		/** Tracks score needed to speed up snowflakes. */
		var targetScore: int = 1000;

		/** Increases speed of snowflakes when difficulty increases. */
		private var difficultySpeed: int = 0;

		/** This array holds only Bullet objects. */
		var bullets: Array = new Array();

		/** This array holds only PowerUp objects. */
		var powerUps: Array = new Array();

		/** Instantiates game over screen. */
		var gameOver: GameOver = new GameOver();

		/** Instantiates restart button. */
		var restart: Restart = new Restart();

		/** Instantates title screen. */
		var titleScreen: TitleScreen = new TitleScreen();

		/** Instantiates start button. */
		var startBtn: StartGame = new StartGame();

		/** Instantiates instructions screen. */
		var instructions: Instructions = new Instructions();

		/** Instantiates view instructions button. */
		var viewInstructions: ViewInstructions = new ViewInstructions();

		/** Instantiates background music. */
		var bgMusic: BGMusic = new BGMusic();

		/** Instantiates shoot sound. */
		var shootSound: ShootSound = new ShootSound();

		/** Instantiates hit sound. */
		var hitSound: HitSound = new HitSound();

		/** Instantiates miss sound. */
		var missSound: MissSound = new MissSound();

		/** Instantiates game over sound. */
		var gameOverSound: GameOverSound = new GameOverSound();

		/** Instantiates powerup sound. */
		var powerUpSound: PowerUpSound = new PowerUpSound();

		/**
		 * This is where we setup the game.
		 */
		public function Game() {

			/** Play background music. */
			bgMusic.play();

			/** Start game loop. */
			addEventListener(Event.ENTER_FRAME, gameLoop);

			/** Add all screens and buttons to stage. */
			addChild(gameOver);
			addChild(restart);
			addChild(titleScreen);
			addChild(startBtn);
			addChild(instructions);
			addChild(viewInstructions);

			/** Place coordinates of titlescreen and start button. */
			titleScreen.x = 275;
			titleScreen.y = 150;

			startBtn.x = 275;
			startBtn.y = 250;
			startBtn.addEventListener(MouseEvent.CLICK, startClick);

			viewInstructions.x = 290;
			viewInstructions.y = 350;
			viewInstructions.addEventListener(MouseEvent.CLICK, instructionsClick);

			/** Set visibility for unneeded movie clips. */
			gameOver.visible = false;
			restart.visible = false;
			scoreboard.visible = false;
			player.visible = false;
			instructions.visible = false;

		} // ends Game

		/**
		 * This event-handler is called every time a new frame is drawn.
		 * It's our game loop!
		 * @param e The Event that triggered this event-handler.
		 */
		private function gameLoop(e: Event): void {

			/** If start button is clicked, start the game! */
			if (startGame == true) {
				titleScreen.visible = false;
				instructions.visible = false;
				startBtn.visible = false;
				startBtn.removeEventListener(MouseEvent.CLICK, startClick);

				stage.addEventListener(MouseEvent.MOUSE_DOWN, handleClick);

				scoreboard.visible = true;
				player.visible = true;

				spawnSnow();

				spawnPowerUps();

				player.update();

				updateSnow();

				updateBullets();

				updatePowerUps();
			}

			collisionDetection();

			/** Set losing condition once score is less than 0. */
			if (score < 0) {
				isGameOver = true;
			}

			gameOverCheck();

			//Update Scoreboard.
			scoreboard.text = "SCORE: " + score;

		} // ends gameLoop

		/**
		 * This event-handler is called everytime the left mouse button is down.
		 * The shots that are fired from the player is based on what powerup (if any) they are holding.
		 * @param e The MouseEvent that triggered this event-handler.
		 */
		private function handleClick(e: MouseEvent): void {
			if (doubleShotPower == true) {
				doubleShot();

				setTimeout(function () {
					doubleShotPower = false
				}, 10000);
			} else if (tripleShotPower == true) {
				tripleShot();

				setTimeout(function () {
					tripleShotPower = false
				}, 10000);
			} else if (repeatedShotPower == true) {
				stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame);
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);

				setTimeout(function () {
					repeatedShotPower = false
					stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrame);
					stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
				}, 10000);
			} else {
				spawnBullet();
			}
		} // ends handleClick

		/** Used only for the repeated shot powerup.
		 * Ensures that every frame will run this function.
		 */
		private function onStageEnterFrame(e: Event): void {
			repeatedShot();
		} // ends onStageEnterFrame

		/** The default shot-type.
		 * Spawns a bullet everytime the user clicks the left mouse button.
		 */
		private function spawnBullet(): void {
			shootSound.play();
			var b: Bullet = new Bullet(player);
			addChild(b);
			bullets.push(b);
		} // ends spawnBullet

		/** The double shot power up function.
		 * Spawns two bullets simultaneously next to each other when the user clicks the left mouse button.
		 */
		private function doubleShot(): void {
			shootSound.play();

			var b: Bullet = new Bullet(player);
			b.x -= 15;
			addChild(b);
			bullets.push(b);

			var b2: Bullet = new Bullet(player);
			b2.x += 15;
			addChild(b2);
			bullets.push(b2);
		} // ends doubleShot

		/** The triple shot power up function.
		 * Spawns three bullets in an arc formation.
		 */
		private function tripleShot(): void {
			shootSound.play();

			var b: Bullet = new Bullet(player);
			addChild(b);
			bullets.push(b);

			var b2: Bullet = new Bullet(player);
			addChild(b2);
			bullets.push(b2);
			b2.angle = (player.rotation - 135) * Math.PI / 180;
			b2.velocityX = b2.SPEED * Math.cos(b2.angle);
			b2.velocityY = b2.SPEED * Math.sin(b2.angle);

			var b3: Bullet = new Bullet(player);
			addChild(b3);
			bullets.push(b3);
			b3.angle = (player.rotation - 45) * Math.PI / 180;
			b3.velocityX = b3.SPEED * Math.cos(b3.angle);
			b3.velocityY = b3.SPEED * Math.sin(b3.angle);
		} // ends tripleShot

		/** The repeated shot function.
		 * Spawns repeated bullets when the user holds down the left mouse button.
		 */
		private function repeatedShot(): void {
			delayBullets--;
			if (delayBullets <= 0) {
				shootSound.play();
				var b: Bullet = new Bullet(player);
				addChild(b);
				bullets.push(b);
				delayBullets = 3;
			}
		} // ends repeatedShot

		/**
		 * This event-handler is called when the repeated shot powerup is active and the user has released the left mouse button.
		 * It removes the onStageEnterFrame and onStageMouseUp event handlers from the stage.
		 * This allows the bullets to stop firing when the user has unclicked the left mouse button.
		 * @param e The MouseEvent that triggered this event-handler.
		 */
		private function onStageMouseUp(e: MouseEvent): void {
			stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);

			delaySpawn = 0;

		} // end onStageMouseUp

		/**
		 * Decrements the countdown timer, when it hits 0, it spawns a snowflake.
		 */
		private function spawnSnow(): void {
			// spawn snow:
			delaySpawn--;
			if (delaySpawn <= 0) {
				var s: Snow = new Snow();
				addChild(s);
				s.speed += difficultySpeed;
				snowflakes.push(s);
				delaySpawn = (int)(Math.random() * 10);
			}
		} // ends spawnSnow

		/**
		 * Decrements the delayPowerUps countdown timer.  When it hits 0, it spawns a random powerup.
		 */
		private function spawnPowerUps(): void {
			// spawn powerups:
			delayPowerUps--;
			if (delayPowerUps <= 0 && doubleShotPower == false && tripleShotPower == false && repeatedShotPower == false) {
				// This selects a random number between 1 and 4 to help determine which powerup gets spawned next.
				powerSelector = (Math.random() * 3 + 1)
				if (powerSelector >= 1 && powerSelector < 2) {
					var d: DoubleShotPowerUp = new DoubleShotPowerUp();
					addChild(d);
					powerUps.push(d);
				} else if (powerSelector >= 2 && powerSelector < 3) {
					var t: TripleShotPowerUp = new TripleShotPowerUp();
					addChild(t);
					powerUps.push(t);
				} else if (powerSelector >= 3 && powerSelector < 4) {
					var r: RepeatedShotPowerUp = new RepeatedShotPowerUp();
					addChild(r);
					powerUps.push(r);
				}
				delayPowerUps = (Math.random() * 240 + 240); // spawn every 10 to 20 seconds.
			}
		} // ends spawnPowerUps

		/**
		 * Updates snow for every frame.
		 */
		private function updateSnow(): void {
			// update everything:
			for (var i: int = snowflakes.length - 1; i >= 0; i--) {
				snowflakes[i].update(); // The update design pattern.

				/** Adds points to the score depending on if the player hit or missed a snowflake. */
				if (snowflakes[i].unscoredPoints > 0 || snowflakes[i].unscoredPoints < 0) {
					score += snowflakes[i].unscoredPoints;
					snowflakes[i].unscoredPoints = 0;
				}

				/** Plays miss sound when snowflakes fall off the screen. */
				if (snowflakes[i].y > 400) {
					missSound.play();
				}

				// Increases speed of snow every 1000 points.
				increaseSpeedCheck();

				// If difficulty increases, increase speed.
				if (increaseDifficulty == true) {
					difficultySpeed += .5;
					snowflakes[i].speed += difficultySpeed;
					targetScore += 1000;
					increaseDifficulty = false;
				}

				/** If snowflake is dead, remove it. */
				if (snowflakes[i].isDead) {
					// remove it!!

					// 1. remove the object from the scene-graph
					removeChild(snowflakes[i]);

					// 2. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					snowflakes.splice(i, 1);
				}
			} // for loop updating snow
		} // ends updateSnow

		/**
		 * Updates bullets for every frame.
		 */
		private function updateBullets(): void {
			// update everything:
			for (var i: int = bullets.length - 1; i >= 0; i--) {
				bullets[i].update(); // Update design pattern.

				/** If bullet is dead, remove it. */
				if (bullets[i].isDead) {
					// remove it!!

					// 1. remove the object from the scene-graph
					removeChild(bullets[i]);

					// 2. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					bullets.splice(i, 1);
				}
			} // for loop updating bullets
		} // ends updateBullets

		/**
		 * Updates powerups for every frame.
		 */
		private function updatePowerUps(): void {
			// update everything:
			for (var i: int = powerUps.length - 1; i >= 0; i--) {
				powerUps[i].update(); // Update design pattern.

				/** If powerup is dead, remove it. */
				if (powerUps[i].isDead) {
					// remove it!!

					// 1. remove the object from the scene-graph
					removeChild(powerUps[i]);

					// 2. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					powerUps.splice(i, 1);
				} // ends if statement
			} // ends for loop
		} // ends updatePowerUps

		/** 
		 * Sets boolean flag to true when it's time for the difficulty to increase.
		 */
		private function increaseSpeedCheck() {

			for (var i = snowflakes.length - 1; i >= 0; i--) {

				if (score >= targetScore) {
					increaseDifficulty = true;
				}

			}
		} // ends increaseSpeedCheck

		/**
		 * Detects collision for snowflakes, bullets, and powerups.
		 */
		private function collisionDetection(): void {
			for (var i: int = 0; i < snowflakes.length; i++) {
				for (var j: int = 0; j < bullets.length; j++) {

					var dx: Number = snowflakes[i].x - bullets[j].x;
					var dy: Number = snowflakes[i].y - bullets[j].y;
					var dis: Number = Math.sqrt(dx * dx + dy * dy);

					/** If a bullet and snowflake hit, remove them. */
					if (dis < snowflakes[i].radius + bullets[j].radius) {
						// collision!
						hitSound.play();
						snowflakes[i].isDead = true;
						bullets[j].isDead = true;

						snowflakes[i].unscoredPoints += 100;
					} // ends if statement
				} // ends for loop
			} // for loop

			for (var k: int = 0; k < bullets.length; k++) {
				for (var l: int = 0; l < powerUps.length; l++) {
					var dx2: Number = powerUps[l].x - bullets[k].x;
					var dy2: Number = powerUps[l].y - bullets[k].y;
					var dis2: Number = Math.sqrt(dx2 * dx2 + dy2 * dy2);

					/** If a bullet and powerup hit, remove them and activate powerup. */
					if (dis2 < powerUps[l].radius + bullets[k].radius) {
						// collision!
						powerUpSound.play();
						powerUps[l].isDead = true;
						bullets[k].isDead = true;

						if (powerUps[l].selector == 1) {
							doubleShotPower = true;
						} else if (powerUps[l].selector == 2) {
							tripleShotPower = true;
						} else if (powerUps[l].selector == 3) {
							repeatedShotPower = true;
						}
					} // ends if statement
				} // ends for loop
			} // ends for loop
		} // ends collisionDetection

		/**
		 * Checks for a game over (when score is less than zero).
		 * Removes everything from the scene and displays game over screen and reset button.
		 */
		private function gameOverCheck(): void {
			if (isGameOver == true) {
				if (gameOverSoundPlayed == false) {
					gameOverSound.play();
					gameOverSoundPlayed = true;
				}

				for (var i = snowflakes.length - 1; i >= 0; i--) {
					removeChild(snowflakes[i]);
					snowflakes.splice(i, 1);
				}

				for (var j = bullets.length - 1; j >= 0; j--) {
					removeChild(bullets[j]);
					bullets.splice(j, 1);
				}

				score = 0;

				gameOver.visible = true;
				restart.visible = true;

				gameOver.x = 275;
				gameOver.y = 150;

				restart.x = 285;
				restart.y = 250;
				restart.addEventListener(MouseEvent.CLICK, restartClick);
			} // ends if statement
		} // ends gameOverCheck

		/**
		 * This event-handler is called when the restart button is clicked.
		 * It turns off the visibility of the gameover screen and restart button.
		 * It also restarts the game!
		 * @param e The MouseEvent that triggered this event-handler.
		 */
		private function restartClick(e: MouseEvent): void {

			gameOver.visible = false;
			restart.visible = false;
			restart.removeEventListener(MouseEvent.CLICK, restartClick);

			isGameOver = false;
			gameOverSoundPlayed = false;
		} // ends restartClick

		/**
		 * This event-handler is called when the start button is clicked on the title screen.
		 * It starts the game!
		 * @param e The MouseEvent that triggered this event-handler.
		 */
		private function startClick(e: MouseEvent): void {
			startGame = true;
		} // ends startClick

		private function instructionsClick(e: MouseEvent): void {
			titleScreen.visible = false;
			viewInstructions.visible = false;
			instructions.visible = true;

			viewInstructions.removeEventListener(MouseEvent.CLICK, instructionsClick);

			instructions.x = 275;
			instructions.y = 180;

			startBtn.y = 350;
		}

	} // class Game
} // package