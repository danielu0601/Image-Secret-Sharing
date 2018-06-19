function output = Equation(coef,x)
%EQUATION Evaluate the equation value
%   Calculate the equation f(1) = c0 + c1x^1 + c2x^2 + ... mod p
    % Fixed to maxmima x=9 for speedup
    xxx = [1  1   1   1   1   1   1   1   1;
           1  2   4   8  16  32  64 128   5;
           1  3   9  27  81 243 227 179  35;
           1  4  16  64   5  20  80  69  25;
           1  5  25 125 123 113  63  64  69;
           1  6  36 216  41 246 221  71 175;
           1  7  49  92 142 241 181  12  84;
           1  8  64  10  80 138 100  47 125;
           1  9  81 227  35  64  74 164 221;];
    w = length(coef);
    output = mod( sum( coef .* xxx(x, 1:w) ), 251 );
%     p = 251;
%     output = 0;
%     xx = 1;
%     for i = 1:w
%         output = output + coef(i)*xx;
%         xx = mod(xx*x, p);
%     end
%     output = mod(output, p);
end

