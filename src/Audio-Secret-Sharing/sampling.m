% sampling
%   change the input stereo audio into mono
%   and create 6 8 sec files.

clear;

filename = 'Phantom';
filetype = '.wav';
[y, fs] = audioread([filename filetype]);
%y = y * 2^15;

left = y(:,1);
right = y(:,2);
%subplot(2,1,1), plot((1:length(left))/fs, left);
%subplot(2,1,2), plot((1:length(right))/fs, right);

y12 = (left + right);
%sound(y12, fs);

audiowrite([filename '_sample'  filetype] , normal(y12               ), fs);
audiowrite([filename '_sample1' filetype] , normal(y12(fs* 1+1:fs* 9)), fs);
audiowrite([filename '_sample2' filetype] , normal(y12(fs*11+1:fs*19)), fs);
audiowrite([filename '_sample3' filetype] , normal(y12(fs*21+1:fs*29)), fs);
audiowrite([filename '_sample4' filetype] , normal(y12(fs*31+1:fs*39)), fs);
audiowrite([filename '_sample5' filetype] , normal(y12(fs*41+1:fs*49)), fs);
audiowrite([filename '_sample6' filetype] , normal(y12(fs*51+1:fs*59)), fs);

function out = normal(in)
    mgn = (65520-32768) / 32768;
    M = max(in);
    m = min(in);
    scl = max(M, abs(m)) / mgn;
    out = (in ./ scl);
end
