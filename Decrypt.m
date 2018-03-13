function Decrypt(K, N, input_path, input_file, output_path, output_file)
%DECRYPT Summary of this function goes here
%   Detailed explanation goes here

    % Read in files,
    % Get width, height,
    length = size(N);
    tmp = imread([input_path input_file num2str(N(1), '%02d') '.bmp']);
    [height, width] = size(tmp);
    input_img(K, height, width) = 0;
    for i = 1:K
        input_img(i,:,:) = imread([input_path input_file num2str(N(i), '%02d') '.bmp']);
    end
    input_img = double(input_img);
    output_img( height, width*K ) = 0;

    % Solve the original secret from n shares
    for i = 1:height
        for j = 1:width
            output_img(i, ((j-1)*K+1):(j*K) ) = Solve_Eq(K, N, input_img(:, i, j));
        end
    end

    % Calculate if there is 0~4 <=> 251~255
    avg = mean(mean(output_img)) - 127;
    avg = avg / abs(avg);
    for i = 1:height
        for j = 1:width*K
            if output_img(i, j) < 5 || output_img(i, j) > 250
                output_img(i, j) = Check_neighbor(output_img, i, j, avg);
            end
        end
    end

    % Scramble back the output image
    for i = 1:height
        for j = 1:width*K
            output_img(i, j) = mod(output_img(i, j) - i - j-2, 251)+2;
        end
    end

    % Output
    output_img = uint8(output_img);
    output_name = [output_path output_file];
    imshow(output_img);
    imwrite(output_img, output_name);

    tmp = imread('Lenna.bmp');
    PSNR = psnr(output_img, tmp)
end

