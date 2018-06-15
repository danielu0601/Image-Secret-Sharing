function Decrypt_Progressive_2(input, K)
%DECRYPT Decrypt from K shares.
%   Detailed explanation goes here
    
    dsp         = input.dsp;
    permutation = input.permutation;
    key         = input.key;
    QT          = input.QT;
    input_path  = input.input_path;
    input_file  = input.input_file;
    output_path = input.output_path;
    output_file = input.output_file;

    N = 1:K;
    % Read in files,
    % Get width, height,
    %tmp = imread([input_path input_file num2str(N(1), '_%02d') '.bmp']);
    %[height, width] = size(tmp);
    input_img(K, 37888) = 0;
    for i = 1:K
        input_img(i,:) = reshape(imread([input_path input_file num2str(N(i),...
                                            '_%02d') '.bmp']), 1, []);
    end
    input_img = double(input_img);
    %height_o = height*8/3;
    %width_o = width*8/4;
    output_img( 512, 512 ) = 0;

    % Solve the original secret from n shares
    C(64,4104) = 0;
    offset = 0;
    if K > 1
        for i = 1:2:4096
            zz = Solve_Eq(2, 1:2, input_img(1:2, offset+((i+1)/2)));
            C(1,i:i+1) = zz;
        end
        offset = offset + 2048;
    end
    if K > 2
        for i = 1:3:4096
            zz = Solve_Eq(3, 1:3, input_img(1:3, offset+((i+2)/3)));
            C(2,i:i+2) = zz;
        end
        offset = offset + 1366;
    end
    if K > 3
        for i = 1:4:4096
            zz = Solve_Eq(4, 1:4, input_img(1:4, offset+((i+3)/4)));
            C(9,i:i+3) = zz;
        end
        offset = offset + 1024;
    end
    if K > 4
        for j = [10 17]
            for i = 1:5:4096
                zz = Solve_Eq(5, 1:5, input_img(1:5, offset+((i+4)/5)));
                C(j,i:i+4) = zz;
            end
            offset = offset + 820;
        end
    end
    if K > 5
        for j = [3 4 11 18 25]
            for i = 1:6:4096
                zz = Solve_Eq(6, 1:6, input_img(1:6, offset+((i+5)/6)));
                C(j,i:i+5) = zz;
            end
            offset = offset + 683;
        end
    end
    if K > 6
        for j = [5:6 12:13 19:20 26:27 33:34 41]
            for i = 1:7:4096
                zz = Solve_Eq(7, 1:7, input_img(1:7, offset+((i+6)/7)));
                C(j,i:i+6) = zz;
            end
            offset = offset + 586;
        end
    end
    if K > 7
        for j = [7:8 14:16 21:24 28:32 35:40 42:62]
            for i = 1:8:4096
                zz = Solve_Eq(8, 1:8, input_img(1:8, offset+((i+7)/8)));
                C(j,i:i+7) = zz;
            end
            offset = offset + 512;
        end
    end
    if K > 8
        for j = [63:64]
            for i = 1:9:4096
                zz = Solve_Eq(9, 1:9, input_img(1:9, offset+((i+8)/9)));
                C(j,i:i+8) = zz;
            end
            offset = offset + 456;
        end
    end
    
    
    for x = 2:64
        for y = 1:4096
            if C(x,y) > 127
                C(x,y) = C(x,y) - 251;
            end
        end
    end
    
    C(:,4097:4104) = [];
    for i = 1:64
        D(i,:,:) = reshape(C(i,:), 64, []);
    end    
    for i = 1:8
        for j = 1:8
            E(i:8:512, j:8:512) = D((i-1)*8+j,:,:);
        end
    end
    for i = 1:8:512
        for j = 1:8:512
            output_img(i:i+7,j:j+7) = round(idct2(E(i:i+7,j:j+7).*QT));
        end
    end
    
    % Scramble back the output image
    if permutation == 1
        rng(key);
        for i = 1:width_o
            tmp = randperm(height_o);
            for j=1:height_o
                tmp2(tmp(j)) = j;
            end
            output_img(tmp,i) = output_img(:,i);
        end
        rng(key);
        for i = 1:height_o
            tmp = randperm(width_o);
            for j=1:width_o
                tmp2(tmp(j)) = j;
            end
            output_img(i,tmp) = output_img(i,:);
        end
    end
    
    % Calculate if there is 0~4 <=> 251~255
%     avg = mean(mean(output_img)) - 127;
%     avg = avg / abs(avg);
%     for i = 1:512
%         for j = 1:512
%             if output_img(i, j) < 5 || output_img(i, j) > 250
%                 output_img(i, j) = Check_neighbor(output_img, i, j, avg);
%             end
%         end
%     end
    
    % Output
    output_img = uint8(output_img);
    
    org = imread(['../' 'Lenna.bmp']);
    PSNR = psnr(output_img, org);
    [ssimval, ~] = ssim(output_img, org);
    
    output_name = [output_path output_file num2str(K, '_%02d')...
                    num2str(ssimval, '_%f') num2str(PSNR, '_%f') '.bmp'];
    imwrite(output_img, output_name);
    if dsp
        imshow(output_img);
    end
end