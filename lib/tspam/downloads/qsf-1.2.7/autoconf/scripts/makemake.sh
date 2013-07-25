#!/bin/sh
#
# Generate Makefile dependencies inclusion and module target file "depend.mk"
# by scanning the directory "src" for files ending in ".c" and ".d", and for
# subdirectories not starting with "_".
#
# Modules live inside subdirectories called [^_]* - i.e. a directory "foo" will
# have a rule created which links all code inside it to "foo.o".
#
# The directory "src/include" is never scanned; neither are CVS directories.
#

outlist=$1
outlink=$2

FIND=find
GREP=grep
which gfind 2>/dev/null | grep /gfind >/dev/null && FIND=gfind
which ggrep 2>/dev/null | grep /ggrep >/dev/null && GREP=ggrep

echo '# Automatically generated file listings' > $outlist
echo '#' >> $outlist
echo "# Creation time: `date`" >> $outlist
echo >> $outlist

echo '# Automatically generated module linking rules' > $outlink
echo '#' >> $outlink
echo "# Creation time: `date`" >> $outlink
echo >> $outlink

case `echo "testing\c"; echo 1,2,3`,`echo -n testing; echo 1,2,3` in
  *c*,-n*) ECHO_N= ECHO_C='
' ECHO_T='	' ;;
  *c*,*  ) ECHO_N=-n ECHO_C= ECHO_T= ;;
  *)       ECHO_N= ECHO_C='\c' ECHO_T= ;;
esac

echo $ECHO_N "Scanning for source files: $ECHO_C"

allsrc=`$FIND src -type f -name "*.c" -print`
allobj=`echo $allsrc | tr ' ' '\n' | sed 's/\.c$/.o/'`
alldep=`echo $allsrc | tr ' ' '\n' | sed 's/\.c$/.d/'`

echo `echo $allsrc | wc -w | tr -d ' '` found

echo $ECHO_N "Scanning for modules: $ECHO_C"

modules=`$FIND src -type d -print \
         | $GREP -v '^src$' \
         | $GREP -v '/_' \
         | $GREP -v '^src/include' \
         | $GREP -v 'CVS' \
         | while read DIR; do \
           CONTENT=\$(/bin/ls -d \$DIR/* \
                     | $GREP -v '.po$' \
                     | $GREP -v '.gmo$' \
                     | $GREP -v '.mo$' \
                     | $GREP -v '.h$' \
                     | sed -n '$p'); \
           [ -n "\$CONTENT" ] || continue; \
           echo \$DIR; \
	   done
         `

echo up to `echo $modules | wc -w | tr -d ' '` found

echo "Writing module linking rules"

echo $ECHO_N "[$ECHO_C"
for i in $modules; do echo $ECHO_N " $ECHO_C"; done
echo $ECHO_N -e "]\r[$ECHO_C"

for i in $modules; do
  echo $ECHO_N ".$ECHO_C"
  allobj="$allobj $i.o"
  deps=""
  for j in $i/*.c; do
    [ -f $j ] || continue
    newobj=`echo $j | sed -e 's@\.c$@.o@'`
    deps="$deps $newobj"
  done
  for j in $i/*; do
    [ -d "$j" ] || continue
    [ `basename $j` = "CVS" ] && continue
    CONTENT=`/bin/ls -d $j/* \
             | $GREP -v '.po$' \
             | $GREP -v '.gmo$' \
             | $GREP -v '.mo$' \
             | $GREP -v '.h$' \
             | sed -n '$p'`
    [ -n "$CONTENT" ] || continue
    deps="$deps $j.o"
  done
  [ -n "$deps" ] || continue
  echo "$i.o: $deps" >> $outlink
  echo '	$(LD) $(LDFLAGS) -o $@' "$deps" >> $outlink
  echo >> $outlink
done

echo ']'

echo "Listing source, object and dependency files"

echo $ECHO_N "allsrc = $ECHO_C" >> $outlist
echo $allsrc | sed 's,src/nls/cat-id-tbl.c,,' | sed -e 's/ / \\!/g'\
| tr '!' '\n' >> $outlist
echo >> $outlist
echo $ECHO_N "allobj = $ECHO_C" >> $outlist
echo $allobj | sed -e 's/ / \\!/g' | tr '!' '\n' >> $outlist
echo >> $outlist
echo $ECHO_N "alldep = $ECHO_C" >> $outlist
echo $alldep | sed -e 's/ / \\!/g' | tr '!' '\n' >> $outlist

echo >> $outlist
echo >> $outlink

# EOF
