package com.jreitter.philipp.controller;

/**
 * Integral Element. output = Integral of input
 */
public class I extends ElementHelper
{
	private float ki = 0.f;
	
	public I(float ki) 
	{
		super(0);
		this.ki = ki;
	}
	
	@Override
	public float update(float dt) 
	{
		value += input * ki * dt;
		return value;
	}
}
