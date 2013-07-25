package com.jreitter.philipp.udacity.simulator;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.LinkedList;
import java.util.List;

public class WallMap 
{
	private List<Rectangle> rects;
	
	public WallMap()
	{
		rects = new LinkedList<Rectangle>();
	}
	
	public void loadFromFile(File f) throws Exception
	{
		BufferedReader in = new BufferedReader(new FileReader(f));
	
		String line = null;
		while((line=in.readLine())!=null)
		{
			String[] args = line.split(",");
			switch(args[0].charAt(0))
			{
			case 'r':
				rects.add( new Rectangle(Integer.parseInt(args[1]),
						Integer.parseInt(args[2]),
						Integer.parseInt(args[3]),
						Integer.parseInt(args[4])));
				break;
			}
		}
	
		in.close();
	}
	
	public boolean isInsideWall(int x, int y)
	{
		for(Rectangle r : rects)
		{
			if(r.contains(x, y))
			{
				return true;
			}
		}
		return false;
	}
	
	public void paint(Graphics2D g)
	{
		g.setColor(Color.DARK_GRAY);
		for(Rectangle r : rects)
		{
			g.fill(r);
		}
	}
}
