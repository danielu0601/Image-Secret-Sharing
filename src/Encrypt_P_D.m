function Encrypt_P_D( input )
%Encrypt_Progressive Encrypt the image into N shares with sensitive area
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
    
    N = input.N;
    S = input.S;
        
    % Read in files,
    [~,~,~] = mkdir(output_path);
    input_img = imread([input_path input_file]);
    input_img = double(input_img);
    
    % Get width, height,
%     [height, width] = size(input_img);
    
    % Add padding (only width need)
    width_s = ceil(width/8);
    input_img(:, (width+1):(width_s*8)) = 255*rand(height, (width_s*8) - width);
    width = width_s*8;
    height_s = height/8;
    width_s = width/8;
    
    % Do DCT
    img = zeros(height, width);
    for i = 1:8:height
        for j = 1:8:width
            img(i:i+7,j:j+7) = round( dct2( input_img(i:i+7,j:j+7) )./QT );
            img(i,j) = img(i,j) - 128;
        end
    end
    img = img + 125;
    
    % Do truncate
    for j = 1:width
        for i = 1:height
            if img(i,j) > 250
                img(i,j) = 250;
            elseif img(i,j) < 0
                img(i,j) = 0;
            end
        end
    end
    
    A = zeros(64, height_s, width_s );
    % Do Rearrange
    for j = 1:8
        for i = 1:8
            A((i-1)*8+j,:,:) = img(i:8:height, j:8:width);
        end
    end
    C = [];
    for i = Z
        C = [C reshape(A(i,:,:), 1, []) ];
    end
    
    % Do Secret Share
    % Define dct's k
	% 2 3 6 6 7 7 8 8
	% 4 5 6 7 7 8 8 8
	% 5 6 7 7 8 8 8 8
	% 6 7 7 8 8 8 8 8
	% 7 7 8 8 8 8 8 8
	% 7 8 8 8 8 8 8 8
	% 8 8 8 8 8 8 8 8
	% 8 8 8 8 8 8 9 9
    output_img(N,width*height) = 0;
    offset = 1;
    i = 1;
    K = [ 0 1 2 3 5 10 21 62 64];
    % DC
    while i < height_s*width_s*K(2)
        if( Check_S( S, i, height_s*width_s ) || Check_S( S, i+1, height_s*width_s ) )
            % Sensitive area
            tmp = [C(i:i+1) randi(250,1,N-2)];
            for x = 1:N
                output_img(x, offset) = Equation(tmp, x);
            end
        else
            % Not Sensitive area
            for x = 1:N
                output_img(x, offset) = Equation(C(i:i+1), x);
            end
        end
        offset = offset+1;
        i = i+2;
    end
    
    % AC
    for R = 3:N
        while i < height_s*width_s*K(R)
%         while i < height_s*width_s*K(3)
            % Find if overlap with sensitive area
            flag = 0;
            for new_i = i:i+R-1
%             for new_i = i:i+2
                if( Check_S( S, new_i, height_s*width_s ) )
                    flag = 1;
                    break;
                end
            end
            % Overlapped
            if( flag == 1 )
                % Do share for not Overlapped part
                if( new_i ~= i )
                    tmp = [C(i:new_i-1) randi(250,1,R-new_i+i)];
%                     tmp = [C(i:new_i-1) randi(250,1,3-new_i+i)];
                    for x = 1:N
                        output_img(x, offset) = Equation(tmp, x);
                    end
                    offset = offset+1;
                    i = new_i;
                end
                % Do share for sensitive part
                while( Check_S( S, i, height_s*width_s ) )
                    % Sensitive area
                    tmp = [C(i) randi(250,1,N-1)];
                    for x = 1:N
                        output_img(x, offset) = Equation(tmp, x);
                    end
                    i = i+1;
                    offset = offset+1;
                    % If reach EOF
                    if i == length(C)
                        break;
                    end
                end
            % Not sensitive part
            else
                % If remain length < R
                if( i+R-1 > length(C) )
                    tmp = randi(255, 1, R);
                    tmp(1:(length(C)-i+1)) = C(i:end);
                    for x = 1:N
                        output_img(x, offset) = Equation(tmp, x);
%                         output_img(x, offset) = Equation(tpm, x);
                    end
                % Normal condition
                else
                    for x = 1:N
                        output_img(x, offset) = Equation(C(i:i+R-1), x);
%                         output_img(x, offset) = Equation(C(i:i+2), x);
                    end
                end
                offset = offset+1;
                i = i+R;
%                 i = i+3;
            end
        end
    end
    
    offset = offset - 1;
    % Delete rest part and remain padding to fit output image size
    offset_s = ceil( offset * 2 / height );
    output_img(:,(offset_s*height/2+1):end) = [];
    % Give Random value to padding (to show the padding, comment out)
    output_img(:,(offset+1):(offset_s*height/2)) = randi(250,N,(offset_s*height/2)-offset);
    
    % Output
    output_img = uint8(output_img);
    for i = 1:N
        output_name = [output_path output_file num2str(i, '_%02d') '.bmp'];
%         tmp = reshape(output_img(i,:,:), [], width/2);
        tmp = reshape(output_img(i,:,:), height/2, []);
        imwrite(tmp, output_name);
%         if dsp
%             subplot(N,1,i);imshow(tmp);
%         end
    end
%     subplot(2, 1, 1);plot(C(1:2048));axis([-inf, inf, 0, 255]);
end

function out = Check_S( S, i, P )
% Return true if 'i' is in sensitive area
    i = mod(i, P);
    if( i == 0 )
        i = P;
    end
    out = sum( find( S == i ) );
end