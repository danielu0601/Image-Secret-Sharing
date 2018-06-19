function Decrypt_P_D(input, K)
%DECRYPT Decrypt from K shares.
% Get parameter
%     dsp         = input.dsp;
    QT          = input.QT;
    Z           = input.Z;
    width       = input.width;
    height      = input.height;
    input_path  = input.input_path;
    input_file  = input.input_file;
    output_path = input.output_path;
    output_file = input.output_file;
    
    height_s = height/8;
    width_s = width/8;
    
    N = 1:K;
    % Read in files, turns back into 1D array
%     input_img(K, width) = 0;
    for i = 1:K
        tmp = reshape(imread([input_path input_file num2str(N(i),'_%02d') '.bmp']), 1, []);
        input_img(i, :) = reshape(tmp, 1, []);
    end
    input_img = double(input_img);
    output_img = zeros( height, width );
    
    %%%
    % NOT DONE
    % Solve the Equations
    K_a = [ 0 1 2 3 5 10 21 62 64];
    C(1:height*width) = 125;
    offset_i = 1;
    offset_C = 1;
    % 2 or more Shares
    if K >= 2
%         while( offset_C < length(input_img) )
        while( offset_C < height_s*width_s )
            zz = Solve_Eq(2, 1:2, input_img(1:2, offset_i));
            C(offset_C:offset_C+1) = zz;
            offset_i = offset_i + 1;
            offset_C = offset_C + 2;
        end
         % 3 or more Shares
        if K >= 3
            % Find out the sensitive area first
            S = [];
            offset_i = 1; % i for input_img ptr
            offset_C = 1; % C for output_img ptr
            while( offset_C < height_s*width_s )
                zz = Solve_Eq(2, [1, 3], input_img([1, 3], offset_i));
                if( C(offset_C:offset_C+1) ~= zz)
                    S = [S offset_C offset_C+1];
                    zz = Solve_Eq(K, 1:K, input_img(1:K, offset_i));
                    C(offset_C:offset_C+1) = zz(1:2);
                end
                offset_i = offset_i + 1;
                offset_C = offset_C + 2;
            end
            % Solve the remaining with known S.
            for R = 3:K
                while offset_C < height_s*width_s*K_a(R)
                    % Find if overlap with sensitive area
                    flag = 0;
                    for new_i = offset_C:offset_C+R-1
                        if( Check_S( S, new_i, height_s*width_s ) )
                            flag = 1;
                            break;
                        end
                    end
                    % Overlapped
                    if( flag == 1 )
                        % Solve share for not Overlapped part
                        if( new_i ~= offset_C )
                            zz = Solve_Eq(R, 1:R, input_img(1:R, offset_i));
                            C(offset_C:new_i-1) = zz(1:new_i-offset_C);
                            offset_i = offset_i + 1;
                            offset_C = new_i;
                        end
                        % Solve share for sensitive part
                        while( Check_S( S, offset_C, height_s*width_s ) )
                            % Sensitive area
                            zz = Solve_Eq(K, 1:K, input_img(1:K, offset_i));
                            C(offset_C) = zz(1);
                            offset_C = offset_C+1;
                            offset_i = offset_i+1;
                            % If reach EOF
                            if offset_C == length(C)
                                break;
                            end
                        end
                    % Not sensitive part
                    else
%                         % If remain length < R
%                         if( offset_C+R-1 > length(C) )
%                             tmp = randi(255, 1, R);
%                             tmp(1:(length(C)-offset_C+1)) = C(offset_C:end);
%                             for x = 1:N
%                                 output_img(x, offset_i) = Equation(tmp, x);
%                             end
                        % Normal condition
%                         else
%                             for x = 1:N
%                                 output_img(x, offset_i) = Equation(C(offset_C:offset_C+R-1), x);
%                             end
%                         end
                        zz = Solve_Eq(R, 1:R, input_img(1:R, offset_i));
                        C(offset_C:offset_C+R-1) = zz;
                        offset_i = offset_i+1;
                        offset_C = offset_C+R;
                    end
                end
            end
        end
    end
%     C = randi( 250, 1, height*width );
%     subplot(2, 1, 2);plot(C(1:2048));axis([-inf, inf, 0, 255]);
    %%%
    
    % Rearrange back to original shape
    offset = 1;
    for i = Z
        tmp = reshape( C(offset:(offset+height_s*width_s-1)), height_s, width_s );
%         i = ii*8 + (jj-8);
        ii = ceil(i / 8);
        jj = mod( i, 8 );
        if jj == 0
            jj = 8;
        end
        output_img(ii:8:height, jj:8:width) = tmp;
        offset = offset + height_s*width_s;
    end
    
    % Do IDCT
    output_img = output_img - 125;
    for i = 1:8:height
        for j = 1:8:width
            output_img(i,j) = output_img(i,j) + 128;
            output_img(i:i+7,j:j+7) = round(idct2(output_img(i:i+7,j:j+7).*QT));
        end
    end
    
    % Do truncate
    for i = 1:512
        for j = 1:512
            if output_img(i,j) > 255
                output_img(i,j) = 255;
            end
            if output_img(i,j) < 0
                output_img(i,j) = 0;
            end
        end
    end
    
    % Output
    output_img = uint8(output_img);
    
    org = imread('../Lenna.bmp');
    PSNR = psnr(output_img, org);
    [ssimval, ~] = ssim(output_img, org);
    
    output_name = [output_path output_file num2str(K, '_%02d')...
                    num2str(ssimval, '_%f') num2str(PSNR, '_%f') '.bmp'];
    imwrite(output_img, output_name);
%     if dsp
%         imshow(output_img);
%     end
end

function out = Check_S( S, i, P )
% Return true if 'i' is in sensitive area
    i = mod(i, P);
    if( i == 0 )
        i = P;
    end
    out = sum( find( S == i ) );
end