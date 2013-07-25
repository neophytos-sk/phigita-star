package com.jreitter.philipp.udacity.simulator.view;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JSlider;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import com.jreitter.philipp.udacity.simulator.Simulation;

public class ControlPanel extends JPanel implements ActionListener, ChangeListener
{
	private static final long serialVersionUID = 1L;
	private Simulation simulation;

	private JButton btnStart;
	private JSlider speed;
	
	public ControlPanel(Simulation s)
	{
		this.simulation = s;
		
		btnStart = new JButton("Stop");
		btnStart.addActionListener(this);
		
		speed = new JSlider(0, 100);
		speed.addChangeListener(this);
		speed.setValue(80);
		
		this.setLayout(new BorderLayout());
		this.add(speed, BorderLayout.CENTER);
		this.add(btnStart, BorderLayout.EAST);
	}

	@Override
	public void actionPerformed(ActionEvent arg0) 
	{
		if(simulation.isRunning())
		{
			simulation.setRunning(false);
			btnStart.setText("Start");
		}else
		{
			if( simulation.start() )
				btnStart.setText("Stop");
		}
	}

	@Override
	public void stateChanged(ChangeEvent arg0) 
	{
		simulation.setTimeDelay(101-speed.getValue());
	}
}
