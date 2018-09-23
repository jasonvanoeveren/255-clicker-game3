package {

	import flash.display.MovieClip;

	/**
	 * This is the class for the Bullet object.
	 */
	public class Bullet extends MovieClip {

		/** Speed of the bullet. */
		public const SPEED: Number = 10;

		/** Velocity of the bullet. */
		public var velocityX: Number = 0;
		public var velocityY: Number = -10;

		/** Checks for if the bullet should be deleted. */
		public var isDead: Boolean = false;

		/** Radius of the bullet. */
		public var radius: Number = 10;

		/** Angle of the bullet. */
		public var angle: Number = 0;

		/**
		 * Bullet constructor function.
		 */
		public function Bullet(p: Player) {
			/** Set coordinates of bullet to player coordinates. */
			x = p.x;
			y = p.y;

			/** Set angle to player rotation. */
			angle = (p.rotation - 90) * Math.PI / 180;

			/** Set velocity according to speed and angle of the bullet. */
			velocityX = SPEED * Math.cos(angle);
			velocityY = SPEED * Math.sin(angle);

		} // ends Bullet

		/**
		 * The update design pattern for the bullet.
		 */
		public function update(): void {

			/** Moves bullet according to velocity. */
			x += velocityX;
			y += velocityY;

			/** If it moves off the stage, mark it as dead. */
			if (!stage || y < 0 || x < 0 || x > stage.stageWidth || y > stage.stageHeight) isDead = true;
		} // ends update

	} // ends class
} // ends package