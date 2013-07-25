import java.awt.Graphics;
import java.util.ArrayList;
import java.util.Iterator;

import javax.swing.JPanel;

/**
 * Manages the display of the segmented least squares problem.  It draws x-y axes,
 * points and line segments.
 * 
 * @author Barbara Lerner
 * March 2007
 *
 */
public class Display extends JPanel {
	/**
	 * Offset between a logical x,y coordinate and the pixel values used in Java's display.
	 */
	public static final int X_OFFSET = 300;

	/**
	 * Offset between a logical x,y coordinate and the pixel values used in Java's display.
	 */
	public static final int Y_OFFSET = 300;
	
	/**
	 * The width of the display
	 */
	public static final int DISPLAY_WIDTH = 2 * X_OFFSET;
	
	/**
	 * The height of the display
	 */
	public static final int DISPLAY_HEIGHT= 2 * Y_OFFSET;
	
	/**
	 * The size of a point
	 */
	private static final int POINT_SIZE = 6;
	
	// The points to display
	private PointSet points;
	
	// The line segments to display
	private ArrayList<LineSegment> segments = new ArrayList<LineSegment>();
	
	/**
	 * Creates a display for a set of points
	 * @param points the points to display
	 */
	public Display(PointSet points) {
		this.points = points;
	}

	/**
	 * Draws the display consisting of the x-y axes, the points and the line segments.
	 */
	public void paintComponent (Graphics g) {
		// Erase the previous display
		g.clearRect(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT);
		
		// Draw x axis
		g.drawLine(0, Y_OFFSET, DISPLAY_WIDTH, Y_OFFSET);
		
		// Draw y axis
		g.drawLine (X_OFFSET, 0, X_OFFSET, DISPLAY_HEIGHT);
		
		// Draw the points
		Iterator<Point> iter = points.iterator(); 
		while (iter.hasNext()) {
			Point p = iter.next();
			g.fillOval(p.getX()-(POINT_SIZE/2)+X_OFFSET, p.getY()-(POINT_SIZE/2)+Y_OFFSET, POINT_SIZE, POINT_SIZE);
		}
		
		// Draw the line segments
		Iterator<LineSegment> lineIter = segments.iterator();
		while (lineIter.hasNext()) {
			LineSegment segment = lineIter.next();
			int minX = segment.getMinX();
			int maxX = segment.getMaxX();
			g.drawLine(minX + X_OFFSET, segment.getY(minX) + Y_OFFSET, maxX + X_OFFSET, segment.getY(maxX) + Y_OFFSET);
		}
	}

	/**
	 * Add a line segment and refresh the display
	 * @param segment the line segment to add.
	 */
	public void addSegment(LineSegment segment) {
		segments.add(segment);
		repaint();
	}

	/**
	 * Remove all exisitng line segments.
	 *
	 */
	public void clearLines() {
		segments.clear();		
	}

	public void clear() {
		clearLines();
		points.clear();
		repaint();
	}
}
