%% Main.m:

% Updated code can be downloaded from https://github.com/EdwinMichaelLab/covid_model_SEIR.git

% FUNCTION NAME:
%   Main
%
% DESCRIPTION:
%   This is the main function for the project. Calls necessary functions to accept inputs from user, run model, and produce output.
%
% INPUTS:
%   1) Locations (Array) : An array containing the locations to model. Can be an array
%   with a single element to model only one location, or a list of locations.
%   If the list has more than one location, Confirmed + Death data will be
%   summed together to form a single dataset.
%
%   2) parameter_priors (Array): The array of priors. Each row represents a
%   different parameter, with a lower and upper bound provided for each
%   parameter.
%
%   3) sim_time (Int): How many days to predict (beyond the dataset).
%
%   4) lockdown_start (datetime): Date to start lockdown.
%
%   5) lockdown_end (datetime): Date to end lockdown.
%
% OUTPUT:
%   out - We need to discuss proper output with CRC. This could be a PNG
%   file, raw (x,y) data, or whatever would be most convenient.

clearvars;
close all
clc;

%% Setup random
rng('default');
rng(1234);

%% INPUTS AND SETUP
%maximum cores to use
M = 128;

% Define counties to model and read data from Johns Hopkins
% Format for each county: "County", "State", "US";
% Location_arr = ["Hillsborough", "Florida", "US";"Polk", "Florida", "US";...
%     "Pasco", "Florida", "US";"Pinellas", "Florida", "US"];
load('FloridaCounties.mat');
global countyid
for i = countyid
    fprintf('Processing county %s\n', counties(i));
    full = strtrim(counties(i).split(','));
    county = full(1);
    state = full(2);
    country = full(3);
    load(sprintf('EndOfScen1_%s.mat', county));
    Location_arr = [county, state, country;];
    
    [Deaths,Confirmed,NPop,timeRef] = read_county_data(Location_arr);
    
    
    % Choose the number of days to simulate beyond latest data (data typically
    % available through yesterday's date)
    % sim_time = 60;
    
    % Start modeling local epidemic when at least 5 cases were confirmed, effectively
    % remove leading zeros from dataset
    minNum = min(Confirmed(length(timeRef)-2),2);
    Deaths(Confirmed<minNum)=[];
    timeRef(Confirmed<minNum)= [];
    Confirmed(Confirmed<minNum)=[];
    
    % Stop fitting at September 30th
    nd = abs(days(timeRef(end) - datetime(2020, 09, 30)));
    Deaths = Deaths(1:end-nd);
    timeRef = timeRef(1:end-nd);
    Confirmed = Confirmed(1:end-nd);
    
    MaxTime = days(datetime(2022,02,31) - timeRef(1)); % length(timeRef)+sim_time;
    
    % Set Lockdown Start date (Florida's stay-at-home order = March 27th, 2020.)
    lockdown_start = datetime(2020, 03, 27);
    
    % Set a series of 5 lockdown release dates. These must be later than the
    % lockdown start date set above. If you do not want to release lockdown,
    % set all five dates to be later than the simulation period (ex. set the
    % year out in the future to 2022). The amount of lockdown release at each
    % date is set in the function diff_eqn1.m.
    lockdown_release_1 = datetime(2020, 11, 30); % this should stay fixed now since they've started lifting lockdown in FL
    lockdown_release_2 = datetime(2020, 05, 18);
    lockdown_release_3 = datetime(2020, 06, 01);
    lockdown_release_4 = datetime(2020, 06, 15);
    lockdown_release_5 = datetime(2020, 06, 29);
    
    % Set up series of times to progressively turn off lockdown
    lockdown = days(lockdown_start - timeRef(1));
    lockdown_rel1 = days(lockdown_release_1 - timeRef(1));
    lockdown_rel2 = days(lockdown_release_2 - timeRef(1));
    lockdown_rel3 = days(lockdown_release_3 - timeRef(1));
    lockdown_rel4 = days(lockdown_release_4 - timeRef(1));
    lockdown_rel5 = days(lockdown_release_5 - timeRef(1));
    
    
    % Set social distancing end date
    soc_dist_flag = 0; % 1 to keep on, 0 to turn off at specified date
    soc_dist_end_date = datetime(2020, 11, 30);
    soc_dist_end = days(soc_dist_end_date - timeRef(1));
    
    % Set quarantine option
    % q represents the proportion of asymptomatic/presymptomatic/mild cases that
    % are detected through contact tracing and quarantined, effectively
    % preventing them from exposing others and producing new cases
    % scenarios: 0, 0.25, 0.5, 0.75
    quarantine_start_date = datetime(2020, 05, 20);
    quarantine_start = days(quarantine_start_date - timeRef(1));
    q = 0;

	% Get movement data
    movement_data = get_movement_data(Location_arr, timeRef, MaxTime);
    movement_ratio_data = movement_data./(1-movement_data);
    % simple moving average
    movement_ratio_data = movmean(movement_ratio_data, 7);
    ndays = 7;
    for i=1:ndays:length(movement_ratio_data)
         if i + ndays < length(movement_ratio_data)
             movement_ratio_data(i:i+ndays) = mean(movement_ratio_data(i:i+ndays));
         else
             movement_ratio_data(i:end) = mean(movement_ratio_data(i:end));
         end
    end
	mr = movement_ratio_data;

    % number of prior parameter sets to sample, default 50000
    nDraws = 50000;
    
    % do not allow progress output for web
    prog_flag = false;
    
    %% CALL BM SEIR MODEL
    BM_SEIR_model2()
    
    save(sprintf('%s_Scen3.mat',county));
    
    %% PLOT OUTPUTS
    % plot_model_predictions(pred_C,Confirmed,D,Deaths,NPop,E,IA,IP,IM,IH,IC,R2,MaxTime,sim_time,timeRef,ParamSets);
    
end
