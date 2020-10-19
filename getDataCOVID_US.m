%% getDataCOVID_US.m:

% FUNCTION NAME:
%   getDataCOVID_US
%
% DESCRIPTION:
%   This is a helper function that scrapes the case data from Johns
%   Hopkins' Website
%
% INPUTS:
%   None.
%
% OUTPUT:
%   tableConfirmed: A table of confirmed cases.
%   tableDeaths: A table of deaths.
%   tableRecovered: A table of recovered cases.
%   time: An array of datetime objects.

function [tableConfirmed,tableDeaths,tableRecovered,time] = getDataCOVID_US(Location_arr)
% The function [tableConfirmed,tableDeaths,tableRecovered,time] = getDataCOVID
% collect the updated data from the COVID-19 epidemy from the
% John Hopkins university [1]
% 
% References:
% [1] https://github.com/CSSEGISandData/COVID-19
% 
% Author: E. Cheynet - Last modified - 20-03-2020
% 
% see also fit_SEIQRDP.m SEIQRDP.m

%% Number of days of data
Ndays = floor(datenum(now))-datenum(2020,01,22)-1; % minus one day because the data are updated with a delay of 24 h
address = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/';
ext = '.csv';
%% Options and names for confirmed
opts = delimitedTextImportOptions("NumVariables", Ndays+11);
opts.VariableNames = ["UID",           "iso2" ,       "iso3" ,   "code3" ,   "FIPS" ,   "Admin2" ,   "Province_State",    "Country_Region" ,   "Lat" ,    "Long_" ,   "Combined_Key", repmat("day",1,Ndays+1)];
opts.VariableTypes = [repmat("string",1,11), repmat("double",1,Ndays+1)];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

filename = ['time_series_covid19_confirmed_US'];
fullName = [address,filename,ext];

%load data
confirmed_filename = 'input/time_series_covid19_confirmed_US.csv';

%test exists
if isfile(confirmed_filename)
    % File exists, then load data
    tableConfirmed =readtable(confirmed_filename, opts);
    disp("loaded confirmed from file");
else
    % File does not exist, then get data
	fname = sprintf("%s.csv", Location_arr(1))  
    urlwrite(fullName,fname);
    tableConfirmed =readtable(fname, opts);
    delete(fname)
    disp("loaded confirmed from website");
end

%% Options and names for deceased
%  One more row is used for the population!
%  Inconsistent format used by John Hopkins university

clear opts
opts = delimitedTextImportOptions("NumVariables", Ndays+12);
opts.VariableNames = ["UID",           "iso2" ,       "iso3" ,   "code3" ,   "FIPS" ,   "Admin2" ,   "Province_State",    "Country_Region" ,   "Lat" ,    "Long_" ,   "Combined_Key", "Population", repmat("day",1,Ndays+1)];
opts.VariableTypes = [repmat("string",1,11), repmat("double",1,Ndays+2)];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

filename = ['time_series_covid19_deaths_US'];
fullName = [address,filename,ext];

%load data
deaths_filename = 'input/time_series_covid19_deaths_US.csv';

%test exists
if isfile(deaths_filename)
    % File exists, then load data
    tableDeaths =readtable(deaths_filename, opts);
    disp("loaded deaths from file");
else
    % File does not exist, then get data
	fname = sprintf("%s.csv", Location_arr(1))  
    urlwrite(fullName,fname);
    tableDeaths =readtable(fname, opts);
    delete(fname)
    disp("loaded deaths from website");
end

%% Get time
time = datetime(2020,01,22):days(1):datetime(datestr(floor(datenum(now))))-datenum(1);

%% So far no data on recovered

tableRecovered = [];

end
