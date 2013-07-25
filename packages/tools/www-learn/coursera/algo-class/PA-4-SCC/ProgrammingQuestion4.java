import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;

public class ProgrammingQuestion4 {
	private static class Node {
		int i;
		Node next;

		private Node(int i, Node next) {
			this.i = i;
			this.next = next;
		}
	}

	private static Node[] al;
	private static Node[] rl;
	private static boolean[] visited;
	private static int time;
	private static int[] times;
	private static int[] top = new int[5];
	private static int count;

	// need to run with -Xmx256m and -Xss3m
	public static void main(String[] args) throws IOException {
		readInput();
		visited = new boolean[al.length];
		time = 0;
		times = new int[al.length];
		for (int i = al.length - 1; i >= 0; i--) {
			firstDfs(i);
		}
		Arrays.fill(visited, false);
		for (int i = al.length - 1; i >= 0; i--) {
			int j = times[i];
			if (visited[j]) {
				continue;
			}
			count = 0;
			secondDfs(j);
			rank();
		}
		printTopFive();
	}

	private static void firstDfs(int i) {
		if (visited[i]) {
			return;
		}
		visited[i] = true;
		Node node = rl[i];
		while (node != null) {
			firstDfs(node.i);
			node = node.next;
		}
		times[time] = i;
		time++;
	}

	private static void secondDfs(int i) {
		if (visited[i]) {
			return;
		}
		visited[i] = true;
		count++;
		Node node = al[i];
		while (node != null) {
			secondDfs(node.i);
			node = node.next;
		}
	}

	private static void rank() {
		for (int i = 0; i < top.length; i++) {
			if (top[i] <= count) {
				for (int j = top.length - 1; j > i; j--) {
					top[j] = top[j - 1];
				}
				top[i] = count;
				break;
			}
		}
	}

	private static void printTopFive() {
		for (int i = 0; i < top.length; i++) {
			if (i > 0) {
				System.out.print(',');
			}
			System.out.print(top[i]);
		}
	}

	private static void readInput() throws IOException {
		al = new Node[875714];
		rl = new Node[al.length];
		BufferedReader br = new BufferedReader(new FileReader("ProgrammingQuestion04.txt"));
		try {
			String line;
			int[] parts = new int[2];
			while ((line = br.readLine()) != null) {
				int p = 0;
				int v = 0;
				for (int i = 0; i < line.length(); i++) {
					if (line.charAt(i) == ' ') {
						parts[p] = v;
						p++;
						v = 0;
					} else {
						v = (v * 10) + (line.charAt(i) - '0');
					}
				}
				int from = parts[0] - 1;
				int to = parts[1] - 1;
				al[from] = new Node(to, al[from]);
				rl[to] = new Node(from, rl[to]);
			}
		} finally {
			try {
				br.close();
			} catch (Exception ignored) {
			}
		}
	}
}
