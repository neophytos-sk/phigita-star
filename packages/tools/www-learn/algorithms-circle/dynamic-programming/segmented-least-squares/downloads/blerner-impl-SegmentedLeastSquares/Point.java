/**
 * A point consisting of an x,y coordinate pair.
 * The sorting order of points is based on their x coordinate.
 * 
 * @author Barbara Lerner
 * March 2007
 *
 */
public class Point implements Comparable {
	// The x coordinate
	private int x;
	
	// The y coordinate
	private int y;
	
	/**
	 * Create a point
	 * @param x the point's x coordinate
	 * @param y the point's y coordinate
	 */
	public Point (int x, int y) {
		this.x = x;
		this.y = y;
		System.out.println ("" + x + ", " + y);
	}
	
	/**
	 * Get the point's x coordinate
	 * @return the point's x coordinate
	 */
	public int getX() {
		return x;
	}
	
	/**
	 * Get the point's y coordinate
	 * @return the point's y coordinate
	 */
	public int getY() {
		return y;
	}

	/**
	 * Compare 2 points to each other.  Throws ClassCastException if other is not a point.
	 * @param other the other point
	 * @return a positive value if this point's x coordinate is more than the other's x coordinate,
	 *      a negative value if this point's x coordinate is less than the other's x coordinate,
	 *      and zero if they are the same.
	 */
	public int compareTo(Object other) {
		Point point2 = (Point) other;
		return x - point2.x;
	}
}
