package {

	import flash.display.MovieClip;

	/**
	 * This is the class for the Double Shot PowerUp object.
	 */
	public class DoubleShotPowerUp extends MovieClip {

		/** Speed of each powerup. */
		private var speed: Number;

		/** If this is true, the object is queued up to be destroyed!! */
		public var isDead: Boolean = false;

		/** Radius of the powerup. */
		public var radius: Number = 20;

		/** Lets the game know what kind of powerup has just been picked up. */
		public var selector: int = 1;

		/** Double Shot PowerUp constructor function. */
		public function DoubleShotPowerUp() {
			/** Set coordinates, speed, and radius. */
			x = Math.random() * 550;
			y = -50;
			speed = Math.random() * 3 + 2; // 2 to 5?
			radius *= scaleX;
		}

		/** Update design pattern. */
		public function update(): void {
			// fall
			y += speed;

			/** If it reaches the end of the screen, kill it. */
			if (y > 400) {
				isDead = true;
			}
		}
	}

}