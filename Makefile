CC = gcc
CFLAGS = -Wall
CLI = tcpClient
SERVER = tcpServer
$(SERVER):  $(SERVER).o
	$(CC) $(CFLAGS) -o $(SERVER) $(SERVER).o
$(SERVER).o: $(SERVER).c
	$(CC) $(CFLAGS) -c $(SERVER).c
clean:
	rm -f *~ *.o $(CLI) $(SERVER)
