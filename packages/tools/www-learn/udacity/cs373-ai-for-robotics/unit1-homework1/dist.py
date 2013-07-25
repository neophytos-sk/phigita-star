p=[.2 for i in range(5)]
world=['green','red','red','green','green']
measurements = ['red', 'green']
pHit=.6
pMiss=.2

def sense(p,Z):
    q=[]
    for i in range(len(p)):
        hit = (Z == world[i])
        q.append(p[i]*(hit*pHit+(1-hit)*pMiss))

    s = sum(q)
    return [q[i]/s for i in range(len(q))]

for k in range(len(measurements)):
    p=sense(p,measurements[k])

print p
