package {

	import flash.display.MovieClip;

	/**
	 * This is the class for the Player object.
	 */
	public class Player extends MovieClip {

		/**
		 * Player constructor function.
		 */
		public function Player() {

		}

		/** Update design pattern. */
		public function update(): void {
			/** Change angle based on mouse position and rotate player. */
			var tx: Number = parent.mouseX - x;
			var ty: Number = parent.mouseY - y;
			var angle: Number = Math.atan2(ty, tx);
			angle *= 180 / Math.PI;

			rotation = angle + 90;
		}
	}

}