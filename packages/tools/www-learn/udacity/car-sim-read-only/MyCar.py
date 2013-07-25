import java
import sys
from math import *
from java.awt import *

import configs.noErrors as cfg
import Utils as utils

from com.jreitter.philipp.udacity.simulator.abstracts import *
from com.jreitter.philipp.udacity.simulator.view import *
from com.jreitter.philipp.udacity.simulator import *
from com.jreitter.philipp.controller import *
from com.jreitter.philipp.udacity import *
from com.jreitter.philipp.util import *

class MyListener(SimulationListener):
    car = 0
    bg = 0
    
    x = 0
    y = 0
    p = []
    
    angle = 0
    
    gpsx = 0
    gpsy = 0
    
    def init(self, ctrl, background):
        self.car = ctrl
        self.bg = background
        self.angle = 0
        self.x = cfg.carStartX
        self.y = cfg.carStartY
        ctrl.setSteer(.5)
        ctrl.setSpeed(1.)
        self.p = utils.init(self.p, background, self.x, self.y)

    
    def onUpdate(self, dt):
        #integrate sensor data, assume prefect sensors
        self.angle = self.angle + dt * self.car.getGyro() 
        
        px = self.x
        py = self.y 
        
        self.x = self.x+self.car.getSpeed()*cos(self.angle)*dt
        self.y = self.y+self.car.getSpeed()*sin(self.angle)*dt
        
        #detect cell skip
        xcell = int(self.x/cfg.worldSpacing)
        ycell = int(self.y/cfg.worldSpacing)
        pxcell = int(px/cfg.worldSpacing)
        pycell = int(py/cfg.worldSpacing)
        if xcell-pxcell != 0 or ycell-pycell != 0:
            self.p = utils.move(self.p, [xcell-pxcell,ycell-pycell])
        

    def onPaint(self, g):
        #Draw Integrated Estimation
        utils.drawArrow(self, g)
        
        #Draw Localization
        utils.drawLocalization(self, g, self.p)
        
        #Draw GPS
        g.setColor(Color.yellow)
        g.fillRect(int(self.gpsx-3),
                   int(self.gpsy-3),
                   6,6)
        
    def onGPS(self, pos):
        self.gpsx = pos[0]
        self.gpsy = pos[1]
        

    def onCamera(self, img):
        self.p = utils.sense(self.p, self.bg, img[0][0], 0.2)
        #there is a cell estimation error which causes my prob to be 0
        #if the car skips in X and Y a cell, do not use a sensor error prob. of 0
        


 

#Start Simulation
s = Simulation()
s.loadConfig("configs/"+cfg.fileName)
s.setListener(MyListener())
v = SimulationFrame(s)
s.start()
v.setVisible(1)
