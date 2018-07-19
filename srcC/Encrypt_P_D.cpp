#include "header.h"
#include "Encrypt_P_D.h"

using namespace std;
using namespace cv;
/**
 * Note that every place with 512 need to change if the input image changes
 * The input image size assume to be multiple of 16
 */

#define pi  3.142857
#define si8 0.353553

double COSINE[8][8] = {
    {1, 0.980785, 0.923880, 0.831470, 0.707107, 0.555570, 0.382683, 0.195090},
    {1, 0.831470, 0.382683,-0.195090,-0.707107,-0.980785,-0.923880,-0.555570},
    {1, 0.555570,-0.382683,-0.980785,-0.707107, 0.195090, 0.923880, 0.831470},
    {1, 0.195090,-0.923880,-0.555570, 0.707107, 0.831470,-0.382683,-0.980785},
    {1,-0.195090,-0.923880, 0.555570, 0.707107,-0.831470,-0.382683, 0.980785},
    {1,-0.555570,-0.382683, 0.980785,-0.707107,-0.195090, 0.923880,-0.831470},
    {1,-0.831470, 0.382683, 0.195090,-0.707107, 0.980785,-0.923880, 0.555570},
    {1,-0.980785, 0.923880,-0.831470, 0.707107,-0.555570, 0.382683,-0.195090}};

// Function to find discrete cosine transform and print it
int fdct(int matrix[8][8], int dct[8][8]) {
    double ci, cj, dct1, sum;
    
    for( int i = 0; i < 8; ++i ) {
        for( int j = 0; j < 8; ++j ) {
            // ci and cj depends on frequency as well as
            // number of row and columns of specified matrix
            if( i == 0 )
                ci = si8;
            else
                ci = 0.5;
            if( j == 0 )
                cj = si8;
            else
                cj = 0.5;
            
            // sum will temporarily store the sum of
            // cosine signals
            sum = 0;
            for( int k = 0; k < 8; ++k ) {
                for( int l = 0; l < 8; ++l ) {
                    sum += (double) matrix[k][l] * COSINE[k][i] * COSINE[l][j];
                }
            }
            dct[i][j] = (int)( ci * cj * sum + 0.5 );
            if( dct[i][j] < 0 )
                dct[i][j] -= 1;
        }
    }
}

bool Check_S( int *S, int i, int P ) {
    i %= P;
    for( int j = 0; S[j] >= 0; j++ )
        if( S[j] == i )
            return true;
    return false;
}

int Equation( int *coef, int w, int x ) {
    // EQUATION Evaluate the equation value
    //    Calculate the equation f(1) = c0 + c1x^1 + c2x^2 + ... mod p
    //  Fixed to maxmima x=9 for speedup
    int xx[9][9] = {
        {1,1, 1,  1,  1,  1,  1,  1,  1},
        {1,2, 4,  8, 16, 32, 64,128,  5},
        {1,3, 9, 27, 81,243,227,179, 35},
        {1,4,16, 64,  5, 20, 80, 69, 25},
        {1,5,25,125,123,113, 63, 64, 69},
        {1,6,36,216, 41,246,221, 71,175},
        {1,7,49, 92,142,241,181, 12, 84},
        {1,8,64, 10, 80,138,100, 47,125},
        {1,9,81,227, 35, 64, 74,164,221}};
    int sum = 0;
    for( int i = 0; i < w; i++ ) {
        sum += coef[i] * xx[x-1][i];
    }
    return sum%251;
}

void Encrypt_P_D( Input input ) {
    // Generate file path
    char filepath[100];
    strcpy( filepath, input.input_path );
    strcat( filepath, input.input_file );
    
    // Get Image from file path
    Mat srcImage = imread(filepath, CV_LOAD_IMAGE_GRAYSCALE);
    if (!srcImage.data) {
        cout << "Image not loaded" << endl;
        return ;
    }

    // Change Image from Mat to array;
    uchar img[512][512];
    for(int i = 0; i < srcImage.rows; i++){
        uchar *data = srcImage.ptr<uchar>(i);
        for(int j = 0; j < srcImage.cols; j++){
            img[i][j] = data[j];
        }
    }
    
    // Do DCT
    for( int i = 0; i < 512; i+=8 ) {
        for( int j = 0; j < 512; j+=8 ) {
            // Copy to tmp for dct
            int bdct[8][8], adct[8][8];
            for( int m = 0; m < 8; m++ ) {
                for( int n = 0; n < 8; n++ ) {
                    bdct[m][n] = img[i+m][j+n];
                }
            }
            // Do DCT
            fdct( bdct, adct );
            // Do Quantize
            for( int m = 0; m < 8; m++ ) {
                for( int n = 0; n < 8; n++ ) {
                    adct[m][n] /= input.QT[m][n];
                    adct[m][n] += 125;
                }
            }
            adct[0][0] -= 128;
            // Put back to original image
            for( int m = 0; m < 8; m++ ) {
                for( int n = 0; n < 8; n++ ) {
                    img[i+m][j+n] = adct[m][n];
                }
            }
        }
    }
    
    // Do truncate
    for( int i = 0; i < 512; i+=8 ) {
        for( int j = 0; j < 512; j+=8 ) {
            if( img[i][j] > 250 )
                img[i][j] = 250;
            else if( img[i][j] < 0 )
                img[i][j] = 0;
        }
    }
    
    // Do Rearrange
    int R[512*512];
    for( int i = 0, c = 0; i < 64; ++i ) {
        int ptr = input.Z[i];
        for( int m = ptr/8; m < 512; m+=8 ) {
            for( int n = ptr%8; n < 512; n+=8 ) {
                R[c] = img[m][n];
                c++;
            }
        }
    }
    
    // Do Secret Sharing
    uchar output_img[9][512*512];
    int offset = 0;
    int itr = 0;
    int K[] = {0,1,2,3,5,10,21,62,64};
    int height_s = input.height/8, width_s = input.width/8;
    // DC
    while( itr < height_s*width_s*K[1] ) {
//        printf("%d ", itr);
        if( Check_S( input.S, itr, height_s*width_s ) || Check_S( input.S, itr+1, height_s*width_s ) ) {
            // Sensitive area
            int tmp[input.N] = {R[itr], R[itr+1]};
            for( int m = 2; m < input.N; ++m ) {
                tmp[m] = rand() % 251;
            }
            for( int x = 0; x < input.N; ++x) {
                output_img[x][offset] = Equation(tmp, input.N, x+1);
            }
        } else {
            // Not Sensitive area
            for( int x = 0; x < input.N; ++x) {
                output_img[x][offset] = Equation( R+itr, 2, x+1 );
            }
        }
        offset += 1;
        itr += 2;
    }
    
    for( int R = 2; R < N; R++ ) {
        while( itr < height_s*width_s*K[R] ) {
            // Find if overlap with sensitive area
            int flag = 0;
            for( int new_i = itr; new_i < itr+R-1; new_i++ ) {
                if( Check_S( input.S, new_i, height_s*width_s ) ) {
                    flag = 1;
                    break;
                }
            }
            if( flag ) {
                
            }
        }
    }
}
/*
    % AC
            % Overlapped
            if( flag == 1 )
                % Do share for not Overlapped part
                if( new_i ~= i )
                    tmp = [C(i:new_i-1) randi(250,1,R-new_i+i)];
%                     tmp = [C(i:new_i-1) randi(250,1,3-new_i+i)];
                    for x = 1:N
                        output_img(x, offset) = Equation(tmp, x);
                    end
                    offset = offset+1;
                    i = new_i;
                end
                % Do share for sensitive part
                while( Check_S( S, i, height_s*width_s ) )
                    % Sensitive area
                    tmp = [C(i) randi(250,1,N-1)];
                    for x = 1:N
                        output_img(x, offset) = Equation(tmp, x);
                    end
                    i = i+1;
                    offset = offset+1;
                    % If reach EOF
                    if i == length(C)
                        break;
                    end
                end
            % Not sensitive part
            else
                % If remain length < R
                if( i+R-1 > length(C) )
                    tmp = randi(255, 1, R);
                    tmp(1:(length(C)-i+1)) = C(i:end);
                    for x = 1:N
                        output_img(x, offset) = Equation(tmp, x);
%                         output_img(x, offset) = Equation(tpm, x);
                    end
                % Normal condition
                else
                    for x = 1:N
                        output_img(x, offset) = Equation(C(i:i+R-1), x);
%                         output_img(x, offset) = Equation(C(i:i+2), x);
                    end
                end
                offset = offset+1;
                i = i+R;
%                 i = i+3;
            end
 
    offset = offset - 1;
    % Delete rest part and remain padding to fit output image size
    offset_s = ceil( offset * 2 / height );
    output_img(:,(offset_s*height/2+1):end) = [];
    % Give Random value to padding (to show the padding, comment out)
    output_img(:,(offset+1):(offset_s*height/2)) = randi(250,N,(offset_s*height/2)-offset);
    
    % Output
    output_img = uint8(output_img);
    for i = 1:N
        output_name = [output_path output_file num2str(i, '_%02d') '.bmp'];
        tmp = reshape(output_img(i,:,:), height/2, []);
        imwrite(tmp, output_name);
    end
*/
