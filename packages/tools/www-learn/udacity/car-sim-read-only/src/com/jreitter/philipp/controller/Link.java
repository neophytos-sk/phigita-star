package com.jreitter.philipp.controller;

/**
 * Direkt link. input = output
 */
public class Link extends ElementHelper
{
	public Link() 
	{
		super(0);
	}
	
	@Override
	public float update(float dt) 
	{
		value = input;
		return value;
	}
}
