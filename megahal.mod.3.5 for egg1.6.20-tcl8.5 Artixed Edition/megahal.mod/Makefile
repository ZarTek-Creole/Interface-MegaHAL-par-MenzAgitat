# Makefile for src/mod/megahal.mod/

doofus:
	@echo ""
	@echo "Let's try this from the right directory..."
	@echo ""
	@cd ../../../; make

static: ../megahal.o

modules: ../../../megahal.so

../megahal.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -DMAKING_MODS -c $(srcdir)/megahal.c
	rm -f ../megahal.o
	mv megahal.o ../

../../../megahal.so: ../megahal.o
	$(LD) -o ../../../megahal.$(MOD_EXT) ../megahal.o $(XLIBS) $(MODULE_XLIBS)
	$(STRIP) ../../../megahal.$(MOD_EXT)

depend:
	$(CC) $(CFLAGS) -MM $(srcdir)/megahal.c -MT ../megahal.o > .depend

clean:
	@rm -f .depend *.o *.$(MOD_EXT) *~

distclean: clean

#safety hash


../megahal.o: megahal.c megahal.h ../module.h ../../../config.h \
 ../../main.h ../../lang.h ../../eggdrop.h ../../flags.h ../../proto.h \
 ../../../lush.h ../../cmdt.h ../../tclegg.h ../../tclhash.h \
 ../../chan.h ../../users.h ../modvals.h ../../tandem.h
