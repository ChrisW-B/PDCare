CC = gcc
CFLAGS = -Wall
SERVER = pdcareServer
$(SERVER):  $(SERVER).o
	$(CC) $(CFLAGS) -o $(SERVER) $(SERVER).o
$(SERVER).o: $(SERVER).c
	$(CC) $(CFLAGS) -c $(SERVER).c
clean:
	rm -f *~ *.o $(CLI) $(SERVER)
