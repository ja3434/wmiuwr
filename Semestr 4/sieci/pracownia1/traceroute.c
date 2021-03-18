#include <stdio.h>
#include <errno.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <strings.h>
#include <string.h>
#include <stdlib.h>
#include <netinet/ip_icmp.h>
#include <assert.h>
#include <time.h>

#define MAX_TTL 30
#define MESSAGES_PER_TTL 3

void print_as_bytes (unsigned char* buff, ssize_t length)
{
	for (ssize_t i = 0; i < length; i++, buff++)
		printf ("%.2x ", *buff);	
}

struct sockaddr_in get_sockaddr_from_ip(char *ip) {
    struct sockaddr_in sock;
    bzero(&sock, sizeof(sock));
    sock.sin_family = AF_INET;
    if (!inet_pton(AF_INET, ip, &sock.sin_addr)) {
        fprintf(stderr, "Given ip is invalid: %s\n", ip);
        exit(EXIT_FAILURE);
    }
    return sock;
}

int create_raw_icmp_socket() {
    int sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    if (sockfd < 0) {
        fprintf(stderr, "socket error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    return sockfd;
}

uint16_t compute_icmp_checksum (const void *buff, int length)
{
	uint32_t sum;
	const uint16_t* ptr = buff;
	assert (length % 2 == 0);
	for (sum = 0; length > 0; length -= 2)
		sum += *ptr++;
	sum = (sum >> 16) + (sum & 0xffff);
	return (uint16_t)(~(sum + (sum >> 16)));
}

struct icmp create_icmp_header() {
    static uint16_t pid = 0;
    static uint16_t seq = 0;
    
    struct icmp header;
    header.icmp_type = ICMP_ECHO;
    header.icmp_code = 0;
    header.icmp_id = ++pid;
    header.icmp_seq = ++seq;
    header.icmp_cksum = 0;
    header.icmp_cksum = compute_icmp_checksum(
        (uint16_t*)&header, sizeof(header));

    return header;
}

void send_icmp_packet(int sockfd, struct sockaddr_in *destination, int ttl) {
    struct icmp header = create_icmp_header();
    setsockopt(sockfd, IPPROTO_IP, IP_TTL, &ttl, sizeof(int));

    printf("%ld %d\n", destination->sin_addr.s_addr, sockfd);
    ssize_t bytes_sent = sendto(
        sockfd,
        &header,
        sizeof(header),
        0,
        (struct sockaddr*)destination,
        sizeof(*destination)
    );
    if (bytes_sent == -1) {
        fprintf(stderr, "Error while sending ICMP packet: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    fprintf(stdout, "Bytes sent: %ld\n", bytes_sent);
}

/* Return ip address of the sender of recceived package */
in_addr_t recv_dontwait(int sockfd) {
    struct sockaddr_in       sender;
    socklen_t sender_len =   sizeof(sender);
    uint8_t                  buffer[IP_MAXPACKET];

    ssize_t packet_len = recvfrom(sockfd, buffer, IP_MAXPACKET, MSG_DONTWAIT,
        (struct sockaddr*)&sender, &sender_len);
    
    if (packet_len == -1) {
        fprintf(stderr, "Error while recieving a packet: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return sender.sin_addr.s_addr;
}

int traceroute(struct sockaddr_in *destination) {
    int sockfd = create_raw_icmp_socket();

    for (int ttl = 1; ttl <= MAX_TTL; ++ttl) {
        send_icmp_packet(sockfd, destination, ttl);
    }
}     

int main(int argc, char * argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage:\n\t%s [host ip]\n", argv[0]);
        return 1;
    }

    struct sockaddr_in destination = get_sockaddr_from_ip(argv[1]);
    traceroute(&destination);
}