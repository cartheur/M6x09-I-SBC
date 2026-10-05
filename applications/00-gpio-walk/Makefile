BS9 ?= ../../crosscompiler/bs9
PROGRAM := gpio_walk

all: $(PROGRAM).s19

$(PROGRAM).s19: $(PROGRAM).as9 ../common/m6x09_i.inc
	$(BS9) $(PROGRAM)
	test -s $@
	grep -q '^S1' $@

clean:
	rm -f $(PROGRAM).lst $(PROGRAM).s19

.PHONY: all clean
