clear;
dsp = 0; % Display if 1
permutation = 0; % permute if 1
key = 999;

input_path = '';
input_file  = 'Lenna.bmp';
output_path = 'result_p_01/';
output_file = 'result';

Encrypt_Progressive(input_path, input_file, output_path, output_file, dsp, permutation, key);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

input_path = output_path;
input_file  = output_file;
output_path = input_path;
output_file = 'dec';

for K = 1:8
    Decrypt_Progressive(K, input_path, input_file, output_path, output_file, dsp, permutation, key);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define zigzag order          %% Define dct's k       %% Define idct's k
%  1  2  6  7 15 16 28 29       % 2 2 4 4 5 5 6 6       % 2 3 4 4
%  3  5  8 14 17 27 30 43       % 3 3 4 5 5 6 6 7       % 5 5 6 6
%  4  9 13 18 26 31 42 44       % 3 4 4 5 6 6 7 7       % 7 7 7 8
% 10 12 19 25 32 41 45 54       % 4 4 5 6 6 7 7 7
% 11 20 24 33 40 46 53 55       % 4 5 6 6 7 7 7 7
% 21 23 34 39 47 52 56 61       % 5 5 6 7 7 7 7 8
% 22 35 38 48 51 57 60 62       % 5 6 7 7 7 8 8 8
% 36 37 49 50 58 59 63 64       % 7 7 7 7 8 8 8 8