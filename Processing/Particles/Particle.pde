class Particle {

	final float partSize = 3;
	PVector velocity;
	PVector position = new PVector(0, 0);
	int lifetime = 255;

	Particle(PVector initialPosition) {
		float a = random(TWO_PI);
		float speed = 2;
		velocity = new PVector(cos(a), sin(a));
		velocity.mult(speed);
		position = initialPosition.get();
		lifetime = (int)random(200, 255);
	}

	boolean isDead() {
		if (lifetime <= 0) {
			return true;
		} else {
			return false;
		}
	}


	public void update(PVector orientationVector) {
		lifetime = max(0, lifetime - 1);
		PVector delta = new PVector(-orientationVector.z, orientationVector.y);
		delta.mult(0.1);
		velocity.add(delta);
		position.add(velocity);
	}

	public void display() {
		float alpha = lifetime;
		rect(position.x - partSize / 2, position.y - partSize / 2, partSize, partSize);
		fill(255, 255, 255, alpha);
	}
}




