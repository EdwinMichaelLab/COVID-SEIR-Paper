%% SEIR_covid_model.m:

% FUNCTION NAME:
%   SEIR_covid_model
%
% DESCRIPTION:
%   This is a helper function for getting the model ready for ode45().
%
% INPUTS:
%   ParamSets: Array of sampled parameters.
%   NPop: Integer, population size
%   MaxTime: Integer, how far to integrate
%   lockdown: Integer, how long to be under lockdown.
%
% OUTPUT:
%   Arrays containing the class values as a function of time.


function [S_out,E_out,IA_out,IP_out,IM_out,IH_out,IC_out,D_out,R1_out,R2_out]...
    = SEIR_covid_model(ParamSets,NPop,...
    S0,E0,IA0,IP0,IM0,IH0,IC0,D0,R10,R20,...
    StartTime,MaxTime,lockdown,lockdown_rel1, ...
    lockdown_rel2,lockdown_rel3,lockdown_rel4,lockdown_rel5,q, ...
    soc_dist_flag, soc_dist_end,quarantine_start,prog_flag,M,mr)

%% Initialize simulation

% Set initial compartment values, now passed to integrator

% initialize output arrays
S_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
E_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
IA_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
IP_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
IM_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
IH_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
IC_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
D_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
R1_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));
R2_out = zeros(MaxTime - StartTime + 1,length(ParamSets(1,:)));

% calculate value to scale progress counts 
pstep = length(ParamSets(1,:)) / 50;

% timing
simu_clk = zeros(1,length(ParamSets(1,:)));

%% Loop through calculations for each parameter set
% can run in parallel for faster computation
parfor (i = 1:length(ParamSets(1,:)), M)

    % time loop start
    simu_clk_strt = tic;
    
    %printout progress periodically to 
    %tell web service how far we have progressed
    if prog_flag & mod(i,pstep) == 0
        disp('progress')
    end

    % pull out one set of parameters
    P = ParamSets(:,i); 
    
%     beta = P(1);
%     alpha = P(2);
%     sigma = P(3);
%     rho = P(4);
%     gammaA = P(5);
%     gammaM = P(6);
%     gammaH = P(7);
%     gammaC = P(8);
%     delta1 = P(9);
%     delta2 = P(10);
%     delta3 = P(11);
%     m  = P(12);
%     lockdown_ratio = P(13);
%     epsilon = P(14);
%     x1 = P(15);
%     x2 = P(16);
%     x3 = P(17);
%     d = P(18);
    
    % numerically integrate the differential equations
    options = odeset('RelTol', 1e-5);
    [t, pop] = ode45(@diff_eqn1,StartTime:1:MaxTime,...
        [S0(i),E0(i),IA0(i),IP0(i),IM0(i),IH0(i),IC0(i),D0(i),R10(i),R20(i)],...
        options,...
       [P(1:18)', lockdown,...
       lockdown_rel1, lockdown_rel2, lockdown_rel3, ...
       lockdown_rel4, lockdown_rel5, q, soc_dist_flag, soc_dist_end,quarantine_start],mr);
   
    % store the predictions for each compartment for each parameter set
    S_out(:,i) = pop(:,1);
    E_out(:,i) = pop(:,2);
    IA_out(:,i) = pop(:,3);
    IP_out(:,i) = pop(:,4);
    IM_out(:,i) = pop(:,5);
    IH_out(:,i) = pop(:,6);
    IC_out(:,i) = pop(:,7);
    D_out(:,i) = pop(:,8);
    R1_out(:,i) = pop(:,9);
    R2_out(:,i) = pop(:,10);

    %time loop end
    simu_clk(i) = toc(simu_clk_strt);
    
end

%print compute time
disp("ODE compute time: " + (mean(simu_clk) * length(ParamSets(1,:))) + " seconds, max " + max(simu_clk) + " seconds.");

end