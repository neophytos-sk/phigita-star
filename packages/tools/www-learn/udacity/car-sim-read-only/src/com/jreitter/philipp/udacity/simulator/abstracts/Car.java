package com.jreitter.philipp.udacity.simulator.abstracts;

public interface Car extends SimulationObject
{
	public float getX();
	public float getY();
	public float getAngle();
	public float getSteer();
	public float getSpeed();
	public CarController getController();
}
