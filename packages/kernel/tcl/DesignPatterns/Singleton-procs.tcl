Class Singleton -superclass Class

Singleton instproc new args {
  expr {[my exists instance] ? [my set instance] : [my set instance [next]]}
}
