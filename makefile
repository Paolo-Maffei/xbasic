###################
# XBASIC Makefile #
###################

SRCDIR=src
SPINDIR=spin
OBJDIR=obj/$(OS)
BINDIR=bin/$(OS)
DRVDIR=include

DIRS = $(OBJDIR) $(BINDIR)

CC=gcc
ECHO=echo
MKDIR=mkdir -p

CFLAGS=-I$(SRCDIR)/common -I$(SRCDIR)/runtime -I$(SRCDIR)/loader
LDFLAGS=$(CFLAGS)
SPINFLAGS=-Ogxr

ifeq ($(OS),linux)
CFLAGS += -DLINUX
BSTC=bstc.linux
EXT=
OSINT=osint_linux
endif

ifeq ($(OS),cygwin)
CFLAGS += -DCYGWIN
BSTC=bstc
EXT=.exe
OSINT=osint_cygwin
endif

ifeq ($(OS),macosx)
CFLAGS += -DMACOSX
BSTC=bstc.osx
EXT=
OSINT=osint_linux
endif

##################
# DEFAULT TARGET #
##################

.PHONY:	all
all:	xbcom xload xbint bin2xbasic cache-drivers

run:
	$(BINDIR)/xbcom -p15 coginit.bas -r -t

#################
# CLEAN TARGETS #
#################

.PHONY:	clean
clean:
	@rm -f -r $(OBJDIR)
	@rm -f -r $(BINDIR)
	@rm -f $(DRVDIR)/*.dat
	@rm -f samples/*.bai
	@rm -f samples/*.dat
	@rm -f samples/*.tmp
	@rm -f samples/*/*.bai
	@rm -f samples/*/*.dat
	@rm -f samples/*/*.tmp
	
.PHONY:	clean-all
clean-all:	clean
	@rm -f -r obj
	@rm -f -r bin
	
#####################
# OBJECT FILE LISTS #
#####################

COMOBJS=\
$(OBJDIR)/db_compiler.o \
$(OBJDIR)/db_expr.o \
$(OBJDIR)/db_generate.o \
$(OBJDIR)/db_wrimage.o \
$(OBJDIR)/db_scan.o \
$(OBJDIR)/db_statement.o \
$(OBJDIR)/db_symbols.o \
$(OBJDIR)/db_types.o \
$(OBJDIR)/db_config.o

INTOBJS=\
$(OBJDIR)/db_vmfcn.o \
$(OBJDIR)/db_vmimage.o \
$(OBJDIR)/db_vmint.o \
$(OBJDIR)/db_runtime.o

COMMONOBJS=\
$(OBJDIR)/db_vmdebug.o \
$(OBJDIR)/db_system.o \
$(OBJDIR)/db_platform.o

LOADEROBJS=\
$(OBJDIR)/db_loader.o \
$(OBJDIR)/db_packet.o \
$(OBJDIR)/PLoadLib.o \
$(OBJDIR)/$(OSINT).o \
$(OBJDIR)/serial_helper.o \
$(OBJDIR)/hub_loader.o \
$(OBJDIR)/flash_loader.o \
$(OBJDIR)/xbasic_vm.o

XBCOMOBJS=\
$(OBJDIR)/xbcom.o \
$(COMOBJS) \
$(COMMONOBJS) \
$(LOADEROBJS)

XBINTOBJS=\
$(OBJDIR)/xbint.o \
$(INTOBJS) \
$(COMMONOBJS)

XLOADOBJS=\
$(OBJDIR)/xload.o \
$(LOADEROBJS) \
$(OBJDIR)/db_config.o \
$(OBJDIR)/db_platform.o

HDRS=\
$(SRCDIR)/compiler/db_compiler.h \
$(SRCDIR)/runtime/db_vm.h \
$(SRCDIR)/runtime/db_vmdebug.h \
$(SRCDIR)/common/db_image.h \
$(SRCDIR)/common/db_config.h

############################################
# SOURCES NEEDED BY THE VISUAL C++ PROJECT #
############################################

HELPER_SRCS=\
$(OBJDIR)/serial_helper.c \
$(OBJDIR)/hub_loader.c \
$(OBJDIR)/flash_loader.c \
$(OBJDIR)/xbasic_vm.c

.PHONY:	spin-binaries
spin-binaries:	$(OBJDIR) bin2c $(HELPER_SRCS)

SPIN_SRCS=\
$(SPINDIR)/serial_helper.spin \
$(SPINDIR)/hub_loader.spin \
$(SPINDIR)/flash_loader.spin \
$(SPINDIR)/packet_driver.spin \
$(SPINDIR)/vm_runtime.spin \
$(SPINDIR)/vm_interface.spin \
$(SPINDIR)/cache_interface.spin \
$(SPINDIR)/TV.spin \
$(SPINDIR)/TV_Text.spin \
$(SPINDIR)/FullDuplexSerial.spin \
$(SPINDIR)/xbasic_vm.spin \
$(SPINDIR)/c3_cache.spin \
$(SPINDIR)/ssf_cache.spin

#################
# CACHE DRIVERS #
#################

CACHE_DRIVERS=\
$(DRVDIR)/c3_cache.dat \
$(DRVDIR)/ssf_cache.dat

.PHONY:	cache-drivers
cache-drivers:	$(CACHE_DRIVERS)

##################
# SPIN TO BINARY #
##################

$(OBJDIR)/serial_helper.binary:	$(SPINDIR)/serial_helper.spin $(SPIN_SRCS)
	@$(BSTC) $(SPINFLAGS) -b -o $(basename $@) $<
	@$(ECHO) $@

$(OBJDIR)/%_loader.binary:	$(SPINDIR)/%_loader.spin $(SPIN_SRCS)
	@$(BSTC) $(SPINFLAGS) -b -o $(basename $@) $<
	@$(ECHO) $@

$(OBJDIR)/%.c:	$(OBJDIR)/%.binary
	@$(BINDIR)/bin2c$(EXT) $< $@
	@$(ECHO) $@

###############
# SPIN TO DAT #
###############

$(DRVDIR)/%.dat:	$(SPINDIR)/%.spin $(SPIN_SRCS)
	@$(BSTC) $(SPINFLAGS) -c -o $(basename $@) $<
	@$(ECHO) $@

$(OBJDIR)/%.dat:	$(SPINDIR)/%.spin $(SPIN_SRCS)
	@$(BSTC) $(SPINFLAGS) -c -o $(basename $@) $<
	@$(ECHO) $@

$(OBJDIR)/%.c:	$(OBJDIR)/%.dat
	@$(BINDIR)/bin2c$(EXT) $< $@
	@$(ECHO) $@

################
# MAIN TARGETS #
################

.PHONY:	xbcom
xbcom:		$(BINDIR)/xbcom$(EXT)

$(BINDIR)/xbcom$(EXT):	$(BINDIR) $(OBJDIR) bin2c $(XBCOMOBJS)
	@$(CC) $(LDFLAGS) $(XBCOMOBJS) -o $@
	@$(ECHO) $@

.PHONY:	xbint
xbint:		$(BINDIR)/xbint$(EXT)

$(BINDIR)/xbint$(EXT):	$(BINDIR) $(OBJDIR) $(XBINTOBJS)
	@$(CC) $(LDFLAGS) $(XBINTOBJS) -o $@
	@$(ECHO) $@

.PHONY:	xload
xload:		$(BINDIR)/xload$(EXT)

$(BINDIR)/xload$(EXT):	$(BINDIR) $(OBJDIR) bin2c $(XLOADOBJS)
	@$(CC) $(LDFLAGS) $(XLOADOBJS) -o $@
	@$(ECHO) $@

#########
# RULES #
#########

$(OBJDIR)/%.o:	$(SRCDIR)/compiler/%.c $(HDRS)
	@$(CC) $(CFLAGS) -c $< -o $@
	@$(ECHO) $@

$(OBJDIR)/%.o:	$(SRCDIR)/runtime/%.c $(HDRS)
	@$(CC) $(CFLAGS) -c $< -o $@
	@$(ECHO) $@

$(OBJDIR)/%.o:	$(SRCDIR)/loader/%.c $(HDRS)
	@$(CC) $(CFLAGS) -c $< -o $@
	@$(ECHO) $@

$(OBJDIR)/%.o:	$(SRCDIR)/common/%.c $(HDRS)
	@$(CC) $(CFLAGS) -c $< -o $@
	@$(ECHO) $@

$(OBJDIR)/%.o:	$(OBJDIR)/%.c $(HDRS)
	@$(CC) $(CFLAGS) -c $< -o $@
	@$(ECHO) $@

#########
# TOOLS #
#########

.PHONY:	bin2c
bin2c:		$(BINDIR)/bin2c$(EXT)

$(BINDIR)/bin2c$(EXT):	$(OBJDIR) $(SRCDIR)/tools/bin2c.c
	@$(CC) $(CFLAGS) $(LDFLAGS) $(SRCDIR)/tools/bin2c.c -o $@
	@$(ECHO) $@

.PHONY:	bin2xbasic
bin2xbasic:		$(BINDIR)/bin2xbasic$(EXT)

$(BINDIR)/bin2xbasic$(EXT):	$(BINDIR) $(OBJDIR) $(SRCDIR)/tools/bin2xbasic.c
	@$(CC) $(CFLAGS) $(LDFLAGS) $(SRCDIR)/tools/bin2xbasic.c -o $@
	@$(ECHO) $@

###############
# DIRECTORIES #
###############

$(DIRS):
	$(MKDIR) $@

##################
# RELEASE TARGET #
##################

.PHONY:	release
release:
	rm -rf ../xbasic-rel/xbasic
	mkdir -p ../xbasic-rel/xbasic
	cp -r src ../xbasic-rel/xbasic
	cp -r pasm ../xbasic-rel/xbasic
	cp -r spin ../xbasic-rel/xbasic
	cp -r include ../xbasic-rel/xbasic
	cp -r samples ../xbasic-rel/xbasic
	cp syntax.txt ../xbasic-rel/xbasic
	cp makefile* ../xbasic-rel/xbasic
	cp setenv.* ../xbasic-rel/xbasic
	cp *.docx ../xbasic-rel/xbasic
