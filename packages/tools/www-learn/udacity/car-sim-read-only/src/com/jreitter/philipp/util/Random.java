package com.jreitter.philipp.util;

public class Random extends java.util.Random
{
	private static final long serialVersionUID = -2440064819342501060L;

	public synchronized double nextGaussian(float m) 
	{
		return(nextGaussian() + m);
	};
	
	public synchronized double nextGaussian(float m, float s) 
	{
		if(s==0.f) return m;
		return(nextGaussian()*s + m);
	};
}
