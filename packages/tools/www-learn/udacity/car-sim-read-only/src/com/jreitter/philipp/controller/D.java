package com.jreitter.philipp.controller;

/**
 * Differencial Element. Output = dInput * dT
 */
public class D extends ElementHelper
{
	private float kd = 0.f;
	private float last = 0.f;
	
	public D(float kd) 
	{
		super(0);
		this.kd = kd;
	}
	
	@Override
	public float update(float dt) 
	{
		value = dt*kd*(input - last);
		last = input;
		return value;
	}
	
	@Override
	public void value(float s) 
	{
		super.value(s);
		last = s;
	}
}
