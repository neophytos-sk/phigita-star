def f(n):
    return (n-1)/5.*4.

def f6(n):
    return f(f(f(f(f(f(n))))))

print f(96.)
