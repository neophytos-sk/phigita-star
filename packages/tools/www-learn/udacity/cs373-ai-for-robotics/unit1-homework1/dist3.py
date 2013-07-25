
p = [0,1,0,0,0]

world=['green','red','red','green','green']
measurements = ['red', 'green']
pHit=.6
pMiss=.2
pExact = 0.8
pOvershoot = 0.1
pUndershoot = 0.1

def sense(p,Z):
    q=[]
    for i in range(len(p)):
        hit = (Z == world[i])
        q.append(p[i]*(hit*pHit+(1-hit)*pMiss))

    s = sum(q)
    return [q[i]/s for i in range(len(q))]

def move(p, U):
    q = []
    for i in range(len(p)):
        s = pExact * p[(i-U)%len(p)]
        s = s + pOvershoot * p[(i-U+1)%len(p)]
        s = s + pUndershoot * p[(i-U-1)%len(p)]
        q.append(s)
    return q

for i in range(1000):
    p=move(p, 1)

print p
