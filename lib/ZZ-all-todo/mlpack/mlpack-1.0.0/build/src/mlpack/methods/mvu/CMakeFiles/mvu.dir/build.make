# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canoncical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# The program to use to edit the cache.
CMAKE_EDIT_COMMAND = /usr/bin/ccmake

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /web/service-phgt-0/lib/mlpack/mlpack-1.0.0

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build

# Include any dependencies generated for this target.
include src/mlpack/methods/mvu/CMakeFiles/mvu.dir/depend.make

# Include the progress variables for this target.
include src/mlpack/methods/mvu/CMakeFiles/mvu.dir/progress.make

# Include the compile flags for this target's objects.
include src/mlpack/methods/mvu/CMakeFiles/mvu.dir/flags.make

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o: src/mlpack/methods/mvu/CMakeFiles/mvu.dir/flags.make
src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o: ../src/mlpack/methods/mvu/mvu_main.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o"
	cd /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/src/mlpack/methods/mvu && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/mvu.dir/mvu_main.cpp.o -c /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/src/mlpack/methods/mvu/mvu_main.cpp

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/mvu.dir/mvu_main.cpp.i"
	cd /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/src/mlpack/methods/mvu && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/src/mlpack/methods/mvu/mvu_main.cpp > CMakeFiles/mvu.dir/mvu_main.cpp.i

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/mvu.dir/mvu_main.cpp.s"
	cd /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/src/mlpack/methods/mvu && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/src/mlpack/methods/mvu/mvu_main.cpp -o CMakeFiles/mvu.dir/mvu_main.cpp.s

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.requires:
.PHONY : src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.requires

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.provides: src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.requires
	$(MAKE) -f src/mlpack/methods/mvu/CMakeFiles/mvu.dir/build.make src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.provides.build
.PHONY : src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.provides

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.provides.build: src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o

# Object files for target mvu
mvu_OBJECTS = \
"CMakeFiles/mvu.dir/mvu_main.cpp.o"

# External object files for target mvu
mvu_EXTERNAL_OBJECTS =

bin/mvu: src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o
bin/mvu: lib/libmlpack.so.1.0.0
bin/mvu: src/mlpack/methods/mvu/CMakeFiles/mvu.dir/build.make
bin/mvu: src/mlpack/methods/mvu/CMakeFiles/mvu.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable ../../../../bin/mvu"
	cd /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/src/mlpack/methods/mvu && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/mvu.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/mlpack/methods/mvu/CMakeFiles/mvu.dir/build: bin/mvu
.PHONY : src/mlpack/methods/mvu/CMakeFiles/mvu.dir/build

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/requires: src/mlpack/methods/mvu/CMakeFiles/mvu.dir/mvu_main.cpp.o.requires
.PHONY : src/mlpack/methods/mvu/CMakeFiles/mvu.dir/requires

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/clean:
	cd /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/src/mlpack/methods/mvu && $(CMAKE_COMMAND) -P CMakeFiles/mvu.dir/cmake_clean.cmake
.PHONY : src/mlpack/methods/mvu/CMakeFiles/mvu.dir/clean

src/mlpack/methods/mvu/CMakeFiles/mvu.dir/depend:
	cd /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /web/service-phgt-0/lib/mlpack/mlpack-1.0.0 /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/src/mlpack/methods/mvu /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/src/mlpack/methods/mvu /web/service-phgt-0/lib/mlpack/mlpack-1.0.0/build/src/mlpack/methods/mvu/CMakeFiles/mvu.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/mlpack/methods/mvu/CMakeFiles/mvu.dir/depend

