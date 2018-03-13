clear;

% Parameters
intput_path = 'result01/';
input_file = 'result_';
output_path = intput_path;%'result01/';
output_file = 'dec.bmp';
%(K,N)
K = 4;
N = [3 4 5 6];

% Constants
%Vari = ["X" "a0" "a1" "a2" "a3" "a4" "a5" "a6" "a7"];
%syms( Vari );
%Variable = [X a0 a1 a2 a3 a4 a5 a6 a7];
%Function = ["a0" "+ a1 * X" "+ a2 * X^2" "+ a3 * X^3" "+ a4 * X^4" "+ a5 * X^5" "+ a6 * X^6" "+ a7 * X^7"];
%F = str2sym(strjoin( Function(1:K) ));

%
% read in files,
% get width, height,
length = size(N);
tmp = imread([intput_path input_file num2str(N(1), '%02d') '.bmp']);
[height, width] = size(tmp);
input_img(K, height, width) = 0;
for i = 1:K
    input_img(i,:,:) = imread([intput_path input_file num2str(N(i), '%02d') '.bmp']);
end
input_img = double(input_img);
output_img( height, width*K ) = 0;

%
% Solve the original secret from n shares
for i = 1:height
    for j = 1:width
        output_img(i, ((j-1)*K+1):(j*K) ) = Solve_Eq(K, N, input_img(:, i, j));
    end
end

% 
% scramble back the output image
for i = 1:height
    for j = 1:width*K
%        output_img(i, j) = mod(output_img(i, j) - i*j - j, 256);
    end
end

%
% Calculate if there is 0~4 => 251~255
avg = mean(mean(output_img)) - 100;
avg = avg / abs(avg);

for i = 1:height
    for j = 1:width*K
        if output_img(i, j) < 5 || output_img(i, j) > 250
%            output_img(i, j) = Check_neighbor(output_img, i, j, avg);
        end
    end
end

%
% Output
output_img = uint8(output_img);
output_name = [output_path output_file];
imshow(output_img);
imwrite(output_img, output_name);

tmp = imread('Lenna.bmp');
PSNR = psnr(output_img, tmp)
