CC=gcc
CFLAGS=-std=gnu17 -O2 -Wall -Wextra
TARGET=traceroute

all: $(TARGET)

$(TARGET): $(TARGET).o
	$(CC) -o $(TARGET) $(TARGET).o 


$(TARGET).o: $(TARGET).c
	$(CC) $(CFLAGS) -c $(TARGET).c

distclean:
	$(RM) $(TARGET)
	$(RM) $(TARGET).o

clean:
	$(RM) $(TARGET).o
