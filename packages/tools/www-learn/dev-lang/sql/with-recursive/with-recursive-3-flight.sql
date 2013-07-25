with recursive
     Route(orig,dest,total,length) as
     (select orig,dest,cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total, R.length+1 as length
     from Route R, Flight F
     where R.length<10 and R.dest=F.orig)
select * from Route
where orig='A' and dest='B';

with recursive
     Route(orig,dest,total) as
     (select orig,dest,cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total
     from Route R, Flight F
     where R.dest=F.orig)
select * from Route
where orig='A' and dest='B';

with recursive
     FromA(dest,total) as
     (select dest,cost as total from Flight where orig='A'
     union
     select F.dest, cost+total as total
     from FromA FA, Flight F
     where FA.dest=F.orig)
select * from FromA
where dest='B';


with recursive
     ToB(orig,total) as
     (select orig,cost as total from Flight where orig='B'
     union
     select TB.orig, cost+total as total
     from Flight F, ToB TB
     where F.dest=TB.orig)
select * from ToB
where orig='A';