#!/usr/bin/tclsh
latex "\nonstopmode\documentclass{minimal}\usepackage{amsart}\begin{document}$$f(x)$$\end{document}"

set eqn {$$f(x)=x+5$$}


set tex {\nonstopmode
\documentclass[amsart]{article}
\pagestyle{empty}
\begin{document}
${eqn}
\end{document}
}

exec -- /bin/sh -c "latex ${tex}" || exit 0" > /dev/null