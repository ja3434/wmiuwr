/* Pracownia programistyczna nr 1 - traceroute
 * Imię i nazwisko: Franciszek Malinka
 * Nr indeksu:      316093
 */

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
#include <sys/types.h>
#include <unistd.h>
#include <stdbool.h>

#define MAX_TTL 30
#define MESSAGES_PER_TTL 3
#define NO_MESSAGES -1
#define TOO_FEW_MESSAGES -2137

void print_as_bytes (unsigned char* buff, ssize_t length)
{
	for (ssize_t i = 0; i < length; i++, buff++)
		printf ("%.2x ", *buff);	
}

void debug_received(uint8_t *buffer, struct sockaddr_in *sender, int packet_len) {
    char ip_str[20];
    inet_ntop(AF_INET, &(sender->sin_addr), ip_str, sizeof(ip_str));

    printf("IP packet with ICMP content from: %s\n", ip_str);
    struct ip*  ip_header = (struct ip*) buffer;
    ssize_t     ip_header_len = 4 * ip_header->ip_hl;

    printf ("IP header: "); 
    print_as_bytes (buffer, ip_header_len);
    printf("\n");

    printf ("IP data:   ");
    print_as_bytes (buffer + ip_header_len, packet_len - ip_header_len);
    printf("\n\n");
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

uint16_t compute_icmp_checksum(const void *buff, int length)
{
	uint32_t sum;
	const uint16_t* ptr = buff;
	assert (length % 2 == 0);
	for (sum = 0; length > 0; length -= 2)
		sum += *ptr++;
	sum = (sum >> 16) + (sum & 0xffff);
	return (uint16_t)(~(sum + (sum >> 16)));
}

struct icmp create_icmp_header(uint16_t seq) {    
    struct icmp header;
    header.icmp_type = ICMP_ECHO;
    header.icmp_code = 0;
    header.icmp_id = (uint16_t)getpid();
    header.icmp_seq = seq;
    header.icmp_cksum = 0;
    header.icmp_cksum = compute_icmp_checksum(
        (uint16_t*)&header, sizeof(header));

    return header;
}

void send_icmp_packet(int sockfd, struct sockaddr_in *destination, int ttl) {
    struct icmp header = create_icmp_header(ttl);
    setsockopt(sockfd, IPPROTO_IP, IP_TTL, &ttl, sizeof(int));

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
}

/* Return ip address of the sender of recceived package */
ssize_t recv_packet(int sockfd, struct sockaddr_in *sender, uint8_t *buffer) {
    socklen_t sender_len = sizeof(*sender);
    ssize_t packet_len = recvfrom(sockfd, buffer, IP_MAXPACKET, 0,
        (struct sockaddr*)sender, &sender_len);
    
    if (packet_len == -1) {
        fprintf(stderr, "Error while recieving a packet: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    return packet_len;
}

void send_icmp_requests(int sockfd, struct sockaddr_in *destination, int ttl, int tries) {
    for (int i = 0; i < tries; i++) {
        send_icmp_packet(sockfd, destination, ttl);
    }
}

int try_select(int sockfd, struct timeval *tv) {
    fd_set descriptors;
    FD_ZERO(&descriptors);
    FD_SET(sockfd, &descriptors);
    return select(sockfd+1, &descriptors, NULL, NULL, tv);
}

void pretty_print_router(int ttl, struct in_addr *senders, float mean_wait_time, int messages_received) {
    char ip_str[20];
    printf("%d.\t", ttl);
    if (messages_received == 0) {
        printf("*\n");
    }
    else {
        for (int i = 0; i < messages_received; i++) {
            bool already_printed = false;
            for (int j = 0; j < i; j++) {
                if (senders[i].s_addr == senders[j].s_addr) {
                    already_printed = true;
                    break;
                }
            }
            if (already_printed) continue;
            inet_ntop(AF_INET, senders + i, ip_str, sizeof(ip_str));
            printf("%-15s ", ip_str);
        }
        if (messages_received < MESSAGES_PER_TTL)   printf("\t???\n");
        else                                        printf("\t%.2fms\n", mean_wait_time);
    }
}

// This function decapsulates important data from the IMCP replies
void get_important_data(uint8_t *buffer, uint8_t *code, uint16_t *id, uint16_t *seq) {
    struct ip*      ip_header = (struct ip*) buffer;
    ssize_t         offset = 4 * ip_header->ip_hl;
    *code = ((struct icmp *)(buffer + offset))->icmp_type;
    if (*code != ICMP_ECHOREPLY && *code != ICMP_TIMXCEED) {
        return;
    } else if (*code == ICMP_TIMXCEED) {
        offset  += ICMP_MINLEN;
        offset  += 4 * ((struct ip *)(buffer + offset))->ip_hl;
        *seq    = ((struct icmp *)(buffer + offset))->icmp_seq;
        *id     = ((struct icmp *)(buffer + offset))->icmp_id;
    } else {
        *seq = ((struct icmp *)(buffer + offset))->icmp_seq;
        *id = ((struct icmp *)(buffer + offset))->icmp_id;
    }
}

// timeout in milliseconds
float get_replies(int sockfd, long timeout, int ttl, int *messages_received, struct in_addr *senders) {
    struct sockaddr_in  sender;
    uint8_t             buffer[IP_MAXPACKET];
    int                 ready;
    long                mean_wait_time = 0;
    struct timeval      tv; tv.tv_sec = timeout / 1000; tv.tv_usec = 0;
    *messages_received = 0;

    while ((ready = try_select(sockfd, &tv))) {
        if (ready < 0) {
            fprintf(stderr, "Select error: %s\n", strerror(errno));
            exit(EXIT_FAILURE);
        }

        recv_packet(sockfd, &sender, buffer);
        uint8_t         icmp_code = 0;
        uint16_t        seq = 0, id = 0;

        get_important_data(buffer, &icmp_code, &id, &seq);
        if (seq == ttl) {
            senders[(*messages_received)++] = sender.sin_addr;
            mean_wait_time += timeout * 1000 - tv.tv_usec;
            
            if (*messages_received == MESSAGES_PER_TTL) break;
        }
    }
    // changing from microseconds to miliseconds
    return (float)mean_wait_time / 3.0 / 1000.0;
}

// Core of the program.
void traceroute(struct sockaddr_in *destination) {
    int sockfd = create_raw_icmp_socket(), messages_received = 0;
    struct in_addr senders[MESSAGES_PER_TTL];

    for (int ttl = 1; ttl <= MAX_TTL; ++ttl) {
        send_icmp_requests(sockfd, destination, ttl, MESSAGES_PER_TTL);
        float mean_wait_time = get_replies(sockfd, 1000, ttl, &messages_received, senders);
        pretty_print_router(ttl, senders, mean_wait_time, messages_received);

        // what if our packet branched and we got to the destination faster by some path? 
        // we gotta make a loop, not an if
        for (int i = 0; i < messages_received; i++) {
            if (senders[i].s_addr == destination->sin_addr.s_addr) {
                return;
            }
        }
    }
}     

int main(int argc, char * argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage:\n\t%s [host ip]\n", argv[0]);
        return 1;
    }

    struct sockaddr_in destination = get_sockaddr_from_ip(argv[1]);
    fprintf(stdout, "traceroute to %s, %d hops max\n", argv[1], MAX_TTL);
    traceroute(&destination);

    return 0;
}