!============================================================================
!
!   calculd.l       Dialog for expression calculation functions
!
!   Written:        91/10/07  Pieter Hintjens
!   Revised:        95/03/10
!
!============================================================================
-schema=lrschema.cpp
-idle
-source=calcul

After-Init:
    (--) Ok                                 -> Expecting-Operand
          + Get-Next-Token
    (--) Error                              -> 
          + Terminate-The-Program

Expecting-Operand:
    (--) String                             -> Expecting-Operator
          + Stack-The-String
          + Get-Next-Token
    (--) Number                             -> Expecting-Operator
          + Stack-The-Number
          + Get-Next-Token
    (--) Left-Par                           -> Expecting-Operand
          + Stack-The-Operator
          + Get-Next-Token
    (--) Function                           -> Expecting-Operand
          + Stack-The-Operator
          + Get-Next-Token

Expecting-Operator:
    (--) Operator                           -> Expecting-Operand
          + Unstack-Ge-Operators
          + Stack-The-Operator
          + Get-Next-Token
    (--) End-Mark                           -> 
          + Unstack-All-Operators
          + Unstack-If-End-Mark
          + Terminate-The-Program
    (--) Right-Par                          -> Expecting-Operator
          + Unstack-All-Operators
          + Unstack-If-Left-Par
          + Get-Next-Token

Defaults:
    (--) String                             -> 
          + Signal-Invalid-Token
          + Terminate-The-Program
    (--) Number                             -> 
          + Signal-Invalid-Token
          + Terminate-The-Program
    (--) Operator                           -> 
          + Signal-Invalid-Token
          + Terminate-The-Program
    (--) End-Mark                           -> 
          + Signal-Token-Missing
          + Terminate-The-Program
    (--) Exception                          -> 
          + Terminate-The-Program
    (--) Other                              -> 
          + Signal-Invalid-Token
          + Terminate-The-Program
    (--) Left-Par                           -> 
          + Signal-Invalid-Token
          + Terminate-The-Program
    (--) Right-Par                          -> 
          + Signal-Invalid-Token
          + Terminate-The-Program
    (--) Function                           -> 
          + Signal-Invalid-Token
          + Terminate-The-Program
