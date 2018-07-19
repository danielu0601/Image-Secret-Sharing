function PlayNextPart(y, y_id, Fs)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    p = audioplayer(y(y_id:y_id+2*Fs), Fs);
    y_id = y_id + 2*Fs;
    p.StopFcn = ['PlayNextPart(y, ' num2str(y_id) ', Fs)'];
    %play(p);
    playblocking(p);
    
    
%     filename = 'sample2.wav';
%     [y, Fs] = audioread(filename);
% 
%     y_id = 1;
%     p = audioplayer(y(y_id:y_id+Fs), Fs);
%     y_id = y_id + Fs;
%     p.StopFcn = ['PlayNextPart( ' num2str(y_id) ')'];
%     play(p);
end

