package com.jreitter.philipp.controller;

/**
 * Proportional Element.
 * output = input * kp
 */
public class P extends ElementHelper
{
	private float kp = 0.f;
	
	public P(float kp) 
	{
		super(0);
		this.kp = kp;
	}
	
	@Override
	public float update(float dt) 
	{
		value = input * kp;
		return value;
	}
}
