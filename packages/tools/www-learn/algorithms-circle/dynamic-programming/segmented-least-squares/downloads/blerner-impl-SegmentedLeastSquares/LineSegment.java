import java.util.Iterator;

/**
 * A line segment that is computed as a least squares fit for a set of points.
 * It is defined as an equation of the form y = mx + b.  Since it is a 
 * segment, it also has a minimum and a maximum x value.
 * 
 * @author Barbara Lerner
 * March 2007
 *
 */
public class LineSegment {
	// The points that the line segment fits.
	private PointSet pSet;
	
	/* Values used in the least squares computation of the slope and
	   y intercept for the line */
	
	// The sum of x coordinates of all points
	private double xSum = 0;
	
	// The sum of y coordinates of all points
	private double ySum = 0;

	// The sum of x-y products of all points
	private double xySum = 0;

	// The sum of x-squared of all points
	private double xSquaredSum = 0;
	
	// End of values used in computing slope and y intercept
	
	// The slope of the least squares line
	private double slope;
	
	// The y intercept of the least squares line
	private double yIntercept;
	
	// The smallest x value for the line segment
	private int minX;
	
	// The largest x value for the line segment
	private int maxX;
	
	// The least squares error for the line segment
	private double leastSquaresError;
	
	/**
	 * Create the best fit line segment for a set of points
	 * @param points the points to fit a line to.  The points must be
	 * 		sorted by x-value.
	 */
	public LineSegment (PointSet points) {
		System.out.println ("Line has " + points.size() + " points");
		pSet = points;
		calculateSums();
		calculateSlope();
		calculateYIntercept();
		calculateError();
	}
	
	/**
	 * @return the equation for the line
	 */
	public String toString() {
		return "y = " + slope + "x + " + yIntercept;
	}
	
	/**
	 * Calculate the various sums used in the least squares computation
	 * Also, remember the smallest and largest x values in the set.
	 */
	private void calculateSums() {
		Iterator<Point> pointIter = pSet.iterator();
		boolean first = true;
		while (pointIter.hasNext()) {
			Point p = pointIter.next();
			if (first) {
				minX = p.getX();
				first = false;
			}
			maxX = p.getX();
			xSum = xSum + p.getX();
			ySum = ySum + p.getY();
			xySum = xySum + p.getX() * p.getY();
			xSquaredSum = xSquaredSum + p.getX() * p.getX();
		}
	}
	
	/**
	 * Calculate the slope of the least squares line.
	 */
	private void calculateSlope() {
		slope = (pSet.size() * xySum - xSum * ySum) / (pSet.size() * xSquaredSum - xSum * xSum);
	}

	/**
	 * Calculate the y-intercept of the least squares line.
	 */
	private void calculateYIntercept() {
		yIntercept = (ySum - slope * xSum) / pSet.size();		
	}
	
	/**
	 * @return the smallest x value for the line segment
	 */
	public int getMinX() {
		return minX;
	}
	
	/**
	 * @return the largest x value for the line segment
	 */
	public int getMaxX() {
		return maxX;
	}

	/**
	 * Calculate the y-value for a given x value
	 * @param x the x value whose y-value we want to calculate
	 * @return the y-value for the point on the line with the given x-value
	 */
	public int getY(int x) {
		return (int) (slope * x + yIntercept);
	}
	
	/**
	 * Calculate the least squares error for the line segment as a fit to the 
	 * set of points
	 */
	private void calculateError() {
		Iterator<Point> pointIter = pSet.iterator();
		leastSquaresError = 0;
		while (pointIter.hasNext()) {
			Point p = pointIter.next();
			double error = p.getY() - slope * p.getX() - yIntercept; 
			leastSquaresError = leastSquaresError + error * error;
		}
	}

	/**
	 * @return the least squares error for the line segment as a fit to the 
	 * 		set of points
	 */
	public double getError() {
		return leastSquaresError;
	}

}
