%% BM SEIR model

%% STEP 1: Define uniform parameter prior min/max values
%parameter_priors = ... 
%    [0.1428 1.5 % 1: beta
%    2.0 2.0 % 2: alpha - set to quickly move S --> R1 at lockdown start
%    0.16 0.5 % 3: sigma inverse of 2-6 days
%    0.25 0.5 % 4: rho 25-50% of cases are asymptomatic
%    0.125 0.33 % 5: gammaA inverse of 4-14 days recovery
%    0.125 0.33 % 6: gammaM
%    0.125 0.33 % 7: gammaH
%    0.125 0.33 % 8: gammaC
%    0.05 1 % 9: delta1 inverse of 1-10 days - modified to 1-20 days
%    0.06 0.25 % 10: delta2 inverse of 4-15 days
%    0.09 1 % 11: delta3 inverse of 1-11 days
%    0.08 0.25 % 12: m
%    3 5 % 13: lockdown ratio, alpha/lambda 
%    0.1 0.3 % 14: epsilon, proportion of symptomatic cases undetected
   % 0.05 0.3 % 15: x1
%    0.2 0.3 % 16: x2 
%    0.2 0.8 % 17: x3
%    0.1 0.4 % 18: d 1-[0.58 0.85]
%    2 500]; % 19: E0
%
%%other parameters
%%fit to section of fit from start?
%fit_to_section = false;
%
%%number of samples to retain after RMSD sorting
%%NOTE: nSelectFitting >= nSelectSimulating
%nSelectFitting = 1000;
%nSelectSimulating = 1000;
%
%%make sure >
%nSelectFitting = max(nSelectFitting, nSelectSimulating);

%%% STEP 2: Randomly sample parameter sets from prior distributions
%ParamSets = SampleParamSets(nDraws,parameter_priors);
%ParamSets(:, 1)
%ParamSets(:, 500)
%%save originals for blending
%ParamSets_orig = ParamSets;
%
%%% STEP 3: Run the model using sampled parameter sets up to the last time for which we have data
%% setup IC
%% Set initial compartment values
%IA0 = zeros(1,nDraws) + 0/NPop;
%%pred_C = cumsum((1-epsilon).*IP.*delta1*NPop);
%IP0 = Confirmed(1) ./ ((1-ParamSets(14,:)) .* ParamSets(9, :) .* NPop);
%%IP0 = zeros(1,nDraws) + 2/NPop;
%IM0 = zeros(1,nDraws) + 0/NPop;
%IH0 = zeros(1,nDraws) + 0/NPop;
%IC0 = zeros(1,nDraws) + 0/NPop;
%%Deaths = NPop*D
%D0  = zeros(1,nDraws) + Deaths(1)/NPop;
%%D0  = zeros(1,nDraws) + 0/NPop;
%R10 = zeros(1,nDraws) + 0/NPop;
%R20 = zeros(1,nDraws) + 0/NPop;
%% 
%% % E0 and S0 defined in parfor loop
%%INPop = 1/NPop;
%E0 = ParamSets(19,:) .* INPop; % E0 = P(19)/NPop;
%S0 = (1 - IA0(1) - IP0(1) - IM0(1) - IH0(1) - IC0(1) - D0(1) - R10(1) - R20(1)) - E0; % S0 = 1 - sum([E0,IA0,IP0,IM0,IH0,IC0,D0,R10,R20]);

%initialize traj. storage
%S = S0; E = E0; IA = IA0; IP = IP0; IM = IM0; IH = IH0;
%IC = IC0; D = D0; R1 = R10; R2 = R20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setup segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setup segments
%equi-spaced?%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%segment_length = 14;
%loops = floor(length(timeRef) / segment_length);
%
%lookup for segments
%segment_steps = zeros(1,loops + 1);

%current_step = 1;

%for i = 1:loops
%    segment_steps(i) = current_step;
%    current_step = current_step + segment_length;
%end

%get ending point
%if length(timeRef) - current_step < segment_length
%    current_step = length(timeRef);
%end

%segment_steps(end) = current_step;

%user designated?%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%segment_steps = [1 14 length(timeRef)];

%show steps
%segment_steps

%loop over segments
%for i = 1:(length(segment_steps) - 1)
%    current_step = segment_steps(i)
%    segment_end = segment_steps(i+1);
    
    % solve first fortnight
%    [S0,E0,IA0,IP0,IM0,IH0,IC0,D0,R10,R20] = SEIR_covid_model(ParamSets,NPop,...
%        S(end,:),E(end,:),IA(end,:),IP(end,:),IM(end,:),IH(end,:),IC(end,:),D(end,:),R1(end,:),R2(end,:),...
%        current_step,segment_end,lockdown,lockdown_rel1,lockdown_rel2,lockdown_rel3,...
%        lockdown_rel4,lockdown_rel5,q,soc_dist_flag,soc_dist_end,quarantine_start,prog_flag,M,mr);
    %size(S0)

    % prepend IC, the first point is at t0
%    S = [S; S0(2:end,:)];
%    E = [E; E0(2:end,:)];
%    IA = [IA; IA0(2:end,:)];
%    IP = [IP; IP0(2:end,:)];
%    IM = [IM; IM0(2:end,:)];
%    IH = [IH; IH0(2:end,:)];
%    IC = [IC; IC0(2:end,:)];
%    D = [D; D0(2:end,:)];
%    R1 = [R1; R10(2:end,:)];
%    R2 = [R2; R20(2:end,:)];
%    
%    % lets grab the reasonable trajectories,
    % we use a form of relative RMSE as a distance metric to indicate how far 
    % the model outputs are from the observed case data. The RMSE is calculated 
    % based on cumulative confirmed case counts and deaths.
    % First, we need to calculate the model-predicted cumulative confirmed 
    % cases. We assume the number of new cases that will be detected each day to 
    % be a fraction of those leaving presymptomatic class and entering the 
    % symptomatic pipeline. We assume epsilon of those are mildly symptomatic 
    % cases that will not get tested/reported.
%    epsilon = ParamSets(14,:);
%    delta1 = ParamSets(9, :);
    %fit to this section? or from start?
    %if from start we need the pred_C from start
%    if fit_to_section
%        pred_C = cumsum((1-epsilon).*IP0.*delta1*NPop);
%        fit_start = current_step;
%    else
%        pred_C = cumsum((1-epsilon).*IP.*delta1*NPop);
%        fit_start = 1;
   % end
    
    %NOTE: I was fitting to the current segment, seems to work better from
    %the start to the current point!
    % Reformat model predictions and observed data for confirmed
    %% cases and deaths
    
%    x1 = pred_C(1:length(Confirmed(fit_start:segment_end)),:); % model-predicted cumulative cases
%    y1 = Confirmed(fit_start:segment_end)'; % observed cumulative cases
%    x2 = NPop*D(1:length(Confirmed(fit_start:segment_end)),:); % model-predicted deaths
%    y2 = Deaths(fit_start:segment_end)'; % observed deaths
    
    % calculate combined RMSE metric, MSE normalized by standard deviation to
    % avoid higher weighting of confirmed cases than deaths (there are much 
    % fewer deaths than cases!)
%    RMSE = sqrt(mean(((x1-y1).^2)./std(x1))); % Only fit to Confirmed cases for now
%    [x,ind] = sort(RMSE);
    
    % select the best nSelectFitting (200) parameter sets based on the corresponding RMSE metric
%    id = ind(1:nSelectFitting);
    
    %ParamSets = ParamSets(:,id);
    %Now take selected trajectories 
    % Set initial compartment values
%    S = S(:,id); E = E(:,id); IA = IA(:,id); IP = IP(:,id); IM = IM(:,id); 
%    IH = IH(:,id); IC = IC(:,id); D = D(:,id); R1 = R1(:,id); R2 = R2(:,id);
    
    %and parameters
%    ParamSets = ParamSets(:,id);
    
    %if last loop don't bother with replicating traj. and new priors
%    if i < length(segment_steps) - 1

        %replicate traj. to get nDraw simulations.
        %number of replications
%        nReplicas = nDraws / nSelectFitting;

%        S = repmat(S,1,nReplicas);
%        E = repmat(E,1,nReplicas);
%        IA = repmat(IA,1,nReplicas);
%        IP = repmat(IP,1,nReplicas);
%        IM = repmat(IM,1,nReplicas);
%        IH = repmat(IH,1,nReplicas);
%        IC = repmat(IC,1,nReplicas);
%        D = repmat(D,1,nReplicas);
%        R1 = repmat(R1,1,nReplicas);
%        R2 = repmat(R2,1,nReplicas);

        %Create new priors? Only if not end of loop
 %       disp("creating new parameters")
        %get range from selected priors
        %note we have culled ParamSets by here
        %selectedParamSets = ParamSets(:,id);
%        parameter_priors_new=[min(ParamSets,[],2) max(ParamSets,[],2)];
        %Randomly sample parameter sets from prior distributions
%        ParamSets = SampleParamSets(nDraws,parameter_priors_new);

        %blend with original set
%        blend_probability = 0.25;

        %throw rands, and take that proportion from original
        %currently does NOT blend within parameter sets!
%        R = rand(1,nDraws);
%        ParamSets(:,R<blend_probability) = ParamSets_orig(:,R<blend_probability);
%    end
%end

%disp("End of fitting")

%% STEP 4: Select best-fitting models based on distance metric 
%NOTE: we only need to do this if nSelectFitting > nSelectSimulating

