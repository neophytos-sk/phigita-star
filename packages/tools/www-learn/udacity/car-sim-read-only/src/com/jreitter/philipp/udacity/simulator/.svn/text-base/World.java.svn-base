package com.jreitter.philipp.udacity.simulator;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.Properties;

import com.jreitter.philipp.udacity.simulator.abstracts.Background;
import com.jreitter.philipp.udacity.simulator.abstracts.Configurable;
import com.jreitter.philipp.udacity.simulator.abstracts.SimulationObject;
import com.jreitter.philipp.util.Random;

public class World implements Configurable, SimulationObject, Background
{	
	//Why not 1 global static object?
	private Random r;
	
	private int width;
	private int height;
	
	private int[][] background;
	private int bgSpacing;
	
	private BufferedImage bgImage;
	
	private WallMap wallMap;
	
	public World()
	{
		r = new Random();
		wallMap = new WallMap();
	}	
	
	public int getSpacint(){return bgSpacing;}
	public int getHeight(){return height;}	
	public int getWidth(){return width;}
	public boolean isInsideWall(int x, int y){ return wallMap.isInsideWall(x, y);}
	
	@Override
	public void loadProperties(Properties p) 
	{
		bgSpacing =  Integer.parseInt(p.getProperty("worldSpacing","5"));
		width = Integer.parseInt(p.getProperty("worldWidth","800"));
		height = Integer.parseInt(p.getProperty("worldHeight","600"));
		
		if( width%bgSpacing != 0 || 
			height%bgSpacing != 0 )
			throw new IllegalArgumentException("Height/Width should be devidable by spacing!");
		
		background = new int[width][height];
		
		try
		{
		String mapFile = p.getProperty("mapFile", null);
		if(mapFile!=null)
			wallMap.loadFromFile(new File(mapFile.replace("\"", "")));
		}catch(Exception e)
		{
			System.err.println("Error loading Map File!");
			e.printStackTrace();
		}
	}
	private void bufferBackground()
	{
		bgImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
		Graphics g = bgImage.createGraphics();
		for( int x = 0; x <= width; x+=bgSpacing)
		{
			g.setColor(Color.black);
			g.drawLine(x, 0, x, height);
			for( int y = 0; y < height; y+=bgSpacing)
			{
				g.setColor(Color.black);
				g.drawLine(0, y, width, y);
				
				if(getColorAtPixel(x, y)==0)
					g.setColor(Color.white);
				else
					g.setColor(Color.gray);

				g.fillRect(x+1, y, bgSpacing-1, bgSpacing);
				
			}
		}
		g.setColor(Color.black);
		g.drawLine(width-1, 0, width-1, height-1);
		g.drawLine(0, height-1, width-1, height-1);
		
		g.dispose();
	}
	
	private void randomBackground()
	{
		for( int x = 0; x < width; x++)
		{
			for( int y = 0; y < height; y++)
			{
				background[x][y] = r.nextInt(2);
			}
		}
	}

	@Override
	public void onPaint(Graphics2D g) 
	{
		g.drawImage(bgImage, 0, 0, null);
		wallMap.paint(g);
	}

	@Override
	public void init() 
	{
		randomBackground();
		bufferBackground();
	}

	@Override
	public void update(float dt) 
	{
		
	}

	@Override
	public int getColorAt( int x, int y )
	{
		if( x >= background.length || x < 0 ||
				y < 0 || y >= background[0].length )
			return -1;
			
		return background[x][y];
	}
	
	@Override
	public int getColorAtPixel(float x, float y) 
	{
		int bx = (int)(x/bgSpacing);
		int by = (int)(y/bgSpacing);
		
		if(bx >= background.length || bx < 0 ||
				by < 0 || by >= background[0].length )
			return -1;

		return(background[bx][by]);
	}
}
