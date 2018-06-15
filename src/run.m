clear;

input.dsp         = 0; % Display image?
input.scramble    = 255; % Scamble before sharing, 0:no, 1:linear, 2:oblique, 3+:random

input.K           = 3;
input.N           = 4;
input.input_path  = '../';
input.input_file  = 'Lenna.bmp';
input.output_path = '../result_01/';
input.output_file = 'result';

Encrypt(input);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

input.K           = 3;
input.N           = [2 3 4];
input.input_path  = input.output_path;
input.input_file  = input.output_file;
input.output_file = 'dec.bmp';

Decrypt(input);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

org = imread(['../' 'Lenna.bmp']);
[height width] = size(org);
dec = imread([input.output_path input.output_file]);
PSNR = psnr(dec(1:height, 1:width), org)