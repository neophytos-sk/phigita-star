import java
import sys
from array import *
from math import *
from java.awt import *
import configs.noErrors as cfg
from com.jreitter.philipp.udacity.simulator.abstracts import *
from com.jreitter.philipp.udacity.simulator.view import *
from com.jreitter.philipp.udacity.simulator import *
from com.jreitter.philipp.controller import *
from com.jreitter.philipp.udacity import *
from com.jreitter.philipp.util import *
#IMPORTS 'n STUFF

ITERATIONS = 30
ANGLES = [1, 0, -1, 0]
SPEED = [100, 100, 100, -100]
COSTS = [10, 1, 10, 500]
GOAL = [770, 570]
FRAME = None
LISTENER = None


def initWorld():
    w = []
    for i in range(cfg.worldWidth/cfg.worldSpacing):
        col = []
        for j in range(cfg.worldHeight/cfg.worldSpacing):
            col.append(0)
        w.append(col)
    return w
    
def buildMap(w, pos, dots):
    for d in dots:
        x = int((d[0]+pos[0])/cfg.worldSpacing)
        y = int((d[1]+pos[1])/cfg.worldSpacing)
        w[x][y] = 1
    return w
        
def drawMap(w, g):
    g.setColor(Color.red)
    for x in range(cfg.worldWidth/cfg.worldSpacing):
        for y in range(cfg.worldHeight/cfg.worldSpacing):
            if w[x][y] == 1:
                g.drawRect(x*cfg.worldSpacing, y*cfg.worldSpacing, cfg.worldSpacing,cfg.worldSpacing)
                
    
#step = [ COST+HEURISTIC, X, Y, ANGLE, COST, CHILDREN=[], PARENT, speed, Steer]
#getPos(float x, float y, float angle, float steer, float speed, float dt, float length)
    
def heuristic(p):
    return sqrt((p[0]-GOAL[0])**2+(p[1]-GOAL[1])**2)
    
def collide(p, map):
    x = int((p[0])/cfg.worldSpacing)
    y = int((p[1])/cfg.worldSpacing)
    ww = cfg.worldWidth/cfg.worldSpacing
    wh = cfg.worldHeight/cfg.worldSpacing
    
    for dx in range(5):
        for dy in range(5):
            nx = x+dx-2
            ny = y+dy-2
            if nx >= ww or nx < 0 or ny >= wh or ny < 0:
                continue
            
            if map[nx][ny] == 1:
                return True
                        
    return False

def collideCheck(x2, y2, a2, i, map, fact=1):
    for j in range(ITERATIONS):
        x2, y2, a2 = BicycleModel.getPos(x2, y2, a2, ANGLES[i], fact*SPEED[i], 0.02, cfg.carLength)
        
        if collide([x2,y2], map) == True:
            raise None
        
    return x2, y2, a2

def expand(todo, step, map, donel, first=False):
    cost = step[4]
    x = step[1]
    y = step[2]
    a = step[3]
    
    for i in range(len(ANGLES)):
        x2 = x
        y2 = y
        a2 = a
        
        try:
            x2, y2, a2 = collideCheck(x2, y2, a2, i, map)
        except:
            continue
        
        c2 = cost+COSTS[i]
        if first == True:
            next = [c2+heuristic([x2,y2]), x2, y2, a2, c2, None, None, i]
        else:
            next = [c2+heuristic([x2,y2]), x2, y2, a2, c2, None, step, i]

        if not next in donel:
            todo.append(next)
        
    return todo
         
def isInRange(p1, p2, d):
    if sqrt((p1[0]-p2[0])**2+(p1[1]-p2[1])**2) < d:
        return True
    else:
        return False
            
def run(w, pos, angle):
    donel = []
    start = [heuristic(pos), pos[0], pos[1], angle, 0, None, None, 1]
    todo = expand([], start, w, donel, True)
    
    found = False
    done  = False
    while found == False and done == False:
        if len(todo) == 0:
            done = True
        else:
            todo.sort()         
            next = todo.pop(0)
            donel.append(next)
            
            cost = next[0]
            x = next[1]
            y = next[2]
            a = next[3]
            
            tmp = []
            tmp.extend(donel)
            tmp.extend(todo)
            LISTENER.setPath(tmp)
            FRAME.repaint()
            
            if isInRange([x,y], GOAL, 50):
                found = True
                print "DONE"
            else:
                todo = expand(todo, next, w, donel)
    
    if done == True:
        print "FAIL"
        
    donel.extend(todo)
    return donel, next       
            
def checkCollision(inst, world):
    if inst == None:
        return True
    
    for n in range(len(inst)):
        try:
            collideCheck(inst[n][1], inst[n][2], inst[n][3], inst[n][7], world, -1)
        except:
            return True
    
    return False
    
        
            
            
    
    