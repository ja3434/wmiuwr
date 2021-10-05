/* Projekt: Transport
 * Autor: Franciszek Malinka 316093
 */

#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdbool.h>
#include "config.h"
#include "window.h"
#include "utils.h"

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

void request_data(int sockfd, struct sockaddr_in server_address, window_t *w, size_t bytes_writen, size_t remaining_bytes) {
  int pos = w->first_pos;
  for (int i = 0; i < w->size && i*DATAGRAM_LEN < remaining_bytes; i++) {
    if (w->uptodate[pos] == false) {
      size_t bytes_to_request = min(DATAGRAM_LEN, remaining_bytes - i*DATAGRAM_LEN);
      send_data_request(sockfd, server_address, bytes_writen + i*DATAGRAM_LEN, bytes_to_request);
    }
    pos = (pos + 1) % w->size;
  }
}

void update_file(FILE *fd, window_t *w, size_t *bytes_writen, size_t *remaining_bytes) {
  while (w->uptodate[w->first_pos] && *remaining_bytes > 0) {
    // printf("Writing %ld\n", *bytes_writen);
    size_t bytes_to_write = min(DATAGRAM_LEN, *remaining_bytes);
    fwrite(w->ar[w->first_pos], sizeof(char), bytes_to_write, fd);  
    *bytes_writen += bytes_to_write;
    *remaining_bytes -= bytes_to_write;
    shift(w);
  } 
}

size_t recv_datagram(int sockfd, char *buffer, struct sockaddr_in server_address) {
  struct sockaddr_in sender;
  
  size_t received_bytes = recv_message(sockfd, buffer, &sender);
  if (sender.sin_addr.s_addr != server_address.sin_addr.s_addr || sender.sin_port != server_address.sin_port) {
    printf("Smieci!\n");
    return 0;
  }
  return received_bytes;  
}


void receive_file(int sockfd, struct sockaddr_in server_address, const char *file_name, size_t remaining_bytes) {
  FILE *fd = fopen(file_name, "w");
  if (!fd) {
    fprintf(stderr, "fopen error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  size_t bytes_writen = 0;
  
  size_t recv_pos, recv_len;
  char buffer[DATAGRAM_LEN + HEADER_LEN];
  int prev_len = 0;
  window_t w;
  init_window(&w, WINDOW_SIZE, DATAGRAM_LEN);
  
  while (remaining_bytes) {
    request_data(sockfd, server_address, &w, bytes_writen, remaining_bytes);
    int timeout = TIMEOUT;
    while (poll_socket_modify_timeout(sockfd, &timeout)) {
      size_t received_bytes = recv_datagram(sockfd, buffer, server_address);
      if (received_bytes == 0) continue;
      sscanf(buffer, "DATA %ld %ld\n", &recv_pos, &recv_len);
      if (recv_pos < bytes_writen) continue;
      
      int pos = (recv_pos - bytes_writen) / DATAGRAM_LEN;
      pos = (pos + w.first_pos) % w.size;
      if (!w.uptodate[pos]) {
        for (int i = 0; i < recv_len; i++) {
          w.ar[pos][i] = buffer[i + received_bytes - recv_len];
        }
        w.uptodate[pos] = true;
      }
      update_file(fd, &w, &bytes_writen, &remaining_bytes);
    }

    if (prev_len != bytes_writen) {
      prev_len = bytes_writen;
      printf("%.3f%%\n", 100.0 * (float)(bytes_writen) / (float)(remaining_bytes+bytes_writen));
    }
  }
  destroy_window(&w);
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