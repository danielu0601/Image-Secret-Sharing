function Decrypt(K, N, input_path, input_file, output_path, output_file, scramble, dsp)
%DECRYPT Summary of this function goes here
%   Detailed explanation goes here

    % Read in files,
    % Get width, height,
    length = size(N);
    tmp = imread([input_path input_file num2str(N(1), '_%02d') '.bmp']);
    [height, width] = size(tmp);
    input_img(K, height, width) = 0;
    for i = 1:K
        input_img(i,:,:) = imread([input_path input_file num2str(N(i), '_%02d') '.bmp']);
    end
    input_img = double(input_img);
    output_img( height, width*K ) = 0;

    % Solve the original secret from n shares
    for i = 1:height
        for j = 1:width
            output_img(i, ((j-1)*K+1):(j*K) ) = Solve_Eq(K, N, input_img(:, i, j));
        end
        %imshow(uint8(output_img));
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
    if scramble > 0
        rand('seed',scramble);
        for i = 1:height
            for j = 1:width*K
                if scramble == 1
                    output_img(i, j) = mod(output_img(i, j) - i - j -2, 251) +2;
                else
                    output_img(i, j) = mod(output_img(i, j) - round(255*rand()) -2, 251) +2;
                end
            end
        end
    end

    % Output
    output_img = uint8(output_img);
    output_name = [output_path output_file];
    imwrite(output_img, output_name);
    if dsp
        imshow(output_img);
    end
end

