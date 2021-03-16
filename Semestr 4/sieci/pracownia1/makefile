CC=gcc
CFLAGS=-g -Wall -Wextra -Wshadow -pedantic -fsanitize=address -fsanitize=undefined

TARGET=traceroute

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c

clean:
	$(RM) $(TARGET)