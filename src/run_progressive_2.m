clear;

input.dsp         = 0; % Display if 1
input.permutation = 0; % permute if 1
input.key         = 999;
input.QT = [8 5 3 3 2 1 1 1;
            5 3 3 2 1 1 1 1;
            3 3 2 1 1 1 1 1;
            3 2 1 1 1 1 1 1;
            2 1 1 1 1 1 1 1;
            1 1 1 1 1 1 1 1;
            1 1 1 1 1 1 1 1;
            1 1 1 1 1 1 1 1];

input.N = 9;

input.input_path  = '../';
input.input_file  = 'Lenna.bmp';
input.output_path = '../result_p_07/';
input.output_file = 'result';

Encrypt_Progressive_2(input);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

input.input_path  = input.output_path;
input.input_file  = input.output_file;
input.output_file = 'dec';

for K = 1:9
    Decrypt_Progressive_2(input, K);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  4096 / k
%    2    3    4    5    6    7    8    9
% 4096 4098 4096 4100 4098 4102 4096 4104
% 2048 1366 1024  820  683  586  512  456
%  Define zigzag order          %% Define dct's k
%  1  2  6  7 15 16 28 29       % 2 3 6 6 7 7 8 8
%  3  5  8 14 17 27 30 43       % 4 5 6 7 7 8 8 8
%  4  9 13 18 26 31 42 44       % 5 6 7 7 8 8 8 8
% 10 12 19 25 32 41 45 54       % 6 7 7 8 8 8 8 8
% 11 20 24 33 40 46 53 55       % 7 7 8 8 8 8 8 8
% 21 23 34 39 47 52 56 61       % 7 8 8 8 8 8 8 8
% 22 35 38 48 51 57 60 62       % 8 8 8 8 8 8 8 8
% 36 37 49 50 58 59 63 64       % 8 8 8 8 8 8 9 9