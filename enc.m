clear;

% Parameters
intput_path = '';
input_file = 'Lenna.bmp';
output_path = 'result02/';
output_file = 'result_';
% (K,N), max N = 8;
K = 4;
N = 6;

% Constants
% Vari = ["X" "a0" "a1" "a2" "a3" "a4" "a5" "a6" "a7"];
% syms( Vari );
% Variable = [X a0 a1 a2 a3 a4 a5 a6 a7];
% Function = ["a0" "+ a1 * X" "+ a2 * X^2" "+ a3 * X^3" "+ a4 * X^4" "+ a5 * X^5" "+ a6 * X^6" "+ a7 * X^7"];
% F = str2sym(strjoin( Function(1:K) ));

%
% read in files,
% get width, height,
% padding
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(output_path);
input_img = imread([intput_path input_file]);
input_img = double(input_img);
[height, width] = size(input_img);
width_n = ceil(width/K);
input_img( height, width_n*K ) = 0;
input_img( :, (width+1):(width_n*K) ) = rand(height, (width_n*K) - width);
width = width_n*K;


% 
% scramble the input image
for i = 1:height
    for j = 1:width
        input_img(i, j) = mod(input_img(i, j) + i*j + j, 251);
    end
end
imwrite(uint8(input_img), 'Lenna_scrambled.bmp');

%
% Distribute to n shares
output_img = zeros(N, height, width_n);
for i = 1:height
    for j = 1:width_n
        for x = 1:N
%             output_img(x, i, j) = subs(F, Variable(1:K+1), [x input_img(i, ((j-1)*K+1):(j*K) )]);
            output_img(x, i, j) = 0;
            for y = 1:K
                output_img(x, i, j) = output_img(x, i, j) + ( input_img(i, (j-1)*K+y)* x^(y-1) );
            end
            output_img(x, i, j) = mod(output_img(x, i, j), 256);
        end
    end
end

%
% Output
output_img = uint8(output_img);
for i = 1:N
    output_name = [output_path output_file num2str(i, '%02d') '.bmp'];
    tmp = output_img(i,:,:);
    tmp = reshape(tmp, [height, width_n]);
    subplot(1,N,i)
    imshow(tmp);
    imwrite(tmp, output_name);
end