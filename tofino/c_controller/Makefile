#
# A simple Makefile for a program and its BfRt Control Plane
#
ifndef SDE_INSTALL
$(error SDE_INSTALL is not set)
endif

PROG=controller

#
# Final targets
#
all: $(PROG)

#
# Simple P4 Compilation rules
#
P4C=bf-p4c
P4PPFLAGS=
P4FLAGS=-g --verbose 2 --target=$(P4TARGET)

P4TARGET=tofino
P4DIR=%.$(P4TARGET)

$(P4DIR) $(P4DIR)/bfrt.json $(P4DIR)/%.conf $(P4DIR)/pipe/context.json: %.p4
	$(P4C) $(P4PPFLAGS) $(P4FLAGS) $< 

p4: $(PROG).$(P4TARGET)

#
# C++ Compilation stuff
#
CPPFLAGS = -I$(SDE_INSTALL)/include -DSDE_INSTALL=\"$(SDE_INSTALL)\" \
           -DPROG_NAME=\"$(PROG)\"
CXXFLAGS = -g -std=c++11 -Wall -Wextra -Werror -MMD -MF $@.d
BF_LIBS  = -L$(SDE_INSTALL)/lib -lbf_switchd_lib -ldriver -lbfutils -lbfsys
LDLIBS   = $(BF_LIBS) -lm -ldl -lpthread
LDFLAGS  = -Wl,-rpath,$(SDE_INSTALL)/lib

DEPS := $(OBJS:.o=.o.d)

.PHONY: p4 all clean

clean:
	-@rm -rf $(PROG) *~ *.o *.d *.tofino *.tofino2 zlog-cfg-cur bf_drivers.log
