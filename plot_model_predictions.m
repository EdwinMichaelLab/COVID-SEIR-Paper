%% plot_model_predictions.m:

% FUNCTION NAME:
%  plot_model_predictions.m
%
% DESCRIPTION:
%   Produces plots of the model predictions.
%
% INPUTS:
%   
%
% OUTPUT:
%   None. Will plot to screen.

function plot_model_predictions(pred_C,Confirmed,D,Deaths,NPop,E, IA,IP,IM,...
    IH,IC,R2,MaxTime,sim_time,timeRef,ParamSets)

ending_timeref = timeRef(end)+sim_time;
timeRef = timeRef(1):ending_timeref;

%% plot observed vs predicted cumulative cases counts
figure;

y = quantile(pred_C,[0.025 0.50 0.975],2);

plot(1:MaxTime,y(:,2),'-k'); % median
hold on;
plot(1:MaxTime,y(:,1),'--k'); % median
plot(1:MaxTime,y(:,3),'--k'); % median

plot(1:length(Confirmed),Confirmed,'ob','MarkerFace','b');

ylabel('Cumulative symptomatic cases');
xt = xticks;
c = xt(2)-xt(1);
xticklabels(char(timeRef(1:c:end)));
xtickangle(45);
title('Model predictions vs observed confirmed cases');

%% plot observed vs predicted deaths
figure;

y = quantile(D*NPop,[0.025 0.50 0.975],2);

semilogy(1:MaxTime,y(:,2),'-k'); % median
hold on;
semilogy(1:MaxTime,y(:,1),'--k'); % median
semilogy(1:MaxTime,y(:,3),'--k'); % median

semilogy(1:length(Deaths),Deaths,'ob','MarkerFace','b');

ylabel('Deaths');
xt = xticks;
c = xt(2)-xt(1);
xticklabels(char(timeRef(1:c:end)));
xtickangle(45);
title('Model predictions vs observed deaths');

%% plot epidemic curve

% 1) the number of actively infectious cases that have been confirmed (some mild symptomatic, hospitalized, ICU)
epsilon = ParamSets(14,:); % proportion of cases not detected

I_confirmed = (1-epsilon).*(IM+IH+IC)*NPop;

% 2) the number of actively infectious cases that are unreported (asymptomatic, presymptomatic, some symptomatic)

I_undetected = (IA+IP+epsilon.*(IM+IH+IC))*NPop;
% should be equal to (IA+IP+IM+IH+IC) - I_confirmed from above?

total_infected = NPop*(E+IA+IP+IM+IH+IC);
figure;

%I = NPop*(IA+IP+IM+IH+IC);
y = quantile(total_infected,[0.025 0.50 0.975],2);

semilogy(1:MaxTime,y(:,2),'-k'); % median
hold on;
semilogy(1:MaxTime,y(:,1),'--k'); % median
semilogy(1:MaxTime,y(:,3),'--k'); % median

x2 = find(y(:,2) == max(y(:,2)));
x1 = find(y(:,1) == max(y(:,1)));
x3 = find(y(:,3) == max(y(:,3)));
ax = gca;
ylim = ax.YLim;
%line([x2 x2] ,[0 ylim(2)]);
%line([x1 x1] ,[0 ylim(2)]);
%line([x3 x3] ,[0 ylim(2)]);
set(ax,'YLim',[0 ylim(2)]);

xt = xticks;
c = xt(2)-xt(1);
xticklabels(char(timeRef(1:c:end)));
xtickangle(45);

ylabel('Total Infected Cases');
title('Total Infected Cases');

figure;

%I = NPop*(IA+IP+IM+IH+IC);
y = quantile(I_undetected,[0.025 0.50 0.975],2);

semilogy(1:MaxTime,y(:,2),'-k'); % median
hold on;
semilogy(1:MaxTime,y(:,1),'--k'); % median
semilogy(1:MaxTime,y(:,3),'--k'); % median

x2 = find(y(:,2) == max(y(:,2)));
x1 = find(y(:,1) == max(y(:,1)));
x3 = find(y(:,3) == max(y(:,3)));
ax = gca;
ylim = ax.YLim;
line([x2 x2] ,[0 ylim(2)]);
line([x1 x1] ,[0 ylim(2)]);
line([x3 x3] ,[0 ylim(2)]);
set(ax,'YLim',[0 ylim(2)]);

xt = xticks;
c = xt(2)-xt(1);
xticklabels(char(timeRef(1:c:end)));
xtickangle(45);

ylabel('Undetected Infectious Cases');
title('Undetected Infectious Cases');

%% plot hospitalized cases
figure;

I = NPop*(IH);
y = quantile(I,[0.025 0.50 0.975],2);

semilogy(1:MaxTime,y(:,2),'-k'); % median
hold on;
semilogy(1:MaxTime,y(:,1),'--k'); % median
semilogy(1:MaxTime,y(:,3),'--k'); % median

x2 = find(y(:,2) == max(y(:,2)));
x1 = find(y(:,1) == max(y(:,1)));
x3 = find(y(:,3) == max(y(:,3)));
ax = gca;
ylim = ax.YLim;
line([x2 x2] ,[0 ylim(2)]);
line([x1 x1] ,[0 ylim(2)]);
line([x3 x3] ,[0 ylim(2)]);
set(ax,'YLim',[0 ylim(2)]);

xt = xticks;
c = xt(2)-xt(1);
xticklabels(char(timeRef(1:c:end)));
xtickangle(45);

ylabel('IH');
title('Hospitalized cases');

%% plot ICU cases
figure;

I = NPop*(IC);
y = quantile(I,[0.025 0.50 0.975],2);

semilogy(1:MaxTime,y(:,2),'-k'); % median
hold on;
semilogy(1:MaxTime,y(:,1),'--k'); % median
semilogy(1:MaxTime,y(:,3),'--k'); % median

x2 = find(y(:,2) == max(y(:,2)));
x1 = find(y(:,1) == max(y(:,1)));
x3 = find(y(:,3) == max(y(:,3)));
ax = gca;
ylim = ax.YLim;
line([x2 x2] ,[0 ylim(2)]);
line([x1 x1] ,[0 ylim(2)]);
line([x3 x3] ,[0 ylim(2)]);
set(ax,'YLim',[0 ylim(2)]);

xt = xticks;
c = xt(2)-xt(1);
xticklabels(char(timeRef(1:c:end)));
xtickangle(45);

ylabel('IC');
title('ICU cases');

end