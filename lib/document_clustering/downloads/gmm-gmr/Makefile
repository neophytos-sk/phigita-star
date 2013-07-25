# gmr Makefile

SRCDIR=   ./src
INCDIR=   ./include
OBJDIR=   ./obj
OBJ=      main.o gmr.o Matrix.o Vector.o Macros.o
TARGET=   gmr

CPP = g++
CPPFLAGS += -g -O2 -Wall

# Path to matlab
MATLAB = /usr/local/matlab/bin/matlab


$(TARGET) : $(addprefix $(OBJDIR)/,$(OBJ)) 
	$(CPP) -o $@ $^

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CPP) $(CPPFLAGS) -I$(INCDIR) -c $< -o $@

plot : $(TARGET)
	./$(TARGET)
	cd matlab_src/
	$(MATLAB) -r "cd('matlab_src'); plotall"

clean : 
	@rm -f ./$(TARGET)
	@rm -f $(SRCDIR)/*.o
	@rm -f ./outdata/*.*
	@rm -f $(SRCDIR)/*~
	@rm -f $(SRCDIR)/*#
	@rm -f *~
	@rm -f *#


