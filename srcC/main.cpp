#include "header.h"
#include "Encrypt_P_D.h"

using namespace std;
using namespace cv;


int main() {
    int a[8][8] = {
        {208,245,108,174,71,112,181,245},
        {231,247,234,194,12,98,193,87},
        {33,41,203,190,25,196,71,150},
        {233,248,245,101,210,203,174,58},
        {162,245,168,168,178,48,168,192},
        {25,124,10,44,81,125,42,66},
        {72,205,217,181,243,114,31,130},
        {140,37,239,9,9,165,128,179}};
    int b[8][8];
    fdct( a, b );
    for( int i = 0; i < 8; ++i ) {
        for( int j = 0; j < 8; ++j ) {
            printf("%6d ", b[i][j] );
        }
        puts("");
    }
    
    Mat srcImage = imread("../Lenna.bmp", CV_LOAD_IMAGE_GRAYSCALE);
    if (!srcImage.data) {
        cout << "Image not loaded" << endl;
        return -1;
    }
    cout << "row: " << srcImage.rows << endl;
    cout << "col: " << srcImage.cols << endl;
    cout << "channel: " << srcImage.channels() << endl;
    cout << "depth: " << srcImage.depth() << endl;
    cout << "type: " << srcImage.type() << endl;
    
    
    uchar array[512][512];
    for(int i = 0; i < srcImage.rows; i++){
        uchar *data = srcImage.ptr<uchar>(i);
        for(int j = 0; j < srcImage.cols; j++){
            array[i][j] = data[j];
        }
    }
    Mat img(512, 512, CV_8U, array);
    imshow("output.bmp",img);
//    waitKey(0);
    
    cout << "1,1: " << (int)array[1][1] << endl;
    cout << "2,2: " << (int)array[2][2] << endl;
    cout << "3,3: " << (int)array[3][3] << endl;
    cout << "4,4: " << (int)array[4][4] << endl;
    cout << "5,5: " << (int)array[5][5] << endl;
    
    Input input = {
        // input and output path
        .input_path  = "../",
        .input_file  = "Lenna.bmp",
        .output_path = "../result_d_02/",
        .output_file = "result",
        // height and width of input image
        .height = 512,
        .width = 512,
        // Total share numbers
        .N = 9,
        .S = {0},
         // Quantization Table
        .QT = { {8,5,3,3,2,1,1,1},
                {5,3,3,2,1,1,1,1},
                {3,3,2,1,1,1,1,1},
                {3,2,1,1,1,1,1,1},
                {2,1,1,1,1,1,1,1},
                {1,1,1,1,1,1,1,1},
                {1,1,1,1,1,1,1,1},
                {1,1,1,1,1,1,1,1}},
        // Zigzag order
        .Z = {0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,
              12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,
              35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,
              58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63},
    };
    
    // Sensitive area return by others
    // x1 y1 x2 y2
    int Sen[][4] = { {240, 252, 295, 280},
                    {264, 340, 325, 370} };
    int h = sizeof(Sen) / sizeof(int) /4;
    printf("Size of Sen is %d\n", h);
    
    for( int i = 0; i < h; i++ ) {
        Sen[i][0] = ((Sen[i][0] + 4) / 16) *2;
        Sen[i][1] =  (Sen[i][1] + 4) / 8;
        Sen[i][2] = ((Sen[i][2] +12) / 16) *2 +1;
        Sen[i][3] =  (Sen[i][3] + 4) / 8;
    }
    // width of the image / 8
    int w_s = input.width / 8;
    int c = 0;
    for( int i = 0; i < h; ++i ) {
        for( int y = Sen[i][1]; y < Sen[i][3]; ++y ) {
            for( int x = Sen[i][0]; x < Sen[i][2]; ++x ) {
                input.S[c] = x + (y-1)*w_s;
                ++c;
            }
        }
    }
    input.S[c] = -1;
    
    Encrypt_P_D(input);
    puts("GGGGG");
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    
    strcpy(input.input_path, input.output_path);
    strcpy(input.input_file, input.output_file);
    strcpy(input.output_file, "dec");
    
    //Decrypt_P_D(input, 1);
    for( int K = 1; K < 9; K++ ) {
        //Decrypt_P_D(input, K);
    }

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    
    return 0;
}
/*
% 4096 / k
%    2    3    4    5    6    7    8    9
% 4096 4098 4096 4100 4098 4102 4096 4104
% 2048 1366 1024  820  683  586  512  456
% Define zigzag order           % Define dct's k
%  1  2  6  7 15 16 28 29       % 2 3 6 6 7 7 8 8
%  3  5  8 14 17 27 30 43       % 4 5 6 7 7 8 8 8
%  4  9 13 18 26 31 42 44       % 5 6 7 7 8 8 8 8
% 10 12 19 25 32 41 45 54       % 6 7 7 8 8 8 8 8
% 11 20 24 33 40 46 53 55       % 7 7 8 8 8 8 8 8
% 21 23 34 39 47 52 56 61       % 7 8 8 8 8 8 8 8
% 22 35 38 48 51 57 60 62       % 8 8 8 8 8 8 8 8
% 36 37 49 50 58 59 63 64       % 8 8 8 8 8 8 9 9

%%%
% Zigzag Order
% Z = [ 1  2  9 17 10  3  4 11 18 25 33 26 19 12  5  6,...
%      13 20 27 34 41 49 42 35 28 21 14  7  8 15 22 29,...
%      36 43 50 57 58 51 44 37 30 23 16 24 31 38 45 52,...
%      59 60 53 46 39 32 40 47 54 61 62 55 48 56 63 64]
% Y = [ 1  2  6  7 15 16 28 29  3  5  8 14 17 27 30 43,...
%       4  9 13 18 26 31 42 44 10 12 19 25 32 41 45 54,...
%      11 20 24 33 40 46 53 55 21 23 34 39 47 52 56 61,...
%      22 35 38 48 51 57 60 62 36 37 49 50 58 59 63 64]
*/


