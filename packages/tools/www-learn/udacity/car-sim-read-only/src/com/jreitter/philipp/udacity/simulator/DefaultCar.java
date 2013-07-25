package com.jreitter.philipp.udacity.simulator;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.io.File;
import java.util.Properties;

import javax.imageio.ImageIO;

import com.jreitter.philipp.controller.Element;
import com.jreitter.philipp.controller.Link;
import com.jreitter.philipp.controller.PT1;
import com.jreitter.philipp.udacity.simulator.abstracts.Car;
import com.jreitter.philipp.udacity.simulator.abstracts.CarController;
import com.jreitter.philipp.udacity.simulator.abstracts.Configurable;
import com.jreitter.philipp.util.Random;

public class DefaultCar implements Car, Configurable
{
	private Image carImage;
	
	/**
	 * CarController class is used for data encapsulation.
	 * While user gets noisy values from the controller, 
	 * the simulation can get real values from Car class.
	 * As long as we don't give the Car to user we are fine.
	 * 
	 * thats deprecated, since i want real the focus is no more on 
	 * pure localization, i want real values for path planning
	 */
	public class DefaultCarController implements CarController
	{
		private DefaultCarController()
		{
		}
		
		public float getSpeed(){return retSpeed;}
		public float getGyro(){return retGyro;}
		
		public void setSpeed(float s)
		{
			if(s>1.f)s=1.f;
			else if(s<-1.f)s=-1.f;
		
			desiredSpeed = s*maxSpeed;
		}

		public void setSteer(float s)
		{
			if(s>1.f)s=1.f;
			else if(s<-1.f)s=-1.f;
		
			desiredSteer = s*maxSteer;
		}
		
		public float[] getPos()
		{
			return new float[]{x,y};
		}
		
		public float getAngle()
		{
			return angle;
		}
	}
	
	//Configuration Variables
	private float speedSensorError = 0.f;
	private float gyroSensorError = 0.f;
	
	private float steerError = 0.f;
	private float speedError = 0.f;
	
	private float maxSpeed = 0.f;
	private float maxSteer = 0.f;

	private float randomTime = 0.5f;
	
	private float carLength = 100.f;
	
	//Other suff
	private Random r;
	private CarController controller;

	//Car State variables
	private float x;
	private float y;
	private float startX;
	private float startY;
	private float startA;
	private float angle;
	
	private Element speed;
	private Element steer;
	
	private float desiredSteer;
	private float desiredSpeed;
	
	//Randomized Values 
	private float retSpeed;
	private float retGyro;
	
	private float time;
	
	//Constructor
	public DefaultCar( )
	{
		controller = new DefaultCarController();
		r = new Random( );
		
		try
		{
			if( getClass().getResource("/img/car.png") == null )
				carImage = ImageIO.read(new File("img/car.png")); //really fast hotfix
			else
				carImage = ImageIO.read(getClass().getResource("/img/car.png"));
		}catch(Exception e)
		{
			e.printStackTrace();
			System.err.println("Couldn't load img/car.png");
		}
		time = 0;
	}
	
	//Getter&Setter
	public float getX(){return x;}
	public float getY(){return y;}
	public float getAngle(){return angle;}
	public float getSteer(){return steer.value();}
	public float getSpeed(){return speed.value();}
	public CarController getController(){return controller;};
	
	//Update Method
	public void update(float dt)
	{
		time += dt;
		if( time > randomTime )
		{
			speed.input((float)r.nextGaussian(desiredSpeed, speedError*speed.value()));
			steer.input((float)r.nextGaussian(desiredSteer, steerError*steer.value()));
			time = 0;
		}
			
		steer.update(dt);
		speed.update(dt);

		float dAngle = steer.value()*(speed.value()/maxSpeed);
		retSpeed = (float)r.nextGaussian(speed.value(), speedSensorError);
		
		retGyro = (float)r.nextGaussian(dAngle, gyroSensorError);
		
		float tan = (float)Math.tan(steer.value());
		float dist = speed.value()*dt;
        float b = (dist/carLength) * tan;
        
        if(Math.abs(b) >= 0.001)
        {
            float R = carLength/tan;
            float cx = (x - (float)Math.sin(angle) * R);
            float cy = (y + (float)Math.cos(angle) * R);
            x = (cx + (float)Math.sin(angle+b) * R);
            y = (cy - (float)Math.cos(angle+b) * R);
            angle = (float)((angle+b)%(2.*Math.PI));
        }
        else
        {
            x = (float)(x + dist * Math.cos(angle));
            y = (float)(y + dist * Math.sin(angle));
        }
        
	}

	@Override
	public void loadProperties(Properties p) 
	{
		speedSensorError = Float.parseFloat(p.getProperty("carSpeedSensorError", "0"));
		gyroSensorError  = Float.parseFloat(p.getProperty("carGyroSensorError" , "0"));
		steerError 		 = Float.parseFloat(p.getProperty("carSteerError"	   , "0"));
		speedError 		 = Float.parseFloat(p.getProperty("carSpeedError"	   , "0"));
		maxSpeed 		 = Float.parseFloat(p.getProperty("carMaxSpeed"		   , "0"));
		maxSteer 		 = Float.parseFloat(p.getProperty("carMaxSteer"		   , "0"));	
		startX 			 = Float.parseFloat(p.getProperty("carStartX"		   , "200"));
		startY			 = Float.parseFloat(p.getProperty("carStartY"		   , "200"));	
		startA			 = Float.parseFloat(p.getProperty("carStartAngle"	   , "0"));	
		randomTime		 = Float.parseFloat(p.getProperty("errorUpdateTime"	   , "0.5"));	
		carLength		 = Float.parseFloat(p.getProperty("carLength"	   	   , "100"));	
		
		float T = Float.parseFloat(p.getProperty("carSpeedT", "0"));
		if(T > 0.f) speed = new PT1(T);
		else speed = new Link();
		
		T = Float.parseFloat(p.getProperty("carSteerT", "0"));
		if(T > 0.f) steer = new PT1(T);
		else steer = new Link();
	}

	@Override
	public void onPaint(Graphics2D g) 
	{
	    Graphics2D gg = (Graphics2D) g.create();
	    gg.setColor(Color.BLUE);
	    gg.rotate(angle+Math.PI/2, x, y);
	    gg.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	    gg.drawImage(carImage, (int)(x-22.5), (int)(y-50), null);
	    gg.dispose();
	}

	@Override
	public void init() 
	{
		x = startX;
		y = startY;
		angle = startA;	
		time = randomTime;
		speed.input(0); 
		speed.value(0);
		steer.input(0); 
		steer.value(0);
	}
	
}
