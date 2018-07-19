clear;

dct_size = 256;
dir = 'result8/';
filename = 'Phantom_sample3_8192.wav';
[y, fs] = audioread(filename);
y = reshape(y,1,[]);        % y = -1~1
y = y * 2^15;               % y = -32768 ~ 32767


% scale the date to fit dct_size 
[~, len_o] = size(y);
len_n = ceil(len_o/dct_size)*dct_size;
if len_n > len_o
    y(len_n) = 0;
end
len = len_n;


% Do DCT
t_y = zeros(1, len);
for i = 1:dct_size:len      % t_y = -32768*N ~ 32767*N
    t_y(i:i+dct_size-1) = dct(y(i:i+dct_size-1));
end


% Find Quantization table
max_y = zeros(1, dct_size);
min_y = zeros(1, dct_size);
for i = 1:dct_size
    max_y(i) = max( t_y(i:dct_size:len) );
    min_y(i) = min( t_y(i:dct_size:len) );
end
QT = ceil( max(max_y, abs(min_y)) ./ 2^15 );


% Do quantize
for i = 1:dct_size:len      % t_y = -32768 ~ 32767
    t_y(i:i+dct_size-1) = t_y(i:i+dct_size-1 ) ./ QT;
end
t_y = round(t_y + 2^15);    % t_y = 0 ~ 65535


% Write QT to file for decrypt
fileID = fopen([dir 'QT.txt'],'w');
fprintf(fileID,'%s\t%d\t%d\n', filename, len, fs);
for i = 1:dct_size
    fprintf(fileID, '%d', QT(i));
    if( mod(i, 16) == 0 )
        fprintf(fileID, '\n');
    else
        fprintf(fileID, '    ');
    end
end
fclose(fileID);


% Do Secret Sharing
%   range   shares
%   1:  8    2 * 4
%   9: 23    3 * 5
%  24: 47    4 * 6
%  48: 87    5 * 8
%  88:147    6 * 10
% 148:224    7 * 11
% 225:256    8 * 4
Scale = [1 9 24 48 88 148 225 256];
N = 8;
e_y = zeros(N,len*3/16); % = 48/256
for x = 1:N
    offset = 1;
    for i = 1:dct_size:len
        for j = 2:8
            for k = Scale(j-1):j:Scale(j)-1
                e_y(x, offset) = Equation(t_y(i+k-1:i+k+j-1-1), x);
                offset = offset + 1;
            end
        end
    end
end
e_y = (e_y ./ 2^15) - 1; % e_y = -1 ~ 1


% Write Shares to file
for i = 1:N
    audiowrite([dir 'Share' num2str(i, '_%d') '.wav'], e_y(i,:), fs/4);
end


% Read from Shares (...)
%   Skip Here
%   Assume I had read the files.


% Decrypt from shares
e_y = (e_y+1) .* 2^15;
d_y = zeros(1, len);
offset = 1;
for i = 1:dct_size:len
    for j = 2:8
        for k = Scale(j-1):j:Scale(j)-1
            d_y(i+k-1:i+k+j-1-1) = Solve_Eq(j, 1:j, e_y(1:j, offset));
            offset = offset + 1;
        end
    end
end


% Do Dequatization
d_y = (d_y ./ 2^15) - 1;           % d_y = -1 ~ 1
for i = 1:dct_size:len
    d_y(i:i+dct_size-1) = d_y(i:i+dct_size-1) .* QT;
end


% Do Dequatization for t_y for plot, can be deleted.
% t_y = (t_y ./ 2^15) - 1;           % t_y = -1 ~ 1
% for i = 1:dct_size:len
%     t_y(i:i+dct_size-1) = t_y(i:i+dct_size-1) .* QT;
% end


% Write decrypted audio to file
y = y / 2^15;
n_y = zeros(1, len);
for counter = [4:4:15 16:16:dct_size]
    for i = 1:dct_size:len
        n_y(i:i+dct_size-1) = idct( [d_y(i:i+counter-1) zeros(1,dct_size-counter)]);
%        n_y(i:i+dct_size-1) = idct( [zeros(1,dct_size-counter) ...
%            d_y(i+dct_size-counter:i+dct_size-1)] );
    end
    
    n_y = normal(n_y);
    audiowrite([dir 'result_dct' num2str(counter, '_%03d_')...
        num2str(psnr(n_y, y), '%02.04f') '.wav'], n_y, fs);
end


% subplot(3, 1, 1);plot(t_y);
% subplot(3, 1, 2);plot(d_y);
% subplot(3, 1, 3);plot(d_y-t_y);

% subplot(3, 1, 1);plot(y);
% subplot(3, 1, 2);plot(n_y);
% subplot(3, 1, 3);plot(n_y-y);

% subplot(6,1,1);plot(t_y);
% subplot(6,1,2);plot(d_y);
% subplot(6,1,3);plot(e_y(1,:));
% subplot(6,1,4);plot(e_y(2,:));
% subplot(6,1,5);plot(e_y(3,:));
% subplot(6,1,6);plot(e_y(4,:));


function out = normal(in)
    mgn = (65520-32768) / 32768;
    M = max(in);
    m = min(in);
    scl = max(M, abs(m)) / mgn;
    out = (in ./ scl);
end
