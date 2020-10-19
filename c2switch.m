function [d] = c2switch(aij,rc,comp)
%c2 switch function
if aij >= rc
    d = 1;
elseif aij > 0
    d = 1 - (rc .* rc - aij.* aij) .* (rc .* rc - aij .* aij) .* (rc .* rc + 2 .* aij .* aij) / ((rc * rc) * (rc * rc) * (rc * rc));
else
    d = 0;
end

if comp
    d = 1 - d;
end
end

