function Encrypt_Progressive(input_path, input_file, output_path, output_file, dsp, permutation, key)
%Encrypt_Progressive Encrypt the image into N shares
%   Expect 8*8's multiple of image size

    N = 8;
    K = 8;
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
    
    height_o = height*3/8;
    width_o = width*4/8;
    

    % Narrow the pixel value area
    for i = 1:height
        for j = 1:width
            if input_img(i, j) > 250
                input_img(i, j) = 250;
            end
        end
    end
    
    % Scramble the input image
    if permutation == 1
        rng(key);
        for i = 1:height
            tmp = randperm(width);
            input_img(i,:) = input_img(i,tmp);
        end
        rng(key);
        for i = 1:width
            tmp = randperm(height);
            input_img(:,i) = input_img(tmp,i);
        end
        imwrite(uint8(input_img), [output_path 'Lenna_permuted.bmp']);
    end
    

    % Distribute to n shares
    output_img = zeros(N, height_o, width_o);
    for i = 1:8:height
        for j = 1:8:width
            off_i = (i-1)*3/8+1;
            off_j = (j-1)*4/8+1;
            tmp = round(dct2(input_img(i:i+7,j:j+7))/8);
            for x = 1:N
                output_img(x, off_i  , off_j  ) = Equation([tmp(1,1) tmp(1,2)], x);
                output_img(x, off_i  , off_j+1) = Equation([tmp(2,1) tmp(3,1) tmp(2,2)], x);
                output_img(x, off_i  , off_j+2) = Equation([tmp(1,3) tmp(1,4) tmp(2,3) tmp(3,2)], x);
                output_img(x, off_i  , off_j+3) = Equation([tmp(4,1) tmp(5,1) tmp(4,2) tmp(3,3)], x);
                output_img(x, off_i+1, off_j  ) = Equation([tmp(2,4) tmp(1,5) tmp(1,6) tmp(2,5) tmp(3,4)], x);
                output_img(x, off_i+1, off_j+1) = Equation([tmp(4,3) tmp(5,2) tmp(6,1) tmp(7,1) tmp(6,2)], x);
                output_img(x, off_i+1, off_j+2) = Equation([tmp(5,3) tmp(4,4) tmp(3,5) tmp(2,6) tmp(1,7) tmp(1,8)], x);
                output_img(x, off_i+1, off_j+3) = Equation([tmp(2,7) tmp(3,6) tmp(4,5) tmp(5,4) tmp(6,3) tmp(7,2)], x);
                output_img(x, off_i+2, off_j  ) = Equation([tmp(8,1) tmp(8,2) tmp(7,3) tmp(6,4) tmp(5,5) tmp(4,6) tmp(3,7)], x);
                output_img(x, off_i+2, off_j+1) = Equation([tmp(2,8) tmp(3,8) tmp(4,7) tmp(5,6) tmp(6,5) tmp(7,4) tmp(8,3)], x);
                output_img(x, off_i+2, off_j+2) = Equation([tmp(8,4) tmp(7,5) tmp(6,6) tmp(5,7) tmp(4,8) tmp(5,8) tmp(6,7)], x);
                output_img(x, off_i+2, off_j+3) = Equation([tmp(7,6) tmp(8,5) tmp(8,6) tmp(7,7) tmp(6,8) tmp(7,8) tmp(8,7) tmp(8,8)], x);
            end
        end
    end
%% Define zigzag order          %% Define dct's k       %% Define idct's k
%  1  2  6  7 15 16 28 29       % 2 2 4 4 5 5 6 6       % 2 3 4 4
%  3  5  8 14 17 27 30 43       % 3 3 4 5 5 6 6 7       % 5 5 6 6
%  4  9 13 18 26 31 42 44       % 3 4 4 5 6 6 7 7       % 7 7 7 8
% 10 12 19 25 32 41 45 54       % 4 4 5 6 6 7 7 7
% 11 20 24 33 40 46 53 55       % 4 5 6 6 7 7 7 7
% 21 23 34 39 47 52 56 61       % 5 5 6 7 7 7 7 8
% 22 35 38 48 51 57 60 62       % 5 6 7 7 7 8 8 8
% 36 37 49 50 58 59 63 64       % 7 7 7 7 8 8 8 8
    % Output
    output_img = uint8(output_img);
    for i = 1:N
        output_name = [output_path output_file num2str(i, '_%02d') '.bmp'];
        tmp = reshape(output_img(i,:,:), [height_o, width_o]);
        imwrite(tmp, output_name);
        if dsp
            subplot(1,N,i)
            imshow(tmp);
        end
    end
end

