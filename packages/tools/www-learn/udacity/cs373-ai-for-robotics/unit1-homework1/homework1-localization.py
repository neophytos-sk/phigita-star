
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
