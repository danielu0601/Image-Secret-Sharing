% Record
%   record a 3 sec audio and compare with 4 files.
clear;

fs=8192;	% 取樣頻率
nBits=16;	% 取樣點解析度，必須是 8 或 16 或 24
nChannel=1;	% 聲道個數，必須是 1（單聲道） 或 2（雙聲道或立體音）
duration=3;	% 錄音時間（秒）
recObj=audiorecorder(fs, nBits, nChannel);


% Start to record
fprintf('Press any button to start record %g sec:\n', duration);
pause
fprintf('Recording...\n');
recordblocking(recObj, duration);
fprintf('Record End\n');
% fprintf('Press any button to play:\n');
% pause
% play(recObj);


% Get audio data from recorder
y = getaudiodata(recObj, 'double');	% get data as a double array
y = reshape(y, 1, []);
y = normal(y);
% plot((1:length(y))/fs, y);
% xlabel('Time (sec)'); ylabel('Amplitude');


% Testing
% duration = 3;
% [y fs] = audioread('result1/result_dct_112_37.0872.wav');
% y = y( fs*2.54+1:fs*5.54 );
% y = reshape(y, 1, []);
% Testing

% Read files to compare
files = [
    'result1/result_dct_048_31.7484.wav';
    'result1/result_dct_080_33.4585.wav';
    'result1/result_dct_128_40.1477.wav';
    'result1/result_dct_256_99.4816.wav'];
for i = 1:4
    [tmp, ~] = audioread(files(i,:));
    sample(i,:) = normal(resample( tmp, fs, 44100));
end


% Find delay and move to there
for i = 1:4
    delay(i) = finddelay( y, sample(i,:) );
end
re_sample = zeros(4, fs*duration);
for i = 1:4
    re_sample(i,:) = sample( i, (delay(i)+1):(delay(i)+fs*duration) );
    %re_sample(i,:) = normal( re_sample(i,:) );
end

p(1) = psnr( re_sample(1,:),y );
p(2) = psnr( re_sample(2,:),y );
p(3) = psnr( re_sample(3,:),y );
p(4) = psnr( re_sample(4,:),y );

[m, id] = max(p);
fprintf(['Best matches:' num2str(id) '\n']);

% Testing
subplot(5, 1, 1); plot( y );
subplot(5, 1, 2); plot( re_sample( 1,: ) );
subplot(5, 1, 3); plot( re_sample( 2,: ) );
subplot(5, 1, 4); plot( re_sample( 3,: ) );
subplot(5, 1, 5); plot( re_sample( 4,: ) );
% Testing


% Calculate difference and output the most similar one


% Normalize for compare
function out = normal(in)
    mgn = (65520-32768) / 32768;
    M = max(in);
    m = min(in);
    scl = max(M, abs(m)) / mgn;
    out = (in ./ scl);
end