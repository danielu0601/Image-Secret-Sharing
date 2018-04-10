function output = Equation(coef,x)
%EQUATION Evaluate the equation value
%   Calculate the equation f(x) = c0 + c1x^1 + c2x^2 + ...
    output = 0;
    [h, w] = size(coef);
    for i = 1:w
        output = output + coef(i)*x^(i-1);
    end
    output = mod(output, 251);
end

