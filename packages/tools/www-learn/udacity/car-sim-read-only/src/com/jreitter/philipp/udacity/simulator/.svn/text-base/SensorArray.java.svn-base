package com.jreitter.philipp.udacity.simulator;

import java.awt.Graphics2D;
import java.util.ArrayList;
import java.util.Properties;

import com.jreitter.philipp.udacity.simulator.abstracts.Car;
import com.jreitter.philipp.udacity.simulator.abstracts.SimulationObject;
import com.jreitter.philipp.util.Random;

public class SensorArray implements SimulationObject
{
	//Why not 1 global static object?
	private Random r;
	
	//Configuration
	private float gpsSensorNoise = 0.f;
	private float cameraImageNoise = 0.f;
	private int gpsUpdate = 0;
	private int cameraUpdate = 0;
	private int scannerUpdate = 0;
	private int scannerRange = 0;
	
	private int c;
	
	private Simulation simulation;
	
	public SensorArray(Simulation s)
	{
		r = new Random();
		this.simulation = s;
	}

	@Override
	public void loadProperties(Properties p) 
	{
		gpsSensorNoise 	 = Float.parseFloat(p.getProperty("gpsSensorNoise"  , "0"));
		cameraImageNoise = Float.parseFloat(p.getProperty("cameraImageNoise", "0"));	
		gpsUpdate = Integer.parseInt(p.getProperty("cameraUpdate","10"));
		cameraUpdate = Integer.parseInt(p.getProperty("gpsSensorUpdate","10"));
		scannerUpdate = Integer.parseInt(p.getProperty("laserScannerUpdate","10"));
		scannerRange = Integer.parseInt(p.getProperty("laserScannerRange","10"));
	}

	public int[][] getCameraImage() 
	{
		Car c = simulation.getCar();
		World w = simulation.getWorld();
				
		int i = w.getColorAtPixel(c.getX(),c.getY());
		if(r.nextFloat()>(1.f-cameraImageNoise)) //cuz [0,1[
		{
			i=(i+1)&1;
		}

		return new int[][]{{i}};
	}
	
	public int[][] getScannerDots()
	{
		ArrayList<Integer[]> dots = new ArrayList<Integer[]>(scannerRange*scannerRange);
		int spacing = simulation.getWorld().getSpacint();
		for(int x = -scannerRange; x < scannerRange; x+=spacing)
		{
			int cx = (int)simulation.getCar().getX();
			for(int y = -scannerRange; y < scannerRange; y+=spacing)
			{
				int cy = (int)simulation.getCar().getY();
				if(simulation.getWorld().isInsideWall(cx+x, cy+y))
					dots.add(new Integer[]{x, y});
			}	
		}

		int[][] res = new int[dots.size()][2];
		for(int i = 0; i < dots.size(); i++)
		{
			res[i][0] = dots.get(i)[0];
			res[i][1] = dots.get(i)[1];
		}
		
		return res;
	}
	
	public float[] getGPSPosition() 
	{
		Car c = simulation.getCar();
		float gx = (float)r.nextGaussian(c.getX(), gpsSensorNoise);
		float gy = (float)r.nextGaussian(c.getY(), gpsSensorNoise);
		return new float[]{gx,gy};
	}

	@Override
	public void onPaint(Graphics2D g) {
		
	}

	@Override
	public void init() 
	{
		c = 0;
	}

	@Override
	public void update(float dt) 
	{
		c++;
		if(c%gpsUpdate==0) 
		{
			simulation.getListener().onGPS(getGPSPosition());
		}
		
		if(c%cameraUpdate==0) 
		{
			simulation.getListener().onCamera(getCameraImage());
		}
		
		if(c%scannerUpdate==0) 
		{
			simulation.getListener().onScanner(getScannerDots());
		}
	}

}
