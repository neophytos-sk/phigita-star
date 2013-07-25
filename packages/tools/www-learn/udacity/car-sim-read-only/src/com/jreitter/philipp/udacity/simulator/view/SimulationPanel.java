package com.jreitter.philipp.udacity.simulator.view;

import java.awt.Graphics;
import java.awt.Graphics2D;

import javax.swing.JPanel;

import com.jreitter.philipp.udacity.simulator.Simulation;
import com.jreitter.philipp.udacity.simulator.abstracts.SimulationObject;

public class SimulationPanel extends JPanel
{
	private static final long serialVersionUID = 1L;
	private Simulation simulation;
	
	public SimulationPanel(Simulation s)
	{
		this.simulation = s;
	}
	
	@Override
	public void paint(Graphics g) 
	{
		super.paint(g);
		
		if(simulation.isRunning())
		{
			Graphics2D g2d = (Graphics2D)g;
			for(SimulationObject o : simulation)
				o.onPaint(g2d);
				
			simulation.getListener().onPaint(g2d);
		}
	}
}
