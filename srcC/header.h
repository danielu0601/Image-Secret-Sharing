#ifndef HEADER
#define HEADER
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <opencv2/opencv.hpp>
#include <math.h>

typedef struct INPUT {
    char input_path[4];
    char input_file[10];
    char output_path[16];
    char output_file[7];
    int height;
    int width;
    int N;
    int S[1000];
    char QT[8][8];
    char Z[64];
} Input;

#endif
