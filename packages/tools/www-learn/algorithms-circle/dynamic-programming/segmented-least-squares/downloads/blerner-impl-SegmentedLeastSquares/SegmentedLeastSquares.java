import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JSlider;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

/**
 * This program demonstrates the solution to the Segmented Least Squares problem described in seciton 6.3 of 
 * Algorithm Design by Jon Kleinberg and Eva Tardos.
 * 
 * Given a set of points, find a set of line segments that fit the points well.  The number of line
 * segments to use is decided by assigning a cost to the addition of a segment.  With a cost of 0, we end up
 * with "connect-the-dots", that is, a line segment between each consecutive pair of points, as sorted by 
 * their x-coordinates.  By increasing the cost of adding a line, the number of segments added will be reduced.
 * 
 * To use this program, the user clicks in the window to add points.  Clicking the Draw Lines button
 * will calculate the line segments.  A slider can be used to adjust the cost of a line.
 * 
 * @author Barbara Lerner
 * March 2007
 *
 */
public class SegmentedLeastSquares implements ActionListener, ChangeListener {
	// The minimum cost for adding a line
	private static final int MINIMUM_LINE_COST = 0;
	
	// The maximum cost for adding a line
	private static final int MAXIMUM_LINE_COST = 10000;
	
	// The initial cost for adding a line
	private static final int INITIAL_LINE_COST = MINIMUM_LINE_COST;
	
	// All the points 
	private PointSet points;
	
	// The least square error for every pair of end points
	private double error[][];
	
	// The least error for a segment ending at a particular point
	private double optimalError[];
	
	// The cost for adding a line
	private double lineCost = INITIAL_LINE_COST;
	
	// Where everything is displayed
	private Display disp;

	/**
	 * Create an object to compute the segmented least squares
	 * @param points the points to create the segmented least squares over
	 * @param disp where to display the lines created
	 */
	public SegmentedLeastSquares (PointSet points, Display disp) {
		this.points = points;
		this.disp = disp;
	}

	/**
	 * When the user clicks the button, calculate the segmented least squares
	 */
	public void actionPerformed(ActionEvent event) {
		computeLines();
	}

	/**
	 * When the user moves the slider, update the line cost and recalculate the
	 * segmented least squares.
	 */
	public void stateChanged(ChangeEvent event) {
		lineCost = ((JSlider) event.getSource()).getValue();
		computeLines();
	}

	protected void clearData() {
		points.clear();
		disp.clear();
	}

	/**
	 * Compute a new set of segmented least square lines.
	 */
	private void computeLines() {
		// Remove the old lines from the display
		disp.clearLines();
		
		if (points.size() > 1) {
			error = new double[points.size()][points.size()];
			optimalError = new double [points.size()];
			segmentedLeastSquares();
			System.out.println ("Line cost = " + lineCost);
			findSegments(points.size()-1);
		}
	}
	
	/**
	 * Compute the least error for any line segment ending at each point.
	 */
	private void segmentedLeastSquares() {
		// Try each point as a starting point of a line segment
		for (int i = 0; i < points.size(); i++) {
			
			// Try each point that follows the starting point as an end to the line segment
			for (int j = i+1; j < points.size(); j++) {
				
				// Calculate the error for that line segment
				System.out.println ("Trying line from point " + i + " to point " + (j));
				PointSet linePoints = points.subSet(i,j);
				LineSegment line = new LineSegment(linePoints); 
				error[i][j] = line.getError();
				//System.out.println (line);
				System.out.println ("Error: " + error[i][j] + "\n");
			}
		}
		
		// Determine the optimal error for each end point.
		optimalError[0] = 0;
		for (int j = 1; j < points.size(); j++) {
			optimalError[j] = computeOptimalError(j);
			//System.out.println ("Minimum error ending at point " + j + " is " + optimalError[j]);
		}
	}
	
