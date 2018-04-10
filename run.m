clear;
scramble = 255; % Scamble before sharing, 0:no, 1:linear, 2:oblique, 3+:random
dsp = 0; % Display image?

K = 3;
N = 4;
input_path = '';
input_file  = 'Lenna.bmp';
output_path = 'result01/';
output_file = 'result';

Encrypt(K, N, input_path, input_file, output_path, output_file, scramble, dsp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

K = 3;
N = [2 3 4];
input_path = output_path;
input_file  = output_file;
output_path = input_path;
output_file = 'dec.bmp';

Decrypt(K, N, input_path, input_file, output_path, output_file, scramble, dsp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

org = imread('Lenna.bmp');
dec = imread([output_path output_file]);
PSNR = psnr(dec(1:512, 1:512), org)