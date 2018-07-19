% filename = 'sample.wav';
% [y, Fs] = audioread(filename);
% 
% PlayNextPart(y, 1, Fs);
% 
% y_id = 1;
% p = audioplayer(y(y_id:y_id+Fs), Fs);
% y_id = y_id + Fs;
% p.StopFcn = ['PlayNextPart( ' num2str(y_id) ')'];
% play(p);

%% Timer Example
% t = timer('TimerFcn', 'stat=false; disp(''Timer!'')',... 
%                  'StartDelay',10);
% start(t)
% 
% stat=true;
% while(stat==true)
%   disp('.')
%   pause(1)
% end

filename = 'sample.wav';
[y, Fs] = audioread(filename);

y_id = 1;

% t = timer('TimerFcn',['p = audioplayer(y(y_id:y_id+Fs), Fs);' ...
%     'y_id = y_id + Fs;' 'play(p);start(t);'], 'StartDelay', 1);
% start(t)


t = timer;
t.TimerFcn = ['q = audioplayer(y(y_id:y_id+Fs), Fs);' ...
    'y_id = y_id + Fs;' 'play(q);' 'pause(p);' 'p = q;'];
%t.TimerFcn = ['pause(p);' 'resume(p);'];
t.Period = 1;
t.TasksToExecute = 80;
t.ExecutionMode = 'fixedRate';
start(t)