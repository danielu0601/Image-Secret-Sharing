function sol = Solve_Eq(K, N, F)
%SOLVE_EQ Solve the equation of X^(K-1)
%   Solve a0 + a1 x1 + a2 x2 + ... aK-1 xK-1
%   Using Gaussian Elimination
%   K : number of unkonwn
%   N : array of x
%   F : array of f(x)
%   result : array of result

    % Initial matrix
    L(:, K+1) = F;
    for i = 1:K
        for j = 1:K
            L(i,j) = N(i)^(j-1);
        end
    end
    
    % Make the matrix upper triangle
    for i = 1:K 
        for j = i+1:K
            while( L(j,i) >= L(i,i) )
                for m = i:K+1
                    L(j,m) = L(j,m) - L(i,m);
                end
            end
        end
    end
    
    % Calculate ans from bottom to top
    for i = K:-1:1
        L(i,K+1) =  mod(L(i,K+1), 251);
        while mod(L(i,K+1), L(i,i)) ~= 0
            L(i,K+1) = L(i,K+1) + 251;
        end
        L(i,K+1) = L(i,K+1) / L(i,i);
        L(i,i) = 1;
        for j = 1:i-1
            while L(j,i) > 0
                L(j,i) = L(j,i) - L(i,i);
                L(j,K+1) = L(j,K+1) - L(i,K+1);
            end
        end
    end
    
    % Assign result to output
    sol = reshape( L(:,K+1), 1, K );
end
