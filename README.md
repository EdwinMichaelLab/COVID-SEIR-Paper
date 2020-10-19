# COVID-SEIR-Paper

This repository contains the SEIR code associated with the paper.

## Basic Usage

Each of the 6 intervention scenarios described in the paper are found in the files Main1.m - Main6.m. To run all 6 scenarios on the first county (Alachua), you can run Master.m as follows:

`matlab -nodisplay -nosplash -r Master(1);`

which will generate output files Alachua_Scen1.mat - Alachua_Scen6.mat.

## Code Description

We will use Main1.m as an example.

### Pulling data from JHU/Unacast and preparing it for use

The following lines are used to download case/death data from JHU, and the mobility data from Unacast, for a given county:

```
[Deaths,Confirmed,NPop,timeRef] = read_county_data(Location_arr);
movement_data = get_movement_data(Location_arr, timeRef, MaxTime);
```

### Interventions (lockdown release, social distancing, and quarantine)

The proportion of those in lockdown is given from the mobility data. lockdown
release is specified using the lockdown_release_1 parameter:

`lockdown_release_1 = timeRef(end);`

Similarly, social distancing is estimated from the fit, unless the following
variables are set appropriately:

```
soc_dist_flag = 0; % 1 to keep on, 0 to turn off at specified date
soc_dist_end_date = timeRef(end);
```

Finally, quarantine strength and start date are set with the following code:

```
quarantine_start_date = datetime(2020, 10, 01);
q = 0;
```

### Model Definition

The differential equations are implemented in diff_eqn1.m:

```
dPop(1) = -d*beta*S*((1-q)*(IA+IP+IM)+IH+IC) - alpha*S +lambda*R1; % S
dPop(2) = d*beta*S*((1-q)*(IA+IP+IM)+IH+IC) - sigma*rho*E - sigma*(1-rho)*E; % E
dPop(3) = sigma*rho*E - gammaA*IA; % IA
dPop(4) = sigma*(1-rho)*E - delta1*IP; % IP
dPop(5) = delta1*IP - x1*delta2*IM - (1-x1)*gammaM*IM; % IM
dPop(6) = x1*delta2*IM - x2*delta3*IH - (1-x2)*gammaH*IH; % IH
dPop(7) = x2*delta3*IH - (1-x3)*gammaC*IC - x3*m*IC; % IC
dPop(8) = x3*m*IC; % D
dPop(9) = alpha*S -lambda*R1; % R1
dPop(10) = gammaA*IA + (1-x1)*gammaM*IM + (1-x2)*gammaH*IH + (1-x3)*gammaC*IC; % R2
```
