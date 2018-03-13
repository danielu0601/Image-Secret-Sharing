clear;

K = 4;
N = 6;
input_path = '';
input_file  = 'Lenna.bmp';
output_path = 'result02/';
output_file = 'result_';

Encrypt(K, N, input_path, input_file, output_path, output_file);

clear;

K = 4;
N = [1 2 3 4];
input_path = 'result02/';
input_file  = 'result_';
output_path = input_path;
output_file = 'dec.bmp';

Decrypt(K, N, input_path, input_file, output_path, output_file)