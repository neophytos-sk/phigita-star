import java
import sys
import math
import Utils 

from java.awt import *

from com.jreitter.philipp.udacity.simulator.abstracts import *
from com.jreitter.philipp.udacity.simulator.view import *
from com.jreitter.philipp.udacity.simulator import *
from com.jreitter.philipp.controller import *
from com.jreitter.philipp.udacity import *
from com.jreitter.philipp.util import *

#draw my position/angle estimation 
def drawArrow(self, g):        
    gg = g.create()
    gg.setColor(Color.blue)
    gg.rotate(self.angle, self.x, self.y)
    gg.drawLine(int(self.x),
                int(self.y),
                int(self.x+30),
                int(self.y))
    
    gg.fillRect(int(self.x-2),
               int(self.y-2), 5, 5)
    gg.dispose()
    
    
    
#Localization code from Unit 1
xoffset = 0
yoffset = 0

def drawLocalization(self, g, p):
    global xoffset, yoffset
    scale = max2d(p)
    for x in range(10):
        for y in range(10):
            alpha = p[x][y]/scale
            if alpha > 1.: alpha = 1. #wire synchronization error (i guess?), dont touch!
            g.setColor(Color(0.8, 0, 0, alpha))
            g.fillRect((x+xoffset)*10, (y+yoffset)*10, 10, 10)
      
def normalDistribution(p):
    normal = 1./100
    for row in range(10):
        nrow=[]
        for col in range(10): #@UnusedVariable
            nrow.append(normal)
        p.append(nrow)
    return p
    
def init(p,world,sx,sy):
    global xoffset, yoffset
    p = []
    p = normalDistribution(p)
    xoffset = int(sx/10-5)
    yoffset = int(sy/10-5)
    return p


def max2d(p):
    _max = 0.
    for row in p:
        tmp = max(row)
        if tmp > _max:
            _max = tmp
    return _max

def sum2d(p):
    _sum = 0.
    for row in p:
        _sum += sum(row)
    return _sum

def normalize(p):
    normal = sum2d(p)
    if normal == 0:
        p = normalDistribution(p) #something blew up
    else:
        for row in range(10):
            for col in range(10):
                p[row][col]/=normal
    return p
    
def move(p,cmd): #TODO: add movement probability
    global xoffset, yoffset
    xoffset += cmd[0]
    yoffset += cmd[1]
    return p

def sense(p,world,measurement,p_s):
    global xoffset, yoffset
    for x in range(10):
        for y in range(10):
            if world.getColorAt(x+xoffset, y+yoffset)==measurement:
                p[x][y] = p[x][y]*(1-p_s)
            else:
                p[x][y] = p[x][y]*p_s
    return normalize(p)