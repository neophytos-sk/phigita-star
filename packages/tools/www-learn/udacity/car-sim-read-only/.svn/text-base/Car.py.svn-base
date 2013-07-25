import java
import sys
from math import *
from java.awt import *
import configs.noErrors as cfg
import AStar as astar
from com.jreitter.philipp.udacity.simulator.abstracts import *
from com.jreitter.philipp.udacity.simulator.view import *
from com.jreitter.philipp.udacity.simulator import *
from com.jreitter.philipp.controller import *
from com.jreitter.philipp.udacity import *
from com.jreitter.philipp.util import *
#IMPORTS 'n STUFF

def drawNode(g, node):
    x  = px = node[1]
    y  = py = node[2]
    an = node[3]
    for j in range(astar.ITERATIONS):
        x, y, an = BicycleModel.getPos(x, y, an, astar.ANGLES[node[7]], -astar.SPEED[node[7]], 0.02, cfg.carLength)
        g.drawLine(int(px), int(py), int(x), int(y))
        px = x
        py = y
  
def drawPath(g, node):
    drawNode(g, node)
    if node[6] != None:
        drawPath(g, node[6])
    
def drawTree(g, nodes):
    for n in nodes:
       drawNode(g, n)

def getDrivePath(node):
    p = [node]
    while node[6] != None:
        node = node[6]
        p.append(node)
    return p

class MyListener(SimulationListener):

    
    def init(self, ctrl, background):
        self.dots = [[0,0]]
        self.scanPos = [0,0]
        self.cnt = 0
        self.car = ctrl
        self.world = astar.initWorld()        
        self.inst = None
        self.path = None
        self.lastNode = None
        
    def onUpdate(self, dt):
        if self.cnt>=astar.ITERATIONS:
            if self.inst != None and len(self.inst) > 0:
                cur = self.inst.pop()
                self.car.setSteer(astar.ANGLES[cur[7]])
                self.car.setSpeed(astar.SPEED[cur[7]])
                self.cnt = 0
            else:
                self.car.setSteer(0)
                self.car.setSpeed(0)
        self.cnt += 1

    
    def onPaint(self, g):
        astar.drawMap(self.world, g)
        if self.path != None:
            pos = self.car.getPos()
            g.setColor(Color.orange)
            drawTree(g, self.path)
        
        if self.lastNode != None:
            g.setColor(Color.green)
            g.setStroke(BasicStroke(2))
            drawPath(g, self.lastNode)
            g.setStroke(BasicStroke(1))
        
    def onGPS(self, pos):
        astar = 1
        
    def onCamera(self, img):
        astar = 1
        
    def onScanner(self, dots):
        self.world = astar.buildMap(self.world, self.car.getPos(), dots)
        if astar.checkCollision(self.inst, self.world) == True:
            self.path, self.lastNode = astar.run(self.world, self.car.getPos(), self.car.getAngle())
            self.inst = getDrivePath(self.lastNode)
            self.cnt = astar.ITERATIONS

    def setPath(self, p):
        self.path = p
   
   
   
   
        
listener = MyListener()      
s = Simulation()
s.loadConfig("configs/"+cfg.fileName)
s.setListener(listener)
v = SimulationFrame(s)
astar.FRAME = v
astar.LISTENER = listener
s.start()
v.setVisible(1)