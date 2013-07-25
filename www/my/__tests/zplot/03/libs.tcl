# tcl

namespace eval Zplot {
    # all the source files for zplot are included here
    source util.tcl
    source args.tcl
    source ps.tcl
    source drawable.tcl
    source style.tcl
    source plot.tcl
    source draw.tcl
    source axis.tcl
    source legend.tcl
    source table.tcl

    # 
    # these are the names of available routines (all else are internal)
    # 

    # manipulating data
    namespace export Table
    namespace export TableLoad
    namespace export TableStore
    namespace export TableSelect
    namespace export TableColNames
    namespace export TableGetNumRows
    namespace export TableGetVal
    namespace export TableAddVal

    # doing raw PS kinds of things
    namespace export PsCanvas
    namespace export PsRender
    namespace export PsCircle
    namespace export PsBox
    namespace export PsLine
    namespace export PsRaw
    
    # the drawable abstraction
    namespace export Drawable
    namespace export Location

    # decorations
    namespace export Axis
    namespace export Axis2
    namespace export TicMarks
    namespace export TicLabels

    # and more decorations
    namespace export Label
    namespace export Line

    # plot functions
    namespace export PlotHeat
    namespace export PlotVerticalBars
    namespace export PlotVerticalIntervals
    namespace export PlotHorizontalBars
    namespace export PlotPoints

    # making a legend 
    namespace export Legend
}











