#!/web/bin/sh
echo "\documentclass[amsart]{article}
\pagestyle{empty}
\begin{document}
$1
\end{document}" > $2.tex
./textopng.sh $2
