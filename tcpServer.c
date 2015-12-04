#include "tcpServer.h"

int main(int argc, char *argv[])
{
	struct sockaddr_in sAddr;
	int sockfd, connfd, status, val;
	pthread_t thread_id;
	char filename[50];

	sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	val = 1;
	status = setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val));
	if (status < 0) {
		perror("Error - port");
		return 0;
	}

	sAddr.sin_family = AF_INET;
	sAddr.sin_port = htons(443);
	sAddr.sin_addr.s_addr = INADDR_ANY;

	status = bind(sockfd, (struct sockaddr *) &sAddr, sizeof(sAddr));
	if (status < 0) {
		perror("Error - Bind");
		return 0;
	}

	status = listen(sockfd, 5);
	if (status < 0) {
		perror("Error - Listen");
		return 0;
	}
	while (1) {
		connfd = accept(sockfd, NULL, NULL);
		if (connfd < 0) {
			printf("Accept error on server\n");
			return 0;
		}
		struct arg_struct args;
		args.conId = connfd;


		sprintf(filename, "patients/patient-%lld.txt", getCurrentTimeInMs());
		args.filename = filename;
		printf("client connected to child thread %i with pid %i.\n", (int)pthread_self(), getpid());
		status = pthread_create(&thread_id, NULL, process_data, (void*)&args);
		if (status != 0) {
			printf("Could not create thread.\n");
			return 0;
		}
		sched_yield();
	}
	pthread_join (thread_id, NULL);
}

long long getCurrentTimeInMs() {
	struct timeval te;
	gettimeofday(&te, NULL); // get current time
	return te.tv_sec * 1000LL + te.tv_usec / 1000;
}

//thread to handle each call to the server, which takes a void pointer of arguments
//this pointer is expected to be a arg_struct, containing
//connectionID and filename
void* process_data(void *arguments)
{
	char line[MAXLINE], result[MAXLINE];
	struct arg_struct *args = arguments;
	int sockfd = args->conId, error = 0;

	char* filename = args->filename;

	for ( ; ; ) {
		int n;
		printf("writing to %s\n", filename);
		if ((n = readline(sockfd, line, MAXLINE)) <= 0) {
			break;
		}
		printf("writing to %s\n", filename);
		if (writeData(filename, line) == -1) {
			printf("Error writing data\n");
			error = 1;
		}
	}
	if (getOctaveProgramInfo(filename, result) == -1) {
		printf("error getting octave\n");
		error = 1;
	}
	printf("error is %d, result[0] is %c \n", error, result[0]);
	if (result[0] != '0' && result[0] != '1') {//make sure only valid data is returned
		error = 1;
		printf("result does not start with 0 or 1");
	}
	if (error) {
		write(sockfd, "-1\0", 3);
		time_t rawtime;
		struct tm * timeinfo;
		time (&rawtime);
		timeinfo = localtime (&rawtime);
		printf("Error at %s\n", asctime(timeinfo));
	}
	else {
		write(sockfd, result, MAXLINE);
	}
	return NULL;
}

//continuously reads in new lines until it receives an end of file,
//takes a file descriptor, a starting pointer, and the max accepted size
//returns the size read
ssize_t readline(int fd, void *vptr, size_t maxlen)
{
	int n, rc;
	char c, *ptr;
	ptr = vptr;
	for (n = 1; n < maxlen; n++) {
		if ( (rc = read(fd, &c, 1)) == 1) {
			if (c == '\b') {
				return 0;
			} else if (c == '\r') {
				break;
			} else {
				*ptr++ = c;
			}
		} else if (rc == 0) {
			if (n == 1)
				return (0);     /* EOF, no data read */
			else
				break;          /* EOF, some data was read */
		} else
			return (-1);            /* error, errno set by read() */
	}
	*ptr = 0;       /* null terminate like fgets() */
	return (n);
}

//calls octave program and writes its response to a string
//takes a file location and response pointer, which it writes to
//returns 0 if successful, -1 otherwise
int getOctaveProgramInfo(const char* fileLoc, char* response)
{
	int status, filedes[2];
	if (pipe(filedes) == -1) {
		perror("pipe");
		return -1;
	}
	pid_t pid = fork();
	if (pid == -1) {
		perror("fork");
		return -1;
	} else if (pid == 0) {
		while ((dup2(filedes[1], STDOUT_FILENO) == -1) && (errno == EINTR)) {}
		close(filedes[1]);
		close(filedes[0]);

		char newLoc[55];
		sprintf(newLoc, "../%s", fileLoc);
		chdir("scripts/");
		execl("/usr/bin/octave",
		      "octave",
		      "--silent",
		      "do_test.m",
		      newLoc,
		      NULL);
		perror("execl");
	}
	else {
		waitpid(pid, &status, 0);
		read(filedes[0], response, MAXLINE);
		printf("%s\n", response);
	}
	close(filedes[1]);
	return 0;
}

//writes a string to a file for later
//takes a filename and the contents to be written to the file
//returns 0 if sucessful, -1 otherwise
int writeData(const char* filename, char* contents)
{
	FILE *f = fopen(filename, "a+");
	if (f == NULL)
	{
		printf("Error opening file %s\n", filename);
		return -1;
	}
	fprintf(f, "%s", contents);
	fclose(f);
	return 0;
}
