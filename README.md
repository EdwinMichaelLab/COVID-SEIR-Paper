# COVID-SEIR-Paper

This repository contains the SEIR code associated with the paper.

## Basic Usage

Each of the 6 intervention scenarios described in the paper are found in the files Main1.m - Main6.m. To run all 6 scenarios on the first county (Alachua), you can run Master.m as follows:

`matlab -nodisplay -nosplash -r Master(1);`

which will generate output files Alachua_Scen1.mat - Alachua_Scen6.mat.

## Code Description

### Pulling data from JHU/Unacast and preparing it for use

Using Main1.m as an example, the following lines are used to download case/death data from JHU for a given county:

`[Deaths,Confirmed,NPop,timeRef] = read_county_data(Location_arr);
movement_data = get_movement_data(Location_arr, timeRef, MaxTime);`


