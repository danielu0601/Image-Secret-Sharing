function Decrypt_Progressive(K, input_path, input_file, output_path, output_file, dsp, permutation, key)
%DECRYPT Decrypt from K shares.
%   Detailed explanation goes here

    N = 1:K;
    % Read in files,
    % Get width, height,
    tmp = imread([input_path input_file num2str(N(1), '_%02d') '.bmp']);
    [height, width] = size(tmp);
    input_img(K, height, width) = 0;
    for i = 1:K
        input_img(i,:,:) = imread([input_path input_file num2str(N(i), '_%02d') '.bmp']);
    end
    input_img = double(input_img);
    height_o = height*8/3;
    width_o = width*8/4;
    output_img( height_o, width_o ) = 0;

    % Solve the original secret from n shares
    for i = 1:3:height
        for j = 1:4:width
            tmp = zeros(8);
            if K > 1
                zz = Solve_Eq(2, 1:2, input_img(1:2, i, j));
                tmp(1,1) = zz(1);
                tmp(1,2) = zz(2);
            end
            if K > 2
            	zz = Solve_Eq(3, 1:3, input_img(1:3, i, j+1));
                tmp(2,1) = zz(1);
                tmp(3,1) = zz(2);
                tmp(2,2) = zz(3);
            end
            if K > 3
            	zz = Solve_Eq(4, 1:4, input_img(1:4, i, j+2));
                tmp(1,3) = zz(1);
                tmp(1,4) = zz(2);
                tmp(2,3) = zz(3);
                tmp(3,2) = zz(4);
            	zz = Solve_Eq(4, 1:4, input_img(1:4, i, j+3));
                tmp(4,1) = zz(1);
                tmp(5,1) = zz(2);
                tmp(4,2) = zz(3);
                tmp(3,3) = zz(4);
            end
            if K > 4
            	zz = Solve_Eq(5, 1:5, input_img(1:5, i+1, j));
                tmp(2,4) = zz(1);
                tmp(1,5) = zz(2);
                tmp(1,6) = zz(3);
                tmp(2,5) = zz(4);
                tmp(3,4) = zz(5);
            	zz = Solve_Eq(5, 1:5, input_img(1:5, i+1, j+1));
                tmp(4,3) = zz(1);
                tmp(5,2) = zz(2);
                tmp(6,1) = zz(3);
                tmp(7,1) = zz(4);
                tmp(6,2) = zz(5);
            end
            if K > 5
            	zz = Solve_Eq(6, 1:6, input_img(1:6, i+1, j+2));
                tmp(5,3) = zz(1);
                tmp(4,4) = zz(2);
                tmp(3,5) = zz(3);
                tmp(2,6) = zz(4);
                tmp(1,7) = zz(5);
                tmp(1,8) = zz(6);
            	zz = Solve_Eq(6, 1:6, input_img(1:6, i+1, j+3));
                tmp(2,7) = zz(1);
                tmp(3,6) = zz(2);
                tmp(4,5) = zz(3);
                tmp(5,4) = zz(4);
                tmp(6,3) = zz(5);
                tmp(7,2) = zz(6);
            end
            if K > 6
            	zz = Solve_Eq(7, 1:7, input_img(1:7, i+2, j));
                tmp(8,1) = zz(1);
                tmp(8,2) = zz(2);
                tmp(7,3) = zz(3);
                tmp(6,4) = zz(4);
                tmp(5,5) = zz(5);
                tmp(4,6) = zz(6);
                tmp(3,7) = zz(7);
            	zz = Solve_Eq(7, 1:7, input_img(1:7, i+2, j+1));
                tmp(2,8) = zz(1);
                tmp(3,8) = zz(2);
                tmp(4,7) = zz(3);
                tmp(5,6) = zz(4);
                tmp(6,5) = zz(5);
                tmp(7,4) = zz(6);
                tmp(8,3) = zz(7);
            	zz = Solve_Eq(7, 1:7, input_img(1:7, i+2, j+2));
                tmp(8,4) = zz(1);
                tmp(7,5) = zz(2);
                tmp(6,6) = zz(3);
                tmp(5,7) = zz(4);
                tmp(4,8) = zz(5);
                tmp(5,8) = zz(6);
                tmp(6,7) = zz(7);
            end
            if K > 7
            	zz = Solve_Eq(8, 1:8, input_img(1:8, i+2, j+3));
                tmp(7,6) = zz(1);
                tmp(8,5) = zz(2);
                tmp(8,6) = zz(3);
                tmp(7,7) = zz(4);
                tmp(6,8) = zz(5);
                tmp(7,8) = zz(6);
                tmp(8,7) = zz(7);
                tmp(8,8) = zz(8);
            end
            tmp(1,1) = tmp(1,1) + 251;
            for x = 1:8
                for y = 1:8
                    if tmp(x,y) > 127
                        tmp(x,y) = tmp(x,y) - 251;
                    end
                end
            end
            off_i = (i-1)*8/3 +1; 
            off_j = (j-1)*8/4 +1;
            output_img(off_i:off_i+7, off_j:off_j+7) = round(idct2(tmp*8));
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
    % Scramble back the output image
    if permutation == 1
        rng(key);
        for i = 1:width_o
            tmp = randperm(height_o);
            for j=1:height_o
                tmp2(tmp(j)) = j;
            end
            output_img(:,i) = output_img(tmp2,i);
        end
        rng(key);
        for i = 1:height_o
            tmp = randperm(width_o);
            for j=1:width_o
                tmp2(tmp(j)) = j;
            end
            output_img(i,:) = output_img(i,tmp2);
        end
    end
    
    % Calculate if there is 0~4 <=> 251~255
    avg = mean(mean(output_img)) - 127;
    avg = avg / abs(avg);
    for i = 1:height_o
        for j = 1:width_o
            if output_img(i, j) < 5 || output_img(i, j) > 250
                output_img(i, j) = Check_neighbor(output_img, i, j, avg);
            end
        end
    end
    
    % Output
    output_img = uint8(output_img);
    
    org = imread('Lenna.bmp');
    PSNR = psnr(output_img, org);
    
    output_name = [output_path output_file num2str(K, '_%02d') num2str(PSNR, '_%f') '.bmp'];
    imwrite(output_img, output_name);
    if dsp
        imshow(output_img);
    end
end

