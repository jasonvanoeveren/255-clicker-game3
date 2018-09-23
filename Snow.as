package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	/**
	 * This is the class for the Snow object.
	 */
	public class Snow extends MovieClip {

		/** Speed of each snowflake. */
		public var speed: Number;

		/** If this is true, the object is queued up to be destroyed!! */
		public var isDead: Boolean = false;

		/** Radius of the snowflake. */
		public var radius: Number = 51;

		/** Tracks unscored points for the game. */
		public var unscoredPoints: int = 0;

		/**
		 * Snow constructor function.
		 */
		public function Snow() {
			/** Set coordinates, speed, scale, and radius. */
			x = Math.random() * 550;
			y = -50;
			speed = Math.random() * 3 + 2; // 2 to 5?
			scaleX = Math.random() * .2 + .1; // .1 to .3
			scaleY = scaleX;
			radius *= scaleX;
		}

		/** Update design pattern. */
		public function update(): void {
			// fall
			y += speed;

			/** If it reaches bottom of screen, kill it. */
			if (y > 400) {
				isDead = true;
				unscoredPoints += -100;
			}
		}
	}

}