#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int
main(int argc, const char* argv[])
{
    int iterations = atoi(argv[1]);
    int i;

    struct timespec tim;
    tim.tv_sec = 0;
    tim.tv_nsec = 1000;

    while (1) {
        i = iterations;
        while (i--)
            ;
        nanosleep(&tim, NULL);
    }

    return 0;

}
