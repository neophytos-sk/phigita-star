# An implementation of Kosaraju's Two-Pass Algorithm for computing Strongly Connected graph components in O(m + n) time using DFS.
# Jared Murphy  14th April 2012

# This works with directed graphs, using an adjacency list to store the vertices and edges

import sys
sys.setrecursionlimit(1000000)

# GRAPH VARIABLES
edges = []
vertices = [-1]    # vertices[0] is not used.... vertices[1] = all the edges going from 1 to somewhere else.
reverse_edges = []
reverse_vertices = [-1]

largestVertex = 875714

# ALGORITHM VARIABLES
explored = [-1]
leaders = [-1]
finishing_times = [-1]
t = 0
s = None

def readGraph(filename):
	# Read all lines into an edges array
	global edges
	global vertices
	global largestVertex
	
	# Populate the vertices array with 875714 empty elements
	for i in range(0, largestVertex):
		vertices.append([])
		reverse_vertices.append([])
	
	f = open(filename, "r")
	for line in f:
		edges.append([int(line.split(" ")[0]), int(line.split(" ")[1])])		# Add a new directed edge to our array.
		vertices[int(line.split(" ")[0])].append(len(edges) - 1)				# Append the edge onto the vertex at the edge's tail.
		reverse_edges.append([int(line.split(" ")[1]), int(line.split(" ")[0])])		# A reverse graph is needed in the algo. We may as well do this here...
		reverse_vertices[int(line.split(" ")[1])].append(len(edges) - 1)				#   ''		''		''		''		''		''		''		''
	f.close()
	
def DFS(verts, edges, start):
	global explored
	global s	# The leader of this node... set in DFS_loop
	global t
	global finishing_times
	global leaders
	
	explored[start] = True
	leaders[start] = s
	for edge in verts[start]:
		if not explored[edges[edge][1]]:
			DFS(verts, edges, edges[edge][1])
	t += 1
	if finishing_times[t] == -1:	# Only set the finishing time if we're on the first pass of DFS_loop
		finishing_times[t] = start
	
def DFS_loop(verts, edges, pass_num):
	global t		# Keeps track of the finishing time counter for the first pass
	global s		# To compute 'leaders'. Only relevant for the second pass
	global explored
	global finishing_times
	global leaders
	
	t = 0
	# Initialize all nodes as unexplored
	explored = [-1]
	for i in range(0, largestVertex):
		explored.append(False)
	
	# Initialize all leaders as -1
	leaders = [-1]
	for i in range(0, largestVertex):
		leaders.append(-1)
	
	# Initialize all finishing times as -1 (Only if we're on the first pass)
	if pass_num == 1:
		for i in range(0, largestVertex):
			finishing_times.append(-1)
		
	# Loop over all possible starting nodes
	if pass_num == 1:
		for node in range(largestVertex, 0, -1):
			if not explored[node]:
				s = node
				DFS(verts, edges, node)
				
	elif pass_num == 2:
		for node in finishing_times[::-1]:
			if not explored[node]:
				s = node
				DFS(verts, edges, node)
	
def kosaraju():
	print("< 1 > Running reverse DFS Loop...")
	DFS_loop(reverse_vertices, reverse_edges, 1)	# Compute finishing times.
	
	print("< 2 > Running forward DFS Loop with finishing times...")
	DFS_loop(vertices, edges, 2)					# Compute the leaders.
	
	print("< 3 > Grouping strongly connected components...")
	# Sort strongly connected components by common leaders.
	leadic = {}		# The easiest way to do this in python is with a dictionary.
	for i in leaders[1:]:
			leadic[i] = leadic.get(i, 0) + 1

	print("< 4 > Computing largest SCC's...")
	a = 0
	b = 0	# b < a
	c = 0	# c < b < a
	d = 0	# d < c < b < a
	e = 0	# e < d < c < b < a
	
	for i in leadic.keys():
		if leadic[i] > a:
			e = d
			d = c
			c = b
			b = a
			a = leadic[i]
		elif leadic[i] > b:
			e = d
			d = c
			c = b
			b = leadic[i]
		elif leadic[i] > c:
			e = d
			d = c
			c = leadic[i]
		elif leadic[i] > d:
			e = d
			d = leadic[i]
		elif leadic[i] > e:
			e = leadic[i]
	print("The 5 largest SCC's are:", a, b, c, d, e)
	
print("Reading in graph file...")
readGraph("SCC.txt")
print("Invoking Kosaraju Algorithm...")
kosaraju()
