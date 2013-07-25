# tcl

namespace eval Zplot {
    # 
    # all the source files for zplot are included here
    # 

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

    # debugging stuff
    namespace export Debug

    # manipulating data
    namespace export Table
    namespace export TableStore
    namespace export TableSelect
    namespace export TableGetMax
    namespace export TableGetMin
    namespace export TableGetRange
    namespace export TableColNames
    namespace export TableGetNumRows
    namespace export TableGetVal
    namespace export TableAddRow
    namespace export TableBucketize
    namespace export TableMath
    namespace export TableAddColumns
    namespace export TableDump
    namespace export TableComputeMeanEtc

    # doing raw PS kinds of things
    namespace export PsCanvas
    namespace export PsCanvasInfo 
    namespace export PsRender
    namespace export PsCircle
    namespace export PsBox
    namespace export PsLine
    namespace export PsPolygon
    namespace export PsText
    namespace export PsRaw
    namespace export PsColors
    
    # the drawable abstraction
    namespace export Drawable
    namespace export Location

    # decorations
    namespace export AxisTicsLabels
    namespace export Axis
    namespace export TicMarks
    namespace export TicLabels

    # and more decorations
    namespace export Label
    namespace export Line

    # plot functions
    namespace export PlotHeat
    namespace export PlotVerticalBars
    namespace export PlotHorizontalBars
    namespace export PlotVerticalIntervals
    namespace export PlotHorizontalIntervals
    namespace export PlotPoints
    namespace export PlotLines
    namespace export PlotFunction
    namespace export PlotVerticalFill

    # making a legend 
    namespace export Legend
}











