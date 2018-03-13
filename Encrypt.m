function Encrypt(K, N, input_path, input_file, output_path, output_file)
%ENCRYPT Summary of this function goes here
%   Detailed explanation goes here

    % Read in files,
    % Get width, height,
    % Padding
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(output_path);
    input_img = imread([input_path input_file]);
    input_img = double(input_img);
    [height, width] = size(input_img);
    width_n = ceil(width/K);
    input_img(height, width_n*K) = input_img(height, width);
    input_img(:, (width+1):(width_n*K)) = rand(height, (width_n*K) - width);
    width = width_n*K;

    % Narrow the pixel value area
    % Scramble the input image
    for i = 1:height
        for j = 1:width
            if input_img(i, j) < 3
                input_img(i, j) = 3;
            end
            if input_img(i, j) > 253
                input_img(i, j) = 253;
            end
            input_img(i, j) = mod(input_img(i, j) + i + j -2, 251) +2;
        end
    end
    imwrite(uint8(input_img), 'Lenna_scrambled.bmp');

    % Distribute to n shares
    output_img = zeros(N, height, width_n);
    for i = 1:height
        for j = 1:width_n
            for x = 1:N
                output_img(x, i, j) = 0;
                for y = 1:K
                    output_img(x, i, j) = output_img(x, i, j) + ( input_img(i, (j-1)*K+y)* x^(y-1) );
                end
                output_img(x, i, j) = mod(output_img(x, i, j), 251);
            end
        end
    end

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
end

