clear;

%parameters
intput_path = '';
input_file = 'Lenna.bmp';
output_path = 'result01/';
output_file = 'result_';
%(K,N)
K = 4;
N = 6;

%
% read in files,
% get width, height,
% padding
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(output_path);
input_img = imread([intput_path input_file]);
input_img = double(input_img);
[height, width] = size(input_img);
width_n = ceil(width/N);
width = width_n*N;
input_img( height, width ) = 0;

% 
% scramble the input image
for i = 1:height
    for j = 1:width
        input_img(i, j) = mod(input_img(i, j) + j, 256);
    end
end

output_img = zeros(N, height, width_n);
for i = 1:height
    for j = 1:width_n
        for x = 1:N
            output_img(x, i, j) = 0;
            for y = 1:K
                output_img(x, i, j) = output_img(x, i, j) + ( input_img(i, (j-1)*N+y)* x^(y-1) );
            end
            output_img(x, i, j) = mod(output_img(x, i, j), 256);
        end
    end
end

output_img = uint8(output_img);
for i = 1:N
    output_name = [output_path output_file num2str(i, '%02d') '.bmp'];
    tmp = output_img(i,:,:);
    tmp = reshape(tmp, [height, width_n]);
    subplot(1,N,i)
    imshow(tmp);
    imwrite(tmp, output_name);
end