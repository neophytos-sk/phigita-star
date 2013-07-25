import random
import configs.test as cfg
from math import *

from com.jreitter.philipp.udacity.simulator import BicycleModel

N = 1000

class particle:
    
    x = 0.
    y = 0.
    a = 0.
    
    def __init__(self):
        self.x = cfg.carStartX+random.random()*cfg.gpsSensorNoise*2
        self.y = cfg.carStartY+random.random()*cfg.gpsSensorNoise*2
        self.a = random.random()*2*pi
        
    def update(self, speed, steer, dt):
        
        self.x, self.y, self.a = BicycleModel.getPos(self.x, self.y, self.a, random.gauss(steer, 0.1), speed, dt, cfg.carLength)
            
    def measurement_prob(self, gps):
        error_dist = sqrt( (self.x-gps[0])**2 + (self.y-gps[1])**2 )
        error = (exp(- (error_dist ** 2) / (cfg.gpsSensorNoise ** 2) / 2.0) /  
                  sqrt(2.0 * pi * (cfg.gpsSensorNoise ** 2)))
        return error
    
    def clone(self):
        r = particle()
        r.x = self.x
        r.y = self.y
        r.a = self.a
        return r
        
    
def initFilter():
    p = []
    for i in range(N):
        r = particle()
        p.append(r)
    return p

def updateFilter(p, car, steer, dt):
    for i in range(N):
        p[i].update(car.getSpeed(), steer, dt)
 
    return p

def measureFilter(p, gps):
    w = []
    for i in range(N):
        w.append(p[i].measurement_prob(gps))

    p3 = []
    index = int(random.random() * N)
    beta = 0.0
    mw = max(w)
    for i in range(N):
        beta += random.random() * 2.0 * mw
        while beta > w[index]:
            beta -= w[index]
            index = (index + 1) % N
        p3.append(p[index].clone())
    return p3

def get_position(p):
    x = 0.0
    y = 0.0
    a = 0.0
    for i in range(len(p)):
        x += p[i].x
        y += p[i].y
        # a is tricky because it is cyclic. By normalizing
        # around the first particle we are somewhat more robust to
        # the 0=2pi problem
        a += (((p[i].a - p[0].a + pi) % (2.0 * pi)) 
                        + p[0].a - pi)
    return [x / len(p), y / len(p), a / len(p)]