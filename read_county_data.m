%% read_county_data.m:

% FUNCTION NAME:
%  read_county_data.m
%
% DESCRIPTION:
%   Parses the Johns Hopkins Database output, and returns the
%   number of confirmed cases, deaths, and time stamps. If more than one
%   location is given, it will add the functions together.
%
% INPUTS:
%   Locations: Array of locations (strings) to get data for.
%
% OUTPUT:
%   Deaths, Confirmed: Arrays of deaths and confirmed over time.
%   Npop: Integer, Population Size
%   timeRef: List of datetime objects.

function [Deaths,Confirmed,Npop,timeRef,FIPS] = read_county_data(Location_array)

% Scrape confirmed case and death data from Johns Hopkins database.
[tableConfirmed,tableDeaths,~,time] = getDataCOVID_US(Location_array);
timeRef = time;
fprintf(['Most recent update: ',datestr(time(end)),'\n']) % print time of most recent update

%grab Combined_Keys from csv
Locations = strings(Location_array.size(1));
FIPS = zeros(Location_array.size(1),1);
for i=1:Location_array.size(1)
    indX = find(ismember(tableConfirmed.Country_Region,Location_array(i,3))==1 ...
        & ismember(tableConfirmed.Province_State,Location_array(i,2))==1 ...
        & ismember(tableConfirmed.Admin2,Location_array(i,1))==1);
    Locations(i) = tableConfirmed.Combined_Key(indX);
    FIPS(i) = tableConfirmed.FIPS(indX);
end

% If Location array has more than one element, loop over locations and add.
Deaths = zeros(1, length(table2array(tableDeaths(200, 13:end))));
Confirmed = zeros(1, length(table2array(tableConfirmed(200, 12:end))));
Npop = zeros(1, length(table2array(tableDeaths(200, 12))));

for i=1:length(Locations)
    Locations(i)
    try % find indices in table for confirmed cases and deaths pertaining to the specified location
        indC = find(contains(tableConfirmed.Combined_Key,Locations(i))==1);
        indD = find(contains(tableDeaths.Combined_Key,Locations(i))==1);
    catch exception % for searching a string pattern of locations when exact spelling/name is unknown? need to check further
        searchLoc = strfind(tableConfirmed.Combined_Key,Locations(i));
        indC = find(~cellfun(@isempty,searchLoc))  ;

        searchLoc = strfind(tableDeaths.Combined_Key,Locations(i));
        indD = find(~cellfun(@isempty,searchLoc))   ;
    end

    disp(tableConfirmed(indC,11)); % confirm that specified county was found in the table
    % if a single location is given.
    if length(indC) == 1
        indC = indC(1); % first instance in table, in case of duplicates?
        indD  = indD(1); % first instance in table, in case of duplicates?
        Deaths = Deaths + table2array(tableDeaths(indD,13:end)); % daily death counts
        Confirmed = Confirmed  + table2array(tableConfirmed(indC,12:end)); % daily confirmed case counts
        Npop = Npop + table2array(tableDeaths(indD,12)); % population (dummy number here)

    % if more than one location comes back (a state or larger region)
    elseif length(indC) > 1
            for i = 1:length(indC)
                this_indC = indC(i);
                this_indD = indD(i);
                Deaths = Deaths + table2array(tableDeaths(this_indD,13:end)); % daily death counts
                Confirmed = Confirmed + table2array(tableConfirmed(this_indC,12:end)); % daily confirmed case counts
                Npop = Npop + table2array(tableDeaths(this_indD,12)); % population (dummy number here)
            end
    end
end

end
