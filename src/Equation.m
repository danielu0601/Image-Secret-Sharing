function output = Equation(coef,x)
%EQUATION Evaluate the equation value
%   Calculate the equation f(1) = c0 + c1x^1 + c2x^2 + ... mod p
    p = 251;
    w = length(coef);
    output = 0;
    xx = 1;
    for i = 1:w
        output = output + coef(i)*xx;
        xx = mod(xx*x, p);
    end
    output = mod(output, p);
end

