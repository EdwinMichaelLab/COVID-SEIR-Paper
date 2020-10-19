%% get_movement_data.m:

% FUNCTION NAME:
%   get_movement_data
%
% DESCRIPTION:
%   This function downloads the Unacast social distancing movement dataset
%   for a given list of locations.
%
% INPUTS:
%   1) Locations (Array) : An array containing the locations to model. Can be an array
%   with a single element to model only one location, or a list of locations.
%   If the list has more than one location, Confirmed + Death data will be
%   summed together to form a single dataset.
%
%   2) timeRef
%
% OUTPUT:
%   movement_data
function movement_data = get_movement_data(Location_arr, timeRef, MaxTime)
%% Download data from Unacast and uncompress if not previously downloaded.
%load data
county_movement_filename = 'sds-full-county.csv';
state_movement_filename = 'sds-full-state.csv';

bad_counties = ["Bay", "Jackson", "Monroe", "Okaloosa", "Santa Rosa", "Suwannee", "Walton", "Washington"];

% Download data if not already on disk
if isfile(county_movement_filename) && isfile(state_movement_filename)
    county_data = readtable(county_movement_filename);
    state_data = readtable(state_movement_filename);
    disp("loaded movement from file");
else
    [y, m, d] = ymd(timeRef(end) - 3) % The movement data is always a couple days behind.
    y = sprintf('%04d', y);
    m = sprintf('%02d', m); % ensure there is a leading 0.
    d = sprintf('%02d', d); % ensure there is a leading 0.
    url1 = sprintf("https://storage.googleapis.com/uc-data4good/US SDS/%s-%s-%s/sds-v3-full-county.csv.gz", y, m, d)
    url2 = sprintf("https://storage.googleapis.com/uc-data4good/US SDS/%s-%s-%s/sds-v3-full-state.csv.gz", y, m, d)
    o = weboptions('CertificateFilename','');
    websave("sds-full-county.csv.gz", url1, o);
    websave("sds-full-state.csv.gz", url2, o);
    gunzip("sds-full-county.csv.gz");
    gunzip("sds-full-state.csv.gz");
    county_data = readtable("./sds-full-county.csv");
    state_data = readtable("./sds-full-state.csv");
    disp("loaded movement from website");
end

% Get state field from first entry in Location array.
state = Location_arr(1, 2);
county = Location_arr(1, 1);

%% Align movement data with timeRef
county_data = county_data(strcmp(county_data.county_name, county + " County"), :);
county_data = county_data(strcmp(county_data.state_name, state), :);
%state_data = state_data(:, [6 14]); % daily visitation diff
county_data = county_data(:, [8 16]);
if sum(isnan(table2array(county_data(:, 2)))) > 0
    disp("NaNs found. Using state-level data.");
    % Go with state data.
    state_data = state_data(strcmp(state_data.state_name, state), :);
    data = state_data(:, [6 14]); % daily visitation diff 
elseif ismember(county, bad_counties)
    disp("Bad county. Using state-level data.");
    % Go with state data.
    state_data = state_data(strcmp(state_data.state_name, state), :);
    data = state_data(:, [6 14]); % daily visitation diff  
else
    disp("Using county-level data.")
    % We interpret negative values as reduction in movement. Any positive data
    % is interpreted as 0 movement.
    data = table2array(county_data(:, 2));
    if ~isempty(data(data>0))
        disp("The movement function goes above 0. Setting this values to zero (0.01).")
        data(data>0) = 0.01;
        county_data(:, 2) = array2table(data);
        data = county_data;
    end
end

data = sortrows(data);

[vals, idx] = intersect(table2array(data(:, 1)), timeRef);

data = data(idx(1):end, :);

%% Use the latest estimate of the movement data to make predictions going forward
movement_data = abs(table2array(data(:, 2)))';
num_days_to_add = MaxTime - length(movement_data)
movement_data(end:end+num_days_to_add) = movement_data(end);
end
