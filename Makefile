#   'Confusion', a MDL intepreter
#   Copyright 2009 Matthew T. Russotto
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

CDEBUGFLAGS = -g -DGC_DEBUG
COPTFLAGS = -O2
CWARNFLAGS =  -Wall -Wno-switch
GC_CFLAGS := $(shell pkg-config --cflags bdw-gc 2>/dev/null || echo "-I/opt/homebrew/include")
GC_LIBS := $(shell pkg-config --libs bdw-gc 2>/dev/null || echo "-L/opt/homebrew/lib -lgc")
LIBS = $(GC_LIBS) -lgccpp
CFLAGS = $(CDEBUGFLAGS) $(COPTFLAGS) $(CWARNFLAGS) $(GC_CFLAGS)
CXXFLAGS = $(CDEBUGFLAGS) $(COPTFLAGS) $(CWARNFLAGS) $(GC_CFLAGS)

PERL = perl

PROGRAMS = mdli

TMPSRCS = mdl_builtins.cpp mdl_builtin_types.cpp mdl_builtin_types.h mdl_builtins.h copying.c

CXXSRCS = macros.cpp mdli.cpp mdl_builtins.cpp mdl_builtin_types.cpp mdl_read.cpp mdl_output.cpp mdl_binary_io.cpp mdl_decl.cpp mdl_assoc.cpp

CSRCS = mdl_strbuf.c copying.c

OBJS = $(CXXSRCS:.cpp=.o) $(CSRCS:.c=.o)

mdli: $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LIBS)

copying.c: COPYING
	awk 'BEGIN { print "const char copying [] = " } /END OF TERMS AND CONDITIONS/ { nextfile } { gsub("\"", "\\\"", $$0); print "\"" $$0 "\\n\""  } END { print ";" }'  < COPYING > copying.c

mdl_builtins.o: mdl_builtins.h

mdl_builtins.cpp: macros.cpp
	$(PERL) find_builtins.pl $(@:.cpp=.h) < $< > $@	

mdl_builtin_types.o: mdl_builtin_types.h
mdl_builtin_types.h: mdl_builtin_types.cpp ;
mdl_builtins.h: mdl_builtins.cpp ;

mdl_builtin_types.cpp: macros.hpp mdl_builtins.h
	$(PERL) make_types.pl $(@:.cpp=.h) < $< > $@	

macros.o: mdl_builtin_types.h mdl_builtins.h mdl_internal_defs.h
mdl_output.o: mdl_builtin_types.h mdl_builtins.h mdl_internal_defs.h
mdl_read.o: mdl_builtin_types.h mdl_builtins.h mdl_internal_defs.h
mdl_binary_io.o: mdl_builtin_types.h mdl_builtins.h mdl_internal_defs.h

clean: 
	rm -f *.o *~ $(PROGRAMS)

extraclean: clean
	rm -f $(TMPSRCS)