% we use a form of relative RMSE as a distance metric to indicate how far 
% the model outputs are from the observed case data. The RMSE is calculated 
% based on cumulative confirmed case counts and deaths.

% First, we need to calculate the model-predicted cumulative confirmed 
% cases. We assume the number of new cases that will be detected each day to 
% be a fraction of those leaving presymptomatic class and entering the 
% symptomatic pipeline. We assume epsilon of those are mildly symptomatic 
% cases that will not get tested/reported.
%epsilon = ParamSets(14,:);
%delta1 = ParamSets(9, :);

%pred_C = cumsum((1-epsilon).*IP.*delta1*NPop);

% Define the last time point of data to use for fitting (3 options)

% Option 1: use all data (normal case)
%endt = length(Confirmed); % all data

% Option 2: manual implementation of sequential fitting - change endt to 
%% indicate how many days of data to fit, run the model with each endt and 
% compare 
% endt = round(0.4 * length(Confirmed)); % 40% of data
% endt = round(0.6 * length(Confirmed)); % 60% of data
% endt = round(0.8 * length(Confirmed)); % 85% of data

% Option 3: fit only to pre-lockdown data
% endt = find(timeRef == datetime('27-Mar-2020')); % up to start of lockdown

% Based on endt, reformat model predictions and observed data for confirmed
% cases and deaths
%x1 = pred_C(1:length(Confirmed(1:endt)),:); % model-predicted cumulative cases
%y1 = Confirmed(1:endt)'; % observed cumulative cases
%x2 = NPop*D(1:length(Confirmed(1:endt)),:); % model-predicted deaths
%y2 = Deaths(1:endt)'; % observed deaths

% calculate combined RMSE metric, MSE normalized by standard deviation to
% avoid higher weighting of confirmed cases than deaths (there are much 
% fewer deaths than cases!)
%RMSE = sqrt(mean([((x1-y1).^2)./std(x1);((x2-y2).^2)./std(x2)]));
%RMSE = sqrt(mean(((x1-y1).^2)./std(x1))); % Only fit to Confirmed cases for now

% select the best nSelectSimulating (200) parameter sets based on the corresponding RMSE metric
%[x,i] = sort(RMSE);
%id = i(1:nSelectSimulating);
%ParamSets = ParamSets(:,id);

%% STEP 5: Run the model for the full simulation period using the sampled parameter sets
%% setup IC
% Set initial compartment values
%S0 = S(:,id);
%E0 = E(:,id);
%IA0 = IA(:,id);
%IP0 = IP(:,id);
%IM0 = IM(:,id);
%IH0 = IH(:,id);
%IC0 = IC(:,id);
%D0 = D(:,id);
%R10 = R1(:,id);
%R20 = R2(:,id);

%save(sprintf('EndOfScen1_%s.mat', county))

%solve, start from t0 so t dependent values aligned
[S,E,IA,IP,IM,IH,IC,D,R1,R2] = SEIR_covid_model(ParamSets,NPop,...
    S0(end,:),E0(end,:),IA0(end,:),IP0(end,:),IM0(end,:),IH0(end,:),IC0(end,:),D0(end,:),R10(end,:),R20(end,:),...
    length(timeRef),MaxTime,...
    lockdown,lockdown_rel1, lockdown_rel2, lockdown_rel3, lockdown_rel4, ...
    lockdown_rel5, q,soc_dist_flag,soc_dist_end,quarantine_start, prog_flag, M, mr);

% prepend IC, the first point is at t0
S = [S0; S(2:end,:)];
E = [E0; E(2:end,:)];
IA = [IA0; IA(2:end,:)];
IP = [IP0; IP(2:end,:)];
IM = [IM0; IM(2:end,:)];
IH = [IH0; IH(2:end,:)];
IC = [IC0; IC(2:end,:)];
D = [D0; D(2:end,:)];
R1 = [R10; R1(2:end,:)];
R2 = [R20; R2(2:end,:)];
%% STEP 6: Remove outliers 
% based on infected predictions at the end of the simulation period

%infected = NPop*(E+IA+IP+IM+IH+IC);
%out = isoutlier(infected(end,:));

%S = S(:,~out);
%E = E(:,~out);
%IA = IA(:,~out);
%IP = IP(:,~out);
%IM = IM(:,~out);
%IH = IH(:,~out);
%IC = IC(:,~out);
%D = D(:,~out);
%R1 = R1(:,~out);
%R2 = R2(:,~out);

%ParamSets = ParamSets(:,~out);

% recalcuate the predicted cumulative confirmed cases for full simulation
% period
epsilon = ParamSets(14,:);
delta1 = ParamSets(9, :);

pred_C = cumsum((1-epsilon).*IP.*delta1*NPop);
