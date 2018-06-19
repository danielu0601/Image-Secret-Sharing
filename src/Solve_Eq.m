function sol = Solve_Eq(K, N, F)
%SOLVE_EQ Solve the equation of X^(K-1)
%   Solve a0 + a1 x1 + a2 x2 + ... aK-1 xK-1
%   Using Gaussian Elimination
%   K : number of unkonwn
%   N : array of x
%   F : array of f(x)
%   result : array of result

    % Special Cases
    if( K == 2 )
        sol(2) = divide( F(2)-F(1), N(2)-N(1));
        sol(1) = mod( F(1)-sol(2)*N(1) , 251);
    elseif( K == 3 )
%         sol(2) N(2)-N(1) + sol(3) N(2)^2-N(1)^2 = F(2)-F(1);
%         sol(2) N(3)-N(1) + sol(3) N(3)^2-N(1)^2 = F(3)-F(1);
        T1 = divide(F(2)-F(1),N(2)-N(1));
        T2 = divide(F(3)-F(1),N(3)-N(1));
%         sol(2) + sol(3) N(2)+N(1) = T1;
%         sol(2) + sol(3) N(3)+N(1) = T2;
%                  sol(3) N(3)-N(2) = T2-T1;
        sol(3) = divide(T2-T1,N(3)-N(2));
        sol(2) = mod( T1-sol(3)*(N(1)+N(2)), 251);
        sol(1) = mod( F(1)-sol(3)*N(1)^2-sol(2)*N(1), 251);
    else
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
                    if( L(tmp,i) > L(j,i) && L(j,i) ~= 0 )
                        tmp = j;
                    end
                end
                if tmp ~= i
                    L([i tmp],:) = L([tmp i],:);
                end
%                 for j = i+1:K
%                     %tmp = floor(L(j,i) / L(i,i));
%                     %L(j,:) = L(j,:) - tmp * L(i,:);
%                     L(j,:) = L(j,:) - L(i,:) * floor(L(j,i) / L(i,i));
%                 end
                L(i+1:K,:) = L(i+1:K,:) - L(i,:) .* floor(L(i+1:K,i) / L(i,i));
            end
        end

        % Calculate ans from bottom to top
        for i = K:-1:1
            L(i,K+1) = mod( L(i,K+1), 251);
            L(i,i)   = mod( L(i,i)  , 251);
            L(i,K+1) = divide( L(i,K+1), L(i,i) );
%             L(i,i) = 1;
            L(1:i-1,K+1) = L(1:i-1,K+1) - L(1:i-1,i) * L(i,K+1);
%             L(1:i-1,i) = 0;
        end

        % Assign result to output
        sol = reshape( L(:,K+1), 1, K );
    end
end

function out = divide( A, B )
%Calculate (A+nP) / B
%  P = 251 in this function
%  If P changes, inv_P need to calculate again.
    inv_P = [  1 126  84  63 201  42  36 157  28 226 137  21  58  18  67 204 ...
             192  14 185 113  12 194 131 136 241  29  93   9  26 159  81 102 ...
             213  96 208   7  95 218 103 182  49   6 216  97 106 191 235  68 ...
              41 246  64 140  90 172 178 130 229  13 234 205 107 166   4  51 ...
             112 232  15  48 211 104  99 129 196 173 164 109 163 177 197  91 ...
              31 150 124   3 189 108 176 174 110  53  80 221  27 243  37  34 ...
              44 146  71 123 169  32  39  70 153  45  61  86  76  89 199  65 ...
              20 240 227 132 118 117 135 228 195 179 100  83 249   2 168 151 ...
              72  56  23 116 134 133 119  24  11 231 186  52 162 175 165 190 ...
             206  98 181 212 219  82 128 180 105 207 217 214   8 224  30 171 ...
             198 141  77  75 143  62 248 127 101 220 160  54  74  88 142  87 ...
              78  55 122 152 147  40 203 236  19 139 200 247  85 144  46  17 ...
             238  22 121  73  79 161 111 187   5 210 183  16  60 145 154  35 ...
             245 202  69 148  33 156 244  43 155  38 149 170  92 225 242 158 ...
             222  10 115 120  57 239 138  66 237  59  47 184 233 193 230 114 ...
              25 223  94 215 209  50 188 167 125 250];
      out = mod(A*inv_P(B), 251);
%     while mod(A, B) ~= 0
%         A = A + 251;
%     end
%     out = mod(A/B,251);
end