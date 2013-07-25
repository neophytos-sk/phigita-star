# This code is slightly modified from the unit in order to run on the Python
# translator. You shouldn't copy and paste directly over the robot class! In
# fact, you shouldn't need to modifiy anything in the first portion. :)

################################################################################
### NO NEED TO MODIFY THIS PORTION OF CODE UNLESS YOU REALLY WANT TO         ###
################################################################################

import math
import random

pi = math.pi

class robot:
    def __init__(self):
        self.x = random.random() * world_size
        self.y = random.random() * world_size
        self.orientation = random.random() * 2.0 * pi
        self.forward_noise = 0.0;
        self.turn_noise = 0.0;
        self.sense_noise = 0.0;
    
    def set(self, new_x, new_y, new_orientation):
        if new_x < 0 or new_x >= world_size:
            raise ValueError, 'X coordinate out of bound'
        if new_y < 0 or new_y >= world_size:
            raise ValueError, 'Y coordinate out of bound'
        if new_orientation < 0 or new_orientation >= 2 * pi:
            raise ValueError, 'Orientation must be in [0..2pi]'
        self.x = float(new_x)
        self.y = float(new_y)
        self.orientation = float(new_orientation)
    
    
    def set_noise(self, new_f_noise, new_t_noise, new_s_noise):
        # makes it possible to change the noise parameters
        # this is often useful in particle filters
        self.forward_noise = float(new_f_noise);
        self.turn_noise = float(new_t_noise);
        self.sense_noise = float(new_s_noise);
    
    
    def sense(self):
        Z = []
        for i in range(len(landmarks)):
            dist = math.sqrt((self.x - landmarks[i][0]) ** 2 + (self.y - landmarks[i][1]) ** 2)
            dist += random.gauss(0.0, self.sense_noise)
            Z.append(dist)
        return Z
    
    
    def move(self, turn, forward):
        if forward < 0:
            raise ValueError, 'Robot cant move backwards'         
        
        # turn, and add randomness to the turning command
        orientation = self.orientation + float(turn) + random.gauss(0.0, self.turn_noise)
        orientation %= 2 * pi
        
        # move, and add randomness to the motion command
        dist = float(forward) + random.gauss(0.0, self.forward_noise)
        x = self.x + (math.cos(orientation) * dist)
        y = self.y + (math.sin(orientation) * dist)
        
        # Unwind move if necessary.
        while x < 0:
            x += world_size
        while y < 0:
            y += world_size
        
        # Cyclic wrap (works on positive numbers).
        x %= world_size
        y %= world_size
        
        # set particle
        res = robot()
        res.set(x, y, orientation)
        res.set_noise(self.forward_noise, self.turn_noise, self.sense_noise)
        return res
    
    def Gaussian(self, mu, sigma, x):
        
        # calculates the probability of x for 1-dim Gaussian with mean mu and var. sigma
        return math.exp(-((mu - x) ** 2) / (sigma ** 2) / 2.0) / math.sqrt(2.0 * pi * (sigma ** 2))
    
    
    def measurement_prob(self, measurement):
        
        # calculates how likely a measurement should be
        
        prob = 1.0;
        for i in range(len(landmarks)):
            dist = math.sqrt((self.x - landmarks[i][0]) ** 2 + (self.y - landmarks[i][1]) ** 2)
            prob *= self.Gaussian(dist, self.sense_noise, measurement[i])
        return prob
    
    
    
    def __repr__(self):
        return '[x=%.6s y=%.6s orient=%.6s]' % (str(self.x), str(self.y), str(self.orientation))



def eval(r, p):
    sum = 0.0;
    for i in range(len(p)): # calculate mean error
        dx = (p[i].x - r.x + (world_size / 2.0)) % world_size - (world_size / 2.0)
        dy = (p[i].y - r.y + (world_size / 2.0)) % world_size - (world_size / 2.0)
        err = math.sqrt(dx * dx + dy * dy)
        sum += err
    return sum / float(len(p))
  

################################################################################
### THIS IS WHERE YOUR PYTHON MASTERY MAY BE DEMONSTRATED :-)                ###
################################################################################

### NOTE:
### Pay attention to function declaration notes. For your code to work in the
### simulator, it has to maintain the interface requirements. Otherwise you
### might blow something up (feel free to test that theory).

# Any globals.
### NOTE: These should not be renamed or reformatted. They are used in initializing
### the simulation. Feel free to modify them though.
landmarks = [[20.0, 20.0], [80.0, 80.0], [20.0, 80.0], [80.0, 20.0]]
world_size = 100.0
N = 1000
updateRate = 1.0; #Hz (0.1 - 10)

# Initialize.
# This function will be called to initialize the robot. The function should
# return the updated robot.
def Initialize():
    myrobot = robot()
    myrobot.set_noise(0.05, 0.05, 5.0)
    particles = []
    for i in range(N):
        particles.append(robot());
        particles[i].set_noise(0.05, 0.05, 5.0);
        
    # Print initial robot position.
    print "Initial position: " + str(myrobot)
    print "Initial goodness: " + str(eval(myrobot, particles))
    
    # Done.
    return [myrobot, particles]

# Move.
# This function will be called whenever a robot move is requested. The function
# should perform the move and update the particle map. The robot and the
# updated particle map should be returned.
def Move(myrobot, particles, orientationDelta, translation):
    # Move robot.
    myrobot = myrobot.move(orientationDelta, translation);
  
    # Update the particles.
    for index in range(len(particles)):
        particles[index] = particles[index].move(orientationDelta, translation)
    
    # Return the robot and the updated particle list.
    # NOTE: This should be a list with the robot as the first element and the list
    #   of particles as the second element.
    return [myrobot, particles]

# Sense.
# This function will be called to perform a robot sensor update. The function
# should return the sensed ranges and the updated particles.
def Sense(myrobot, particles):
    # Sense.
    Z = myrobot.sense()
  
    # Determine particle weights.
    w = []
    for particle in particles:
        w.append(particle.measurement_prob(Z))
    
    # Filter particles based on weights.
    filtered_particles = []
    index = int(random.random() * N)
    beta = 0.
    w_max = max(w)
    for i in range(N):
        beta += random.random() * 2.0 * w_max
        while beta > w[index]:
            beta -= w[index]
            index = (index + 1) % N
        filtered_particles.append(particles[index])
  
    # Finished update, return sensed ranges and new particle list.
    return [Z, filtered_particles]

# StepSimulation
# This function is called every time the simulation is stepped.
def StepSimulation(iteration, myrobot, particles):
    simFinished = False
    
    # Less than 10 iterations?
    if iteration < 10:
        # Move robot.
        [myrobot, particles] = Move(myrobot, particles, 0.2, 10)
        
        # Sense.
        [Z, particles] = Sense(myrobot, particles)
    else:
        simFinished = True
        
    # Print output.
    print "Iteration " + str(iteration) + ": " + str(eval(myrobot, particles))
    
    # Return arguments.
    return [myrobot, particles, simFinished]

# Debug.
# This function is called by our source editor when you hit "Run". You should
# put any debug code here and not in global scope, otherwise it will be executed
# when the simulation runs, which could be bad. :)
def Debug():
    # Initialize everything.
    [myrobot, particles] = Initialize()
  
    # Test out a few moves.
    print eval( myrobot, particles )
    
    # Run simulation.
    simFinished = False
    iteration = 0
    while not simFinished:
        [myrobot, particles, simFinished] = StepSimulation(iteration, myrobot, particles)
        iteration += 1
