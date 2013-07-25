package com.jreitter.philipp.controller;

/**
 * First order lag Element. ouput = input * 1-e^(-t/T)
 */
public class PT1 implements Element
{
	private float t = 0.f;
	private float time = 0.f;
	private float offset = 0.f;
	private float relative = 0.f;
	private float value = 0.f;
	
	public PT1(float t)
	{
		this.t = t;
	}
	
	@Override
	public float update(float dt) 
	{
		time += dt;
		value = offset + relative * (1.f - (float)Math.exp(-time/t));
		return value;
	}
	
	@Override
	public void value(float s) 
	{
		time = 0.0f;
		relative = relative - s;
		offset = s;
		value = s;
	}
	
	@Override
	public void input(float in) 
	{
		time = 0.0f;
		relative = in - value;
		offset = value;
	}

	@Override
	public float value() 
	{
		return value;
	}
	
	@Override
	public float input() 
	{
		return offset + relative;
	}
}
