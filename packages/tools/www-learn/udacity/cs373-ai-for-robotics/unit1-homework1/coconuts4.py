def f(n):
    return (n-1)/5.*4.

def f6(n):
    return f(f(f(f(f(f(n))))))

def is_int(n):
    return abs(n-int(n))<0.0000001

n = 0
found = False
while not found:
    n += 1
    found = is_int(f6(float(n)))

print n
