#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <poll.h>
#include <stdbool.h>
#include "config.h"

#define NS_TO_MS(X) ((long)(X) / (long)1000000)
#define S_TO_MS(X) ((long)(X) * (long)1000)

int get_socket() {
  int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0) {
    fprintf(stderr, "socket error: %s", strerror(errno));
    exit(EXIT_FAILURE);
  }
  return sockfd;
}

size_t send_datagram(int sockfd, struct sockaddr_in server_address, char *buffer, size_t buffer_len) {
  return sendto(sockfd, buffer, buffer_len, 0, (struct sockaddr*) &server_address, sizeof(server_address));
}

void send_data_request(int sockfd, struct sockaddr_in server_address, size_t pos, size_t bytes) {
  char buffer[40];
  sprintf(buffer, "GET %ld %ld\n", pos, bytes);
  size_t buffer_len = strlen(buffer);
  if (send_datagram(sockfd, server_address, buffer, buffer_len) != buffer_len) {
    fprintf(stderr, "sendto error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
}

long get_time_interval(struct timespec start, struct timespec finish) {
  return S_TO_MS(finish.tv_sec - start.tv_sec) + NS_TO_MS(finish.tv_nsec - start.tv_nsec);
}

int poll_socket_modify_timeout(int sockfd, int *timeout) {
  if (*timeout < 0) {
    *timeout = 0;
    return 0;
  }

  struct pollfd fds;
  struct timespec start;
  struct timespec finish;
  
  fds.fd = sockfd;
  fds.events = POLLIN;
  fds.revents = 0;
  
  clock_gettime(CLOCK_REALTIME, &start);
  int result = poll(&fds, 1, *timeout);
  clock_gettime(CLOCK_REALTIME, &finish);
  
  if (result == -1) {
    fprintf(stderr, "poll error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  if (result == 0) {
    *timeout = 0;
    return 0;
  }

  *timeout -= get_time_interval(start, finish);
  return result;
}   

size_t recv_message(int sockfd, char *buffer, struct sockaddr_in *sender) {
  socklen_t sender_len = sizeof(*sender);
  bzero(buffer, HEADER_LEN + DATAGRAM_LEN);
  bzero(sender, sizeof(*sender));
  size_t datagram_len = recvfrom(sockfd, buffer, IP_MAXPACKET, 0,
    (struct sockaddr*)sender, &sender_len);

  if (datagram_len < 0) {
    fprintf(stderr, "recvfrom error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  
  return datagram_len;
}

inline size_t min(size_t x, size_t y) { return (x<y ? x : y); }

void receive_file(int sockfd, struct sockaddr_in server_address, const char *file_name, size_t file_len) {
  FILE *fd = fopen(file_name, "w");
  if (!fd) {
    fprintf(stderr, "fopen error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  size_t bytes_writen = 0;
  
  size_t recv_pos, recv_len;
  struct sockaddr_in sender;
  char buffer[DATAGRAM_LEN + HEADER_LEN];
  int prev_len = 0;

  while (file_len) {
    send_data_request(sockfd, server_address, bytes_writen, min(file_len, DATAGRAM_LEN));
    int timeout = 10;
    while (poll_socket_modify_timeout(sockfd, &timeout)) {
      size_t received_bytes = recv_message(sockfd, buffer, &sender);
      if (sender.sin_addr.s_addr != server_address.sin_addr.s_addr || sender.sin_port != server_address.sin_port) continue;
      sscanf(buffer, "DATA %ld %ld\n", &recv_pos, &recv_len);
      if (recv_pos != bytes_writen) continue;
      fwrite(buffer + received_bytes - recv_len, sizeof(char), recv_len, fd);  
      file_len -= recv_len;
      bytes_writen += recv_len;
      break;    
    }
    if (prev_len != bytes_writen) {
      prev_len = bytes_writen;
      printf("%.3f%%\n", 100.0 * (float)(bytes_writen) / (float)(file_len+bytes_writen));
    }
  }

  fclose(fd);
}

int main(int argc, char *argv[]) {
  if (argc != 5) {
    printf("Usage:\n\t%s [server ip] [server port] [output file name] [file size]\n", argv[0]);
    return -1;
  }

  int sockfd = get_socket();
  struct sockaddr_in server_address;
  bzero(&server_address, sizeof(server_address));
  server_address.sin_family = AF_INET;
  if (!inet_pton(AF_INET, argv[1], &server_address.sin_addr)) {
    fprintf(stderr, "Invalid ip address: %s\n", argv[1]);
    return -1;
  }
  server_address.sin_port = htons(atoi(argv[2]));
  if (server_address.sin_port == 0) {
    fprintf(stderr, "Invalid port: %s\n", argv[2]);
    return -1;
  }

  size_t file_len = atoi(argv[4]);
  if (file_len == 0) {
    printf("File len is 0, nothing to do here.\n");
    return 0;
  }

  receive_file(sockfd, server_address, argv[3], file_len);
}