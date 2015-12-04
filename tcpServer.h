#include <sys/types.h>   /* basic system data types */
#include <sys/socket.h>  /* basic socket definitions */
// #include <sys/wait.h>
#include <netinet/in.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>

#define MAXLINE 8192
#define LISTENQ 16    /* max size of queue */

struct arg_struct {
	int conId;
	char* filename;
};

int writeData(const char*, char*);
int getOctaveProgramInfo(const char*, char*);
ssize_t readline(int, void *, size_t);
void* process_data(void *);
long long getCurrentTimeInMs();
int main(int, char *[]);
