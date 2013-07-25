package com.jreitter.philipp.udacity.simulator;

public class BicycleModel 
{
	//when i did the exact same calculation in python it would just drift apart from the java calculation
	public static float[] getPos(float x, float y, float angle, float steer, float speed, float dt, float length)
	{
     	float tan = (float)Math.tan(steer);
		float dist = speed*dt;
        float b = (dist/length) * tan;
        
        if(Math.abs(b) >= 0.001)
        {
            float R = length/tan;
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
        
        return new float[]{x, y, angle};
	}
}
