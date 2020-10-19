function Y = step(X)
%HEAVISIDE Step function.
if X >= 0
    Y = c2switch(X, 4, false);
else
    Y = 0;
end
% Y = zeros(size(X));
% Y(X > 0) = 1;
% Y(X == 0) = .5;
end