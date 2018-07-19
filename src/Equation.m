function output = Equation(coef,x)
%EQUATION Evaluate the equation value
%   Calculate the equation f(1) = c0 + c1x^1 + c2x^2 + ... mod p
    % Fixed to maxmima x=9 for speedup
    xxx = [
        1     1     1     1     1     1     1     1     1;
        1     2     3     4     5     6     7     8     9;
        1     4     9    16    25    36    49    64    81;
        1     8    27    64   125   216    92    10   227;
        1    16    81     5   123    41   142    80    35;
        1    32   243    20   113   246   241   138    64;
        1    64   227    80    63   221   181   100    74;
        1   128   179    69    64    71    12    47   164;
        1     5    35    25    69   175    84   125   221;];
    w = length(coef);
    output = mod( coef * xxx(1:w, x), 251 );
end

