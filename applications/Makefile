SUBDIRS := 00-gpio-walk 01-serial-hello 02-ideal010

all:
	@for directory in $(SUBDIRS); do $(MAKE) -C $$directory; done

clean:
	@for directory in $(SUBDIRS); do $(MAKE) -C $$directory clean; done

.PHONY: all clean
