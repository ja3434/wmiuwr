CC				:= gcc
CFLAGS 		:= -Og -std=gnu17 -Wall -Wall -fsanitize=address -fsanitize=undefined
TARGET 		:= router
DEPS			:= config.h

ODIR			:= obj
_OBJ	 		:= router.o utils.o linked_list.o network_addr.o dist_vector.o
OBJ				:= $(patsubst %,$(ODIR)/%,$(_OBJ))

all: $(TARGET)

$(ODIR)/%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -rf $(TARGET)
	rm -rf test

distclean:
	rm -rf $(TARGET)
	rm -rf test
	rm -rf $(ODIR)/*.o
