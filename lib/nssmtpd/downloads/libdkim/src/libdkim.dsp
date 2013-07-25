# Microsoft Developer Studio Project File - Name="libdkim" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=libdkim - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "libdkim.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "libdkim.mak" CFG="libdkim - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "libdkim - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "libdkim - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "libdkim - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f libdkim.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "libdkim.exe"
# PROP BASE Bsc_Name "libdkim.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "nmake /f "makefile.vc""
# PROP Rebuild_Opt "/a"
# PROP Target_File "Release\libdkim.dll"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "libdkim - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Cmd_Line "NMAKE /f libdkim.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "libdkim.exe"
# PROP BASE Bsc_Name "libdkim.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Cmd_Line "nmake /f "makefile.vc" DEBUG=1"
# PROP Rebuild_Opt "/a"
# PROP Target_File "Debug\libdkim.dll"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "libdkim - Win32 Release"
# Name "libdkim - Win32 Debug"

!IF  "$(CFG)" == "libdkim - Win32 Release"

!ELSEIF  "$(CFG)" == "libdkim - Win32 Debug"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\dkim.cpp
# End Source File
# Begin Source File

SOURCE=.\dkimbase.cpp
# End Source File
# Begin Source File

SOURCE=.\dkimsign.cpp
# End Source File
# Begin Source File

SOURCE=.\dkimverify.cpp
# End Source File
# Begin Source File

SOURCE=.\dns.cpp
# End Source File
# Begin Source File

SOURCE=.\dnsresolv.cpp
# End Source File
# Begin Source File

SOURCE=.\libdkimtest.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\dkim.h
# End Source File
# Begin Source File

SOURCE=.\dkimbase.h
# End Source File
# Begin Source File

SOURCE=.\dkimsign.h
# End Source File
# Begin Source File

SOURCE=.\dkimverify.h
# End Source File
# Begin Source File

SOURCE=.\dns.h
# End Source File
# Begin Source File

SOURCE=.\dnsresolv.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Source File

SOURCE=.\libdkim.def
# End Source File
# Begin Source File

SOURCE=.\Makefile.vc
# End Source File
# End Target
# End Project
