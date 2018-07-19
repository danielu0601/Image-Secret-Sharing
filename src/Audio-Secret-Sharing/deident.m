clear;

dct_size = 1024;
dir = 'dei6/';
[~,~] = mkdir(dir);
filename = 'Speech_sample2_8192.wav';
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

% Do Secret Sharing

% Write Shares to file

% Read from Shares (...)
%   Skip Here
%   Assume I had read the files.

% Decrypt from shares
d_y = t_y;

% Do Dequatization
d_y = (d_y ./ 2^15) - 1;           % d_y = -1 ~ 1
for i = 1:dct_size:len
    d_y(i:i+dct_size-1) = d_y(i:i+dct_size-1) .* QT;
end


% Do Dequatization for t_y for plot, can be deleted.
t_y = (t_y ./ 2^15) - 1;           % t_y = -1 ~ 1
for i = 1:dct_size:len
    t_y(i:i+dct_size-1) = t_y(i:i+dct_size-1) .* QT;
end


% Write decrypted audio to file
y = y / 2^15;
n_y = zeros(1, len);

% Min
for big = 768:16:1024
    for i = 1:dct_size:len
        [B, I] = mink( abs(d_y(i:i+dct_size-1)), big);
        tmp = zeros(1,dct_size);
        tmp(I) = d_y(I+i-1);
        n_y(i:i+dct_size-1) = idct(tmp);
    end
    
    n_y = normal(n_y);
    audiowrite([dir 'result_min' num2str(big, '_%03d_')...
        num2str(psnr(n_y, y), '%02.04f') '.wav'], n_y, fs);
end

% Max
for big = 16:16:128
    for i = 1:dct_size:len
        [B, I] = maxk( abs(d_y(i:i+dct_size-1)), big);
        tmp = zeros(1,dct_size);
        tmp(I) = d_y(I+i-1);
        n_y(i:i+dct_size-1) = idct(tmp);
    end
    
    n_y = normal(n_y);
    audiowrite([dir 'result_max' num2str(big, '_%03d_')...
        num2str(psnr(n_y, y), '%02.04f') '.wav'], n_y, fs);
end

% mv = 92;
% for i = 1:dct_size:len
%     tmp = zeros(1,dct_size);
%     tmp( 1:4:dct_size ) = d_y( i:4:i+dct_size-1 );
% %     tmp( 1:dct_size-mv ) = d_y( (i+mv):(i+dct_size-1) );
% %     tmp( dct_size-mv+1:dct_size ) = d_y( i:(i+mv-1) );
%     n_y(i:i+dct_size-1) = idct(tmp);
% end
% sound(n_y);

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

% subplot(4,1,1);i =  1;plot(d_y(i:i+dct_size-1));
% subplot(4,1,2);i = 11;plot(d_y(i:i+dct_size-1));
% subplot(4,1,3);i = 21;plot(d_y(i:i+dct_size-1));
% subplot(4,1,4);i = 31;plot(d_y(i:i+dct_size-1));

function out = normal(in)
    mgn = (65520-32768) / 32768;
    M = max(in);
    m = min(in);
    scl = max(M, abs(m)) / mgn;
    out = (in ./ scl);
end
