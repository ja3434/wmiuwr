CC	:= gcc
CFLAGS 	:= -Og -std=gnu17 -Wall -Wall -fsanitize=address -fsanitize=undefined
TARGET 	:= router

all: $(TARGET)
test: test

utils.o: utils.c
	$(CC) $(CFLAGS) -c utils.c

network_addr.o: network_addr.c
	$(CC) $(CFLAGS) -c network_addr.c

router.o: router.c
	$(CC) $(CFLAGS) -c $(TARGET).c

linked_list.o: linked_list.c
	$(CC) $(CFLAGS) -c linked_list.c

router: utils.o network_addr.o linked_list.o router.o
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).o network_addr.o utils.o linked_list.o

test.o: test.c
	$(CC) $(CFLAGS) -c test.c

test: linked_list.o test.o 
	$(CC) $(CFLAGS) -o test test.o linked_list.o

clean:
	rm -rf $(TARGET)
	rm -rf test

distclean:
	rm -rf $(TARGET)
	rm -rf test
	rm -rf *.o
