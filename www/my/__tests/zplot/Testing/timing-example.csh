#! /bin/csh -f

# timing.data.raw 

@ t = 0
while ($t < 30)
    foreach i (10000 20000 30000 40000 50000 60000 70000 80000 90000 100000)
	echo "TIMING $i ITERATION $t"
	echo "TIMING $i ITERATION $t" >> timing.data.raw 
	./timing-example.tcl $i >> timing.data.raw 
    end
    @ t ++
end
