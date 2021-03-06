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
    L(:, 2) = N;
    L(:, 1) = 1;
    
    for i = 3:K
        L(:,i) = L(:,i-1).*L(:,2);
    end
    
    % Make the matrix upper triangle
    for i = 1:K-1
        while( sum(L(i+1:K,i)) ~= 0 )
            tmp = i;
            for j = i+1:K
                if( L(j,i) < 0 )
                    L(j,:) = -L(j,:);
                end
                if( L(tmp,i) > L(j,i) && L(j,i) > 0 )
                    tmp = j;
                end
            end
            if tmp ~= i
                L([i tmp],:) = L([tmp i],:);
            end
            for j = i+1:K
                %tmp = floor(L(j,i) / L(i,i));
                %L(j,:) = L(j,:) - tmp * L(i,:);
                L(j,:) = L(j,:) - L(i,:) * floor(L(j,i) / L(i,i));
            end
        end
    end
    
    % Calculate ans from bottom to top
    for i = K:-1:1
        L(i,K+1) = mod(L(i,K+1), 65521);
        while mod(L(i,K+1), L(i,i)) ~= 0
            L(i,K+1) = L(i,K+1) + 65521;
        end
        L(i,K+1) = L(i,K+1) / L(i,i);
        %L(i,i) = 1;
        L(1:i-1,K+1) = L(1:i-1,K+1) - L(1:i-1,i) * L(i,K+1);
        %L(1:i-1,i) = 0;
    end
    
    % Assign result to output
    sol = reshape( L(:,K+1), 1, K );
end
