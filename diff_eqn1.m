%% diff_eqn1.m:

% FUNCTION NAME:
%   diff_eqn1
%
% DESCRIPTION:
%   This function defines our system of ODEs that we are integrating
%   via ode45().
%
% INPUTS:
%   t: Array of timesteps.
%   pop0: Array of initial class values
%   P: Array of parameters.
%
% OUTPUT:
%   None.

function dPop = diff_eqn1(t,pop0,P,mr)

%% Define variables
beta = P(1);
alpha = P(2);
sigma = P(3);
rho = P(4);
gammaA = P(5);
gammaM = P(6);
gammaH = P(7);
gammaC = P(8);
delta1 = P(9);
delta2 = P(10);
delta3 = P(11);
m  = P(12);
lockdown_ratio = P(13);
epsilon = P(14);
x1 = P(15);
x2 = P(16);
x3 = P(17);
d = P(18);
lockdown = P(19);
rel1 = P(20);
rel2 = P(21);
rel3 = P(22);
rel4 = P(23);
rel5 = P(24);
q = 0; %start at zero, switch on after date. P(25);
soc_dist_flag = P(26);
soc_dist_end = P(27);
quarantine_start = P(28);

%% Make intervention modifications

% do not model social distancing or contact tracing/quaranting pre-lockdown
if (~soc_dist_flag)
    if (t >= soc_dist_end)
        d = P(18) + (1 - P(18)) * c2switch(t - soc_dist_end, 4, false); %1 - (rc * rc - aij * aij) * (rc * rc - aij * aij) * (rc * rc + 2 * aij * aij) / ((rc * rc) * (rc * rc) * (rc * rc));
    end
end

% if after quarantine start, switch
if t > quarantine_start
    q = P(25) * c2switch(t - quarantine_start, 4, false);
    %q = 0;
end

lambda = alpha/mr(floor(t));

if t > rel1
	alpha = 0;
	lambda = 2;
end

%% Define class values at first time step
S = pop0(1);
E = pop0(2);
IA = pop0(3);
IP = pop0(4);
IM = pop0(5);
IH = pop0(6);
IC = pop0(7);
D = pop0(8);
R1 = pop0(9);
R2 = pop0(10);

%% Define differential equations for each compartment
dPop = zeros(length(pop0),1);

%dPop(1) = -d*beta*S*((1-q)*(IA+IP+IM)+IH+IC) - (c2switch(t-lockdown, 4, false)*c2switch(t-rel5, 4, true)*alpha*S) + (c2switch(t-lockdown, 4, false)*c2switch(t-rel5, 4, true)*lambda*R1); % S
dPop(1) = -d*beta*S*((1-q)*(IA+IP+IM)+IH+IC) - alpha*S +lambda*R1; % S
dPop(2) = d*beta*S*((1-q)*(IA+IP+IM)+IH+IC) - sigma*rho*E - sigma*(1-rho)*E; % E
dPop(3) = sigma*rho*E - gammaA*IA; % IA
dPop(4) = sigma*(1-rho)*E - delta1*IP; % IP
dPop(5) = delta1*IP - x1*delta2*IM - (1-x1)*gammaM*IM; % IM
dPop(6) = x1*delta2*IM - x2*delta3*IH - (1-x2)*gammaH*IH; % IH
dPop(7) = x2*delta3*IH - (1-x3)*gammaC*IC - x3*m*IC; % IC
dPop(8) = x3*m*IC; % D
%dPop(9) = (c2switch(t-lockdown, 4, false)*c2switch(t-rel5, 4, true)*alpha*S) - (c2switch(t-lockdown, 4, false)*c2switch(t-rel5, 4, true)*lambda*R1); % R1
dPop(9) = alpha*S -lambda*R1; % R1
dPop(10) = gammaA*IA + (1-x1)*gammaM*IM + (1-x2)*gammaH*IH + (1-x3)*gammaC*IC; % R2

end
