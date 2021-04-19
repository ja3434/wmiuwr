CC				:= gcc
CFLAGS 		:= -Og -std=gnu17 -Wall -Wall -fsanitize=address -fsanitize=undefined
TARGET 		:= router
TEST 			:= test
DEPS			:= config.h

ODIR			:= obj
_OBJ	 		:= router.o utils.o linked_list.o network_addr.o dist_vector.o
OBJ				:= $(patsubst %,$(ODIR)/%,$(_OBJ))

_TEST_OBJ := test.o linked_list.o
TEST_OBJ  := $(patsubst %,$(ODIR)/%,$(_TEST_OBJ))


all: $(TARGET)
test: $(TEST)

$(ODIR)/%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

$(TEST): $(TEST_OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -rf $(TARGET)
	rm -rf test

distclean:
	rm -rf $(TARGET)
	rm -rf test
	rm -rf $(ODIR)/*.o