	/**
	 * Determine the least error for any of the line segments ending at point j
	 * @param j the end of the line segment
	 * @return the least error for any of the line segments ending at point j
	 */
	private double computeOptimalError (int j) {
		double min = error[0][j] + lineCost;
		for (int i = 1; i < j; i++) {
			// The error for using a line segment is the error of the segment itself,
			// the cost of adding a line, and the optimal error ending at the segment that precedes this one.
			double thisError = error[i][j] + lineCost + computeOptimalError(i);
			if (thisError < min) {
				min = thisError;
			}
		}
		return min;
	}
			
	/**
	 * Find the best line segments where the highest point to include ends at point j
	 * @param j the position of the highest point, sorted by x values.
	 */
	private void findSegments (int j) {
		if (j <= 0) {
			// Base case
			return;
		}
		
		// Determine the starting point that gives the least error for a line segment
		// ending at point j.
		double min = error[0][j] + lineCost;
		int minI = 0;
		for (int i = 1; i < j; i++) {
			double thisError = error[i][j] + lineCost + optimalError[i];
			if (thisError < min) {
				min = thisError;
				minI = i;
			}
		}
		
		// Create the line segment with least error.
		LineSegment newSegment = new LineSegment (points.subSet (minI, j)); 
		disp.addSegment (newSegment);
		System.out.println ("Adding line from point " + minI + " to " + j + " with error " + min);
		System.out.println (newSegment);
		
		// Recursively find the line segments that give minimum total error where
		// the highest point is the starting point for this segment.
		findSegments(minI);
	}

	/**
	 * Create the user interface for segmented least squares and the object to
	 * compute the segmented least squares
	 * @param args Not used
	 */
	public static void main (String[] args) {
		// The points added by the user
		final PointSet points = new PointSet();
		
		JFrame f = new JFrame();
		final Display disp = new Display(points);
		disp.addMouseListener(new MouseListener() {

			public void mouseClicked(MouseEvent e) {
				// Add a point where the user clicks.
				points.add (new Point (e.getX() - Display.X_OFFSET, e.getY() - Display.Y_OFFSET));
				disp.clearLines();
				disp.repaint();
			}

			public void mouseEntered(MouseEvent arg0) {
				// TODO Auto-generated method stub
				
			}

			public void mouseExited(MouseEvent arg0) {
				// TODO Auto-generated method stub
				
			}

			public void mousePressed(MouseEvent arg0) {
				// TODO Auto-generated method stub
				
			}

			public void mouseReleased(MouseEvent arg0) {
				// TODO Auto-generated method stub
				
			}
			
		});
		Container contentPane = f.getContentPane();
		contentPane.add(disp, BorderLayout.CENTER);
		
		JPanel buttonPanel = new JPanel();
		// Button that causes the best line segments to be computed.
		JButton lineButton = new JButton ("Draw lines");
		final SegmentedLeastSquares leastSquares = new SegmentedLeastSquares(points, disp); 
		lineButton.addActionListener (leastSquares);
		buttonPanel.add (lineButton);
		
		// Slider to allow modification of the cost of a single line.
		JSlider lineCostSlider = new JSlider(MINIMUM_LINE_COST, MAXIMUM_LINE_COST, INITIAL_LINE_COST);
		lineCostSlider.setPaintTicks(true);
		lineCostSlider.setMajorTickSpacing(3000);
		lineCostSlider.setPaintLabels(true);
		lineCostSlider.addChangeListener(leastSquares);
		buttonPanel.add(lineCostSlider);
		
		// Button to clear all the data points
		JButton clearButton = new JButton ("Clear data");
		clearButton.addActionListener(new ActionListener() {

			public void actionPerformed(ActionEvent arg0) {
				leastSquares.clearData();
			}
			
		});
		buttonPanel.add(clearButton);
		
		contentPane.add(buttonPanel, BorderLayout.SOUTH);
		f.setSize(Display.DISPLAY_WIDTH, Display.DISPLAY_HEIGHT);
		f.setVisible(true);
	}

}
