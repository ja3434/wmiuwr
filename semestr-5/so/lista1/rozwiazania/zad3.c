#include<unistd.h>

const char *t[2];

int main() {
	t[0] = "siemandero";
	t[1] = NULL;

	execvp("python", t);
}
