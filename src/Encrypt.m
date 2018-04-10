function Encrypt(K, N, input_path, input_file, output_path, output_file, scramble, dsp)
%ENCRYPT Encrypt the image into N shares
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
    input_img(:, (width+1):(width_n*K)) = round(255*rand(height, (width_n*K) - width));
    width = width_n*K;

    % Narrow the pixel value area
    % Scramble the input image
    if scramble > 0
        rand('seed',scramble);
        for i = 1:height
            for j = 1:width
                if input_img(i, j) < 3
                    input_img(i, j) = 3;
                end
                if input_img(i, j) > 253
                    input_img(i, j) = 253;
                end
                if scramble == 1
                    input_img(i, j) = mod(input_img(i, j) + i + j -2, 251) +2;
                else
                    if scramble == 2
                        input_img(i, j) = mod(input_img(i, j) + i*j + j -2, 251) +2;
                    else
                        input_img(i, j) = mod(input_img(i, j) + round(255*rand()) -2, 251) +2;
                    end
                end
            end
        end
        imwrite(uint8(input_img), [output_path 'Lenna_scrambled.bmp']);
    end

    % Distribute to n shares
    output_img = zeros(N, height, width_n);
    for i = 1:height
        for j = 1:width_n
            for x = 1:N
                output_img(x, i, j) = Equation(input_img(i, (j*K-K+1):(j*K)), x);
            end
        end
    end

    % Output
    output_img = uint8(output_img);
    for i = 1:N
        output_name = [output_path output_file num2str(i, '_%02d') '.bmp'];
        tmp = reshape(output_img(i,:,:), [height, width_n]);
        imwrite(tmp, output_name);
        if dsp
            subplot(1,N,i)
            imshow(tmp);
        end
    end
end

