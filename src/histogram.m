img = imread('result_01.bmp');
cal = zeros(1,251);
for i = 1:172
    for j = 1:256
        cal( img(j,i)+1 ) = cal( img(j,i)+1 ) +1;
    end
end
plot( 0:250, cal, 'LineWidth', 4 );
xlabel('Values');
ylabel('Frequency');
title('Histogram of Share #1');
set(gca,'fontsize',20,'LineWidth',2);
grid on