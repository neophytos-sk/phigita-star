package com.jreitter.philipp.controller;

/**
 * Second order lag, build out of 2 first order lags in series.
 */
public class PT2 implements Element
{
	private PT1 pt1;
	private PT1 pt2;
	
	public PT2(float T1, float T2)
	{
		pt1 = new PT1(T1);
		pt2 = new PT1(T2);
	}
	
	public PT2(float T1)
	{
		this(T1,T1);
	}
	
	@Override
	public float update(float dt) 
	{
		pt2.input(pt1.update(dt));
		return pt2.update(dt);
	}
	
	@Override
	public void input(float in) 
	{
		pt1.input(in);
	}
	
	@Override
	public void value(float s)
	{
		pt1.value(s);
		pt2.value(s);
	}

	@Override
	public float value() 
	{
		return pt2.value();
	}
	
	@Override
	public float input() 
	{
		return pt1.input();
	}
}
