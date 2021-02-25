import pylab 

a = int(input("podaj liczbe: "))
b = int(input("podaj liczbe: "))

x = range(-10, 11) 
y = [] 
for i in x: 
    y.append(a * i + b) 
pylab.plot(x, y) 
pylab.title('Wykres f(x) = a*x - b') 
pylab.grid(True) 
pylab.show()
