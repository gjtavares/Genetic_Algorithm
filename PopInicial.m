function [X] = PopInicial(N)

lb = 1;  % lower bound
ub = 3;  % upper bound
X  = (lb + (ub-lb).*rand(N,500));
X  = round(X);

end

