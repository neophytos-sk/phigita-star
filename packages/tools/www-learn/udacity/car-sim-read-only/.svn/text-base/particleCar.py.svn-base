import java
import sys
from math import *
from java.awt import *

import configs.test as cfg
import particle as par

from com.jreitter.philipp.udacity.simulator.abstracts import *
from com.jreitter.philipp.udacity.simulator.view import *
from com.jreitter.philipp.udacity.simulator import *
from com.jreitter.philipp.controller import *
from com.jreitter.philipp.udacity import *
from com.jreitter.philipp.util import *




    

car = None
bg  = None
filter = None

gpos = [0,0]

angle = 0;

counter = 0

def init(c,b):
    global car, bg, filter, angle, filter
    car = c
    bg = b
    car.setSpeed(1.)
    car.setSteer(.4)
    angle = 0
    filter = par.initFilter()

def update(dt):
    global filter
    filter = par.updateFilter(filter, car, .4*cfg.carMaxSteer, dt)
    
def paint(g):
    g.setColor(Color.red)
    g.fillRect(int(gpos[0]-4), int(gpos[1]-4), 8, 8)
    global filter
    
    g.setColor(Color.blue)
    for p in filter:
        g.fillRect(int(p.x)-2, int(p.y)-2, 4, 4)
    
    
    
def gps(pos):
    global gpos, filter
    gpos = pos
    filter = par.measureFilter(filter, pos)
    
def cam(img):
    img = 0








#SIMULATION STUFF
class MyListener(SimulationListener):
    def init(self, ctrl, background):
        init(ctrl,background)
    def onUpdate(self, dt):
        update(dt)
    def onPaint(self, g):
        paint(g)
    def onGPS(self, pos):
        gps(pos)
    def onCamera(self, img):
        cam(img)
        
s = Simulation()
s.loadConfig("configs/"+cfg.fileName)
s.setListener(MyListener())
v = SimulationFrame(s)
s.start()
v.setVisible(1)