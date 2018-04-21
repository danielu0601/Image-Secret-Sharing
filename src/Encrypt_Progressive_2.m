function Encrypt_Progressive_2(input_path, input_file, output_path, output_file,...
    dsp, permutation, key, QT)
%Encrypt_Progressive Encrypt the image into N shares
%   Expect 8*8's multiple of image size

    N = 9;
    % Read in files,
    % Get width, height,
    % Padding
    [~,~,~] = mkdir(output_path);
    input_img = imread([input_path input_file]);
    input_img = double(input_img);
    [height, width] = size(input_img);
    width_n = ceil(width/8);
    input_img(height, width_n*8) = input_img(height, width);
    input_img(:, (width+1):(width_n*8)) = round(255*rand(height, (width_n*8) - width));
    width = width_n*8;
    
    height_o = height/8;
    width_o = width/8;

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

    % Do DCT and rearrange
    img = imread('../Lenna.bmp');
    img = double(img);
    for i = 1:8:height
        for j = 1:8:width
            img(i:i+7,j:j+7) = round(dct2(img(i:i+7,j:j+7))./QT);
        end
    end
    for i = 1:8
        for j = 1:8
            B((i-1)*8+j,:,:) = img(i:8:512, j:8:512);
        end
    end
    C(64,4104) = 0;
    for i = 1:64
        C(i,1:4096) = reshape(B(i,:,:), 1, []);
    end

    % Distribute to n shares
    output_img(8,37888) = 0;
    for x = 1:N
        offset = 0;
        
        for i = 1:2:4096
            output_img(x, offset+((i+1)/2)) = Equation([C(1,i) C(1,i+1)], x);
        end
        offset = offset + 2048;
        
        for i = 1:3:4096
            output_img(x, offset+((i+2)/3)) = Equation([C(2,i) C(2,i+1) C(2,i+2)],...
                x);
        end
        offset = offset + 1366;
        
        for i = 1:4:4096
            output_img(x, offset+((i+3)/4)) = Equation([C(9,i) C(9,i+1) C(9,i+2)...
                C(9,i+3)], x);
        end
        offset = offset + 1024;
        
        for j = [10 17]
            for i = 1:5:4096
                output_img(x, offset+((i+4)/5)) = Equation([C(j,i) C(j,i+1) C(j,i+2)...
                    C(j,i+3) C(j,i+4)], x);
            end
            offset = offset + 820;
        end
        for j = [3 4 11 18 25]
            for i = 1:6:4096
                output_img(x, offset+((i+5)/6)) = Equation([C(j,i) C(j,i+1) C(j,i+2)...
                    C(j,i+3) C(j,i+4) C(j,i+5)], x);
            end
            offset = offset + 683;
        end
        for j = [5:6 12:13 19:20 26:27 33:34 41]
            for i = 1:7:4096
                output_img(x, offset+((i+6)/7)) = Equation([C(j,i) C(j,i+1) C(j,i+2)...
                    C(j,i+3) C(j,i+4) C(j,i+5) C(j,i+6)], x);
            end
            offset = offset + 586;
        end
        for j = [7:8 14:16 21:24 28:32 35:40 42:62]
            for i = 1:8:4096
                output_img(x, offset+((i+7)/8)) = Equation([C(j,i) C(j,i+1) C(j,i+2)...
                    C(j,i+3) C(j,i+4) C(j,i+5) C(j,i+6) C(j,i+7)], x);
            end
            offset = offset + 512;
        end
        for j = [63:64]
            for i = 1:9:4096
                output_img(x, offset+((i+8)/9)) = Equation([C(j,i) C(j,i+1) C(j,i+2)...
                    C(j,i+3) C(j,i+4) C(j,i+5) C(j,i+6) C(j,i+7) C(j,i+8)], x);
            end
            offset = offset + 456;
        end
    end
    
    
    % Output
    output_img = uint8(output_img);
    for i = 1:N
        output_name = [output_path output_file num2str(i, '_%02d') '.bmp'];
        tmp = reshape(output_img(i,:,:), [], 256);
        imwrite(tmp, output_name);
        if dsp
            subplot(1,N,i)
            imshow(tmp);
        end
    end
end
