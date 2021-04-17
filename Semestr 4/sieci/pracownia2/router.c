#include <stdio.h>
#include <errno.h>
#include <strings.h>
#include <string.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdlib.h>
#include <poll.h>
#include <time.h>
#include <unistd.h>

#define SERVER_PORT 54321
#define TURN_LEN_S 5
#define TURN_LEN_MS (1000 * TURN_LEN_S)
#define TURN_LEN_US (1000000 * TURN_LEN_S)
#define NS_TO_MS(X) ((long)(X) / (long)1000000)
#define S_TO_MS(X) ((long)(X) * (long)1000)

struct router_addr {
    struct in_addr  addr;
    uint16_t        distance;
    uint8_t         netmask;
};

struct in_addr get_broadcast_address(struct router_addr ra) {
    struct in_addr result = ra.addr;
    /* bitshift by more than 31 is UB */
    if (ra.netmask < 32) {
        result.s_addr |= ~((1<<ra.netmask) - 1);
    }
    return result;
}

void pretty_print(struct router_addr ra) {
    char ip_addr[20];
    inet_ntop(AF_INET, &ra.addr, ip_addr, sizeof(ip_addr));
    printf("%s/%d distance %d\n", ip_addr, ra.netmask, ra.distance);
}

/* converts string of IP with netmask in CIDR notation to router_addr */
struct router_addr stora(char *str) {
    struct router_addr  result;
    char                addr[20];
    size_t              ip_preffix = strcspn(str, "/");
    
    strncpy(addr, str, strlen(str));
    addr[ip_preffix] = 0;
    inet_pton(AF_INET, addr, &(result.addr));
    result.netmask = atoi(str + ip_preffix + 1);
    return result;
}

int get_socket() {
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        fprintf(stderr, "Socket error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    return sockfd;
}

void bind_to_port(int sockfd, uint16_t port) {
    struct sockaddr_in server_address;
    bzero(&server_address, sizeof(server_address));
    server_address.sin_family       = AF_INET;
    server_address.sin_port         = htons(port);
    server_address.sin_addr.s_addr  = htonl(INADDR_ANY);
    if (bind(sockfd, (struct sockaddr*)&server_address, sizeof(server_address)) < 0) {
        fprintf(stderr, "Bind error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int broadcastPermission = 1;
    setsockopt (sockfd, SOL_SOCKET, SO_BROADCAST, (void *)&broadcastPermission, sizeof(broadcastPermission));
}

uint16_t read_configuration(struct router_addr** networks) {
    uint16_t n;
    scanf("%hd", &n);
    *networks = malloc(n * sizeof(struct router_addr));
    for (int i = 0; i < n; i++) {
        char addr[20];
        char _dist[10];
        uint16_t dist;
        scanf(" %s %s %hd", addr, _dist, &dist);
        (*networks)[i] = stora(addr);
        (*networks)[i].distance = dist;
    }
    return n;
}

long get_time_interval(struct timespec start, struct timespec finish) {
    return S_TO_MS(finish.tv_sec - start.tv_sec) + NS_TO_MS(finish.tv_nsec - start.tv_nsec);
}

int poll_modify_timeout(struct pollfd *fds, nfds_t nfd, int *timeout) {
    if (*timeout < 0) {
        fprintf(stderr, "poll_modify_timeout: timeout is negative.\n");
        exit(EXIT_FAILURE);
    }
    
    struct timespec start;
    clock_gettime(CLOCK_REALTIME, &start);
    int result = poll(fds, nfd, *timeout);
    
    if (result == -1) {
        fprintf(stderr, "poll error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    if (result == 0) {
        *timeout = 0;
        return 0;
    }
    struct timespec finish;
    clock_gettime(CLOCK_REALTIME, &finish);
    *timeout -= get_time_interval(start, finish);
    printf("Timeout: %dms, time waiting: %ldms.\n", *timeout, get_time_interval(start, finish));
    return result;
}   

/* For debug purposes only */
void recv_and_print(int sockfd, int networks_number, struct router_addr *networks) {
    struct sockaddr_in  sender;
    socklen_t           sender_len = sizeof(sender);
    uint8_t             buffer[IP_MAXPACKET + 1];
    ssize_t datagram_len = recvfrom(sockfd, buffer, IP_MAXPACKET, 0,
        (struct sockaddr*)&sender, &sender_len);
    if (datagram_len < 0) {
        fprintf(stderr, "recvfrom error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < networks_number; i++) {
        if (networks[i].addr.s_addr == sender.sin_addr.s_addr) {
            return;
        }
    }
 
    char sender_ip_str[20];
    inet_ntop(AF_INET, &(sender.sin_addr), sender_ip_str, sizeof(sender_ip_str));
    printf("Received UDP packet from IP address: %s, port %d\n", 
        sender_ip_str, ntohs(sender.sin_port));

    buffer[datagram_len] = 0;
    printf("%ld-byte message: +%s+\n", datagram_len, buffer);

}

void listen_for_routers(int sockfd, int timeout, int networks_number, struct router_addr *netowrks) {
    printf("Listening for %dms.\n", timeout);
    struct pollfd fds;
    fds.fd = sockfd;
    fds.events = POLLIN;
    fds.revents = 0;
    while (poll_modify_timeout(&fds, 1, &timeout)) {
        printf("Poll returned, remaining timeout: %dms.\n", timeout);
        recv_and_print(sockfd, networks_number, netowrks);
    }
    printf("Finished listening\n");
}

int send_distance_vector(int sockfd, struct in_addr network) {
    struct sockaddr_in network_address;
	bzero (&network_address, sizeof(network_address));
	network_address.sin_family       = AF_INET;
	network_address.sin_port         = htons(SERVER_PORT);
    network_address.sin_addr         = network;

	char* message = "Hello server! My name is S1\n";
	ssize_t message_len = strlen(message);
    int result;

    char addr[20];
    inet_ntop(AF_INET, &network, addr, sizeof(addr));
    printf("Sending datagram to %s\n", addr);
	if ((result = sendto(sockfd, message, message_len, 0, (struct sockaddr*) &network_address, sizeof(network_address))) != message_len) {
		fprintf(stderr, "sendto error: %s\n", strerror(errno)); 
		// return EXIT_FAILURE;		
	}
}

void propagate_distance_vector(int sockfd, int networks_number, struct router_addr *networks) {
    printf("Propagating distance vector\n");
    for (int i = 0; i < networks_number; i++) {
        struct in_addr broadcast_address = get_broadcast_address(networks[i]);
        send_distance_vector(sockfd, broadcast_address);
    }
    printf("Distance vector propagated.\n");
}

void router_loop(int sockfd, int networks_number, struct router_addr *networks) {
    printf("Starting the router loop...\n");
    for (;;) {
        listen_for_routers(sockfd, TURN_LEN_MS, networks_number, networks);
        propagate_distance_vector(sockfd, networks_number, networks);
    }
}

int main() {
    struct router_addr* networks;
    int n = read_configuration(&networks);
    for (int i = 0; i < n; i++) {
        pretty_print(networks[i]);
    }

    int sockfd = get_socket();
    bind_to_port(sockfd, SERVER_PORT);
    router_loop(sockfd, n, networks);
    
    close(sockfd);
    free(networks);
}