function output = Equation(coef,x)
%EQUATION Summary of this function goes here
%   Detailed explanation goes here
    output = 0;
    [h, w] = size(coef);
    for i = 1:w
        output = output + coef(i)*x^(i-1);
    end
end

