package com.jreitter.philipp.udacity.simulator;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;

import com.jreitter.philipp.udacity.simulator.abstracts.Car;
import com.jreitter.philipp.udacity.simulator.abstracts.Configurable;
import com.jreitter.philipp.udacity.simulator.abstracts.SimulationListener;
import com.jreitter.philipp.udacity.simulator.abstracts.SimulationObject;
import com.jreitter.philipp.udacity.simulator.view.SimulationPanel;

public class Simulation implements Runnable, Iterable<SimulationObject>
{
	private Car car;
	private World world;
	private boolean run = false;
	private SimulationListener listener;
	private int timeDelay = 20;
	private Thread currentThread;
	
	private SimulationPanel visual;
	private List<SimulationObject> objects;
	
	public Simulation()
	{
		objects = new LinkedList<SimulationObject>();
		
		SensorArray sensors = new SensorArray(this);
		DefaultCar  car     = new DefaultCar();
		World       world   = new World();

		objects.add(world);
		objects.add(car);
		objects.add(sensors);
		
		this.car   = car;
		this.world = world;
	}
	
	//Getter / Setter
	public Car getCar(){return car;}
	public World getWorld(){return world;}
	public SimulationListener getListener(){return listener;}
	public int getTimeDelay(){return timeDelay;}
	
	public void setListener(SimulationListener l){listener = l;}
	public synchronized void setRunning(boolean b){run = b;}
	public synchronized boolean isRunning(){return run;} 
	public void setPanel(SimulationPanel p){visual = p;}
	public void setTimeDelay(int i){timeDelay = i;}
	
	public boolean start()
	{
		if(currentThread == null)
		{
			currentThread = new Thread(this);
			currentThread.start();
			return true;
		}
		return false;
	}
	
	public void loadConfig(String path) throws FileNotFoundException, IOException
	{
		//Forced use of my Configurable interface, FUCK YEA!
		Properties p = new Properties();
		p.load(new FileReader(path));
		for( Configurable c : objects )
			c.loadProperties(p);
	}
	
	@Override
	public void run()
	{
		if( listener == null )
			return;

		for(SimulationObject o : objects)
			o.init();
		
		listener.init(car.getController(), world);

		setRunning(true);
		while(isRunning())
		{
			long time = System.currentTimeMillis();
			
			listener.onUpdate(0.02f);
			
			for(SimulationObject o : objects)
				o.update(0.02f);
			
			if(visual!=null)
			{
				visual.repaint();
				visual.revalidate();
			}
			
			try {
				time = System.currentTimeMillis()-time;
				time = timeDelay - time;
				if(time > 0)
					Thread.sleep(time); //bad, fix it
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
		currentThread = null;
	}

	@Override
	public Iterator<SimulationObject> iterator() {
		return objects.iterator();
	}
	
	public static boolean runa = true;
	
	@SuppressWarnings("deprecation")
	public static void main(String[] args) throws InterruptedException, IOException
	{
		
		Thread d = new Thread()
		{ 
			long start = 0;
			public void run()
			{
				while(runa)
				{
					if( start == 0) start = System.currentTimeMillis();
					System.out.println(System.currentTimeMillis()-start);
					try {
						Thread.sleep(10);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
		};
		d.run();
		
		while( System.in.read() == -1) Thread.sleep(10);
		
		runa = false;
		d.stop(); 
	}
}
