A = zeros(8,8);
B = zeros(8,8);
B(1,1) = 1000;
C = zeros(200,8,8);
for i = 1:1000000
    tmp = dct2( randi( 16, 8, 8 ) );
    tmp = tmp .* 16;
    A = max( A, tmp );
    B = min( B, tmp );
    tmp(1,1) = tmp(1,1) - 1024;
    for j = 1:8
        for k = 1:8
            C( round(tmp(j,k)/5)+100,j,k ) = C( round(tmp(j,k)/5)+100,j,k ) +1;
        end
    end
end
A = round(A);
B = round(B);

subplot(2,1,1);plot( 505:5:1500, C(:, 1, 1) );
subplot(2,1,2);plot( -495:5:500, C(:, 8, 8) );

%MIN DC
for i = 1:200
    if sum(C(1:i,1,1)) / sum(C(:,1,1)) * 1000 > 1
        disp(['MIN DC:' num2str(i*5+500)]);
        break;
    end
end
%MAX DC
for i = 1:200
    if sum(C(i:200,1,1)) / sum(C(:,1,1)) * 1000 < 1
        disp(['MAX DC:' num2str(i*5+500)]);
        break;
    end
end
% MIN AC
for i = 1:200
    if sum(C(1:i,8,8)) / sum(C(:,8,8)) * 1000 > 1
        disp(['MIN AC:' num2str(i*5-500)]);
        break;
    end
end
% MAX AC
for i = 1:200
    if sum(C(i:200,8,8)) / sum(C(:,8,8)) * 1000 < 1
        disp(['MAX AC:' num2str(i*5-500)]);
        break;
    end
end
