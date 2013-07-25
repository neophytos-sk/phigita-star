iter=1000
code="""


#colors = [['green','green','green'],
#        ['green','red','red'],
#        ['green','green','green']]

#measurements=['red']
#motions=[[0,0]]
#sensor_right=0.8
#p_move=1.0

#measurements = ['red','red']
#motions=[[0,0],[0,1]]
#sensor_right = 1.0
#p_move = 0.5

colors=[['red', 'green', 'green', 'red', 'red'],
        ['red', 'red', 'green', 'red', 'red'],
        ['red', 'red', 'green', 'green', 'red'],
        ['red', 'red', 'red', 'red', 'red']]


measurements = ['green','green','green','green','green']
motions=[[0,0],[0,1],[1,0],[1,0],[0,1]]
sensor_right = 0.7
p_move = 0.8



p = [[1./(len(colors)*len(colors[0])) for j in colors[0]] for i in colors]

def sense(p,Z):
    q=[]

    nrows = len(p)
    ncols = len(p[0])
    for i in range(nrows):
        row = []
        for j in range(ncols):
            hit = (Z == colors[i][j])
            row.append(p[i][j] * (hit*sensor_right + (1-hit)*(1.-sensor_right)))

        q.append(row)

    s = sum(sum(q[i]) for i in range(nrows))

    for i in range(nrows):
        for j in range(ncols):
            q[i][j] /= s

    return q


def move(p, delta):
    q = []

    (delta_row,delta_col) = delta

    nrows = len(p)
    ncols = len(p[0])

    for i in range(nrows):
        row = []
        for j in range(ncols):
            s = p_move * p[(i-delta_row)%nrows][(j-delta_col)%ncols]
            s = s + (1.-p_move) * p[i][j]
            row.append(s)

        q.append(row)

    return q

def show(p):
    print p

for i in range(len(measurements)):
    p=move(p, motions[i])
    p=sense(p,measurements[i])

show(p)


"""
code='def loc(colors,motions,measurements,sensor_right,p_move):\n'+\
        '\n'.join(['    '+l for l in code.splitlines()])+\
        '\n    return p\n'

import imp
from random import *
icode=imp.new_module('mod')
exec code in icode.__dict__
nlm=lambda f,x,y:[map(f,x,y) for x,y in zip(x,y)]
def loc(colors,motions,measurements,sensor_right,p_move):
    m=len(colors)
    n=len(colors[0])
    p=[[1./(m*n)]*n]*m
    def norm(p): 
        s=float(sum(map(sum,p)))
        return [map(lambda i:i/s,r) for r in p] 
    def shift(p,U):
        t=[r[-U[1]:]+r[:-U[1]] for r in p]
        return t[-U[0]:]+t[:-U[0]] 
    sense=lambda p,Z:nlm(lambda a,b:a*sensor_right if b==Z else a*(1-sensor_right),p,colors)
    move=lambda p,U:nlm(lambda x,y:p_move*x+(1-p_move)*y,shift(p,map(lambda m,l:m%l,U,[m,n])),p)
    for Z,U in zip(measurements,motions):
        p=norm(sense(move(p,U),Z))
    return p

def gencolors():
    p=random()
    x=int(random()*500+1)
    y=int(random()*500+1)
    return [['green' if random()<p else 'red' for i in range(x)] for j in range(y)]
def genpath(colors):
    sensor_right=gauss(0.7,0.3)
    p_move=gauss(0.8,0.2)
    y=int(random()*len(colors))
    x=int(random()*len(colors[0]))
    lenp=max(int(gauss(30,15)),1)
    notcol=lambda x: 'green' if x=='red' else 'red'
    motions=[]
    measurements=[]
    for i in range(lenp):
        move=choice([[j,k] for j in range(-1,2)  for k in range(-1,2) if not (j and k)])
        x+=move[1] if random()<p_move else 0
        y+=move[0] if random()<p_move else 0
        x%=len(colors[0])
        y%=len(colors)
        motions.append(move)
        measurements.append(colors[y][x] if random()<sensor_right else  notcol(colors[y][x]))
    return [motions,measurements,sensor_right,p_move]

def geninputs():
    colors=gencolors()
    return [colors]+genpath(colors)
correct=[]
for i in range(iter):
    input=geninputs()
    p1=loc(*input)
    p2=icode.loc(*input)
    correct.append(max(map(max,nlm(lambda x,y:abs(x-y),p1,p2))))
print "{} correct out of {}".format(sum([i<0.000001 for i in correct]),len(correct))
print "Mean Error: {} \n Max Error: {}".format(sum(correct)/len(correct),max(correct))
