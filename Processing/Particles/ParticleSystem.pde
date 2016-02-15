class ParticleSystem {
	LinkedList<Particle> particles;

	ParticleSystem() {
		particles = new LinkedList<Particle>();
	}

	void generate(int n, PVector initialPosition) {
		for (int i = 0; i < n; i++) {
			Particle p = new Particle(initialPosition);
			particles.add(p);
		}
	}

	void update(PVector orientationVector) {
		ListIterator li = particles.listIterator();
		while (li.hasNext()) {
			Particle p = (Particle)li.next();
			p.update(orientationVector);
			if(p.isDead()) {
				li.remove();
			}
		}
	}

	void display() {
		for (Particle p : particles) {
			p.display();
		}
		//println("nb shapes: "+particles.size());
	}
}


