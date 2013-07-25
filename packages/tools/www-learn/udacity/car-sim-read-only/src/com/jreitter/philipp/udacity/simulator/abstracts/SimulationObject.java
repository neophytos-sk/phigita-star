package com.jreitter.philipp.udacity.simulator.abstracts;

import java.awt.Graphics2D;

public interface SimulationObject extends Configurable
{
	public void init();
	public void update(float dt);
	public void onPaint(Graphics2D g);
}
