doc_return 200 text/plain "unfinished code"
return

set libdir [acs_root_dir]/packages/tools/lib/

package require critcl
::critcl::config force 1
::critcl::config keepsrc 0
::critcl::config language c++
::critcl::clibraries -lstdc++

::critcl::ccode {

    class Bond {
    public:
      virtual void WhatAmI (void) { cout << "Bond\n"; }
    };
    class Warrant : public Bond {
    public:
      void WhatAmI (void) { cout << "Warrant\n"; }
    };

    void Leppard(void) {
      Warrant * w = new Warrant;
      Bond * b = w;
      w->WhatAmI();
      b->WhatAmI();
    }

}
