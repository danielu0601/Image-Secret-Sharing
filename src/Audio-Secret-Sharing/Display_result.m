clear;

dir = 'result2/';
filename1 = [dir 'result2_dct1.wav'];
filename2 = [dir 'result2_dct9.wav'];
filename3 = [dir 'result2_dct17.wav'];
filename4 = [dir 'result2_dct25.wav'];
filename5 = [dir 'result2_dct65.wav'];
[y1, fs] = audioread(filename1);
[y2, fs] = audioread(filename2);
[y3, fs] = audioread(filename3);
[y4, fs] = audioread(filename4);
[y5, fs] = audioread(filename5);
subplot(5,1,1), plot((1:length(y1))/fs, y1);
subplot(5,1,2), plot((1:length(y2))/fs, y2);
subplot(5,1,3), plot((1:length(y3))/fs, y3);
subplot(5,1,4), plot((1:length(y4))/fs, y4);
subplot(5,1,5), plot((1:length(y5))/fs, y5);