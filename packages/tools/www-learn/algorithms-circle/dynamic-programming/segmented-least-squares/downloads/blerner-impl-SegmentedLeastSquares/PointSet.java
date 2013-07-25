import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;

/**
 * A set of points sorted by their x-value.
 * @author Barbara Lerner
 */
public class PointSet {
	// The points being managed
	private SortedSet<Point> points = new TreeSet<Point>();
	
	// An array representation of the points to allow selection by position.
	private Point[] pointArray;
	
	/**
	 * Creates an empty point set.
	 */
	public PointSet() {
		// Nothing special to be done.
	}

	/**
	 * Creates a point set using a specific collection of points
	 * @param pts the points in the set
	 */
	private PointSet(SortedSet<Point> pts) {
		points = pts;
	}

	/**
	 * Adds a point to the set
	 * @param p the point to add
	 * @return true if the point was added, false if it was already in the set
	 */
	public boolean add (Point p) {
		// Invalidate the array
		pointArray = null;
		return points.add(p);
	}
	
	/**
	 * Returns a subset of points between 2 positions, where the position is 
	 * determined by the order sorted by x-coordinates.
	 * @param from the position of the starting point to include
	 * @param to the position of the ending point to include
	 * @return the selected subset
	 */
	public PointSet subSet (int start, int end) {
		if (pointArray == null) {
			pointArray = points.toArray(new Point[points.size()]);		
		}
		
		// Including everything from start to the end of the set
		if (end > pointArray.length-2) {
			return new PointSet (points.tailSet(pointArray[start]));
		}
		
		// The subset method in SortedSet does not include the ending point, so we
		// give an index one greater so that our ending point is included.
		return new PointSet (points.subSet(pointArray[start], pointArray[end+1]));
	}

	/**
	 * Returns an iterator over the points, sorted by x-coordinates.
	 * @return an iterator over the points, sorted by x-coordinates.
	 */
	public Iterator<Point> iterator() {
		return points.iterator();
	}

	/**
	 * @return the number of points in the set
	 */
	public int size() {
		return points.size();
	}

	public void clear() {
		points.clear();
		pointArray = null;
	}

}
