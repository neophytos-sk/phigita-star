emerge -av blas-atlas lapack-atlas
for x in blas cblas lapack; do sudo eselect $x set atlas; done
#emerge -av clapack
USE="lapack" emerge -av numpy scipy

# emerge -av qhull


# PIL - python imaging library
emerge -av imaging

