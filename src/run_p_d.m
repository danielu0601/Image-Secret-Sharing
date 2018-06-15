clear;

% input.dsp = 0; % 1 for Displaym 0 for not
% input.permutation = 0; % 1 for permute, 0 for not
% input.key = 999;
input.QT = [8 5 3 3 2 1 1 1;
            5 3 3 2 1 1 1 1;
            3 3 2 1 1 1 1 1;
            3 2 1 1 1 1 1 1;
            2 1 1 1 1 1 1 1;
            1 1 1 1 1 1 1 1;
            1 1 1 1 1 1 1 1;
            1 1 1 1 1 1 1 1];
input.Z = [ 1  2  6  7 15 16 28 29  3  5  8 14 17 27 30 43,...
            4  9 13 18 26 31 42 44 10 12 19 25 32 41 45 54,...
           11 20 24 33 40 46 53 55 21 23 34 39 47 52 56 61,...
           22 35 38 48 51 57 60 62 36 37 49 50 58 59 63 64];
  
% Sensitive area return by others
input.Sen = [ [240 240 280 280];
              [360 180 380 200];
            ];
input.width = 512;
input.height = 512;
[w, h] = size(input.Sen);
input.Sen( :, [1 2] ) = floor( (input.Sen( :, [1 2] )+7) / 8);
input.Sen( :, [3 4] ) =  ceil( (input.Sen( :, [3 4] )+7) / 8);

% width of the image / 8
width = 64;
input.S = [];
for i = 1:w
    for x = input.Sen(i,1):input.Sen(i,3)
        for y = input.Sen(i,2):input.Sen(i,4)
            input.S = [input.S (((x-1)*width)+y)];
        end
    end
end

input.input_path  = '../';
input.input_file  = 'Lenna.bmp';
input.output_path = '../result_d_02/';
input.output_file = 'result';

Encrypt_P_D(input);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

input.input_path  = input.output_path;
input.input_file  = input.output_file;
input.output_file = 'dec';

for K = 1:9
    Decrypt_P_D(K, input);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

