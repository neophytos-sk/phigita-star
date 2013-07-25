package com.jreitter.philipp.udacity.simulator.view;

import java.awt.BorderLayout;

import javax.swing.JFrame;

import com.jreitter.philipp.udacity.simulator.Simulation;

public class SimulationFrame extends JFrame
{
	private static final long serialVersionUID = 1L;
	
	private SimulationPanel simulationPanel;
	private ControlPanel controlPanel;
	
	public SimulationFrame(Simulation s)
	{
		simulationPanel = new SimulationPanel(s);
		s.setPanel(simulationPanel);
		
		controlPanel = new ControlPanel(s);
		
		setLayout( new BorderLayout() );
		add(simulationPanel, BorderLayout.CENTER);
		add(controlPanel, BorderLayout.SOUTH);
		
		setBounds(100, 100, s.getWorld().getWidth()+10, s.getWorld().getHeight()+60);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	}
}
