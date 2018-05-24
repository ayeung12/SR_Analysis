%%initial cleaning and organization
valid = ~isnan(testing.Response);
testValid = testing(valid, :); 

trial1 = testValid.TrialType == 1;
trial2 = testValid.TrialType == 2;
trial3 = testValid.TrialType == 3; 

resp = testValid.Response;
resp(resp == 6) = 1;
resp(resp == 4) = 0;

trialLeft = testValid.Side == 180;
trialRight = testValid.Side == 0;

lineWidth = testValid.LineWidth;
lineWidth(trialLeft) = -lineWidth(trialLeft);

lineWidth1 = lineWidth(trial1);
resp1 = resp(trial1);

lineWidth2 = lineWidth(trial2);
resp2 = resp(trial2);

lineWidth3 = lineWidth(trial3);
resp3 = resp(trial3);

isRight = testValid.Side;
isRight(trialRight) = 1;
isRight(trialLeft) = 0;

continuous_fast = (testValid.TrialType == 3) & (testValid.dTheta == 8);
continuous_slow = (testValid.TrialType == 3) & (testValid.dTheta == 4);
jitter_full = (testValid.TrialType == 2) & (testValid.dTheta == 8);
jitter_half = (testValid.TrialType == 2) & (testValid.dTheta == 4);

lineWidthFast = lineWidth(continuous_fast);
respFast = resp(continuous_fast);
lineWidthSlow = lineWidth(continuous_slow);
respSlow = resp(continuous_slow);
lineWidthFull = lineWidth(jitter_full);
respFull = resp(jitter_full);
lineWidthHalf = lineWidth(jitter_half);
respHalf = resp(jitter_half);

eccentricity_low = testValid.Eccentricity < 4;
eccentricity_medium = testValid.Eccentricity == 5;
eccentricity_high = testValid.Eccentricity > 6;
lineWidthLow = lineWidth(eccentricity_low);
respLow = resp(eccentricity_low);
lineWidthMedium = lineWidth(eccentricity_medium);
respMedium = resp(eccentricity_medium);
lineWidthHigh = lineWidth(eccentricity_high);
respHigh = resp(eccentricity_high);
%% plot psychometric curves
fit_params = [];

figure
jmpspace = linspace(-6, 6, 10000);
%trial type 1 (static)
[B] = glmfit(lineWidth1, resp1, 'binomial');
fit_params(1,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidth1, resp1, 10, 'bo', 'filled')
hold on

%trial type 2 (jitter)
[B] = glmfit(lineWidth2, resp2, 'binomial');
fit_params(2,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
resp2(resp2 == 1) = 1.05;
resp2(resp2 == 0) = -.05;
scatter(lineWidth2, resp2, 10, 'ro', 'filled')
hold on

%trial type 3 (continuous)
[B] = glmfit(lineWidth3, resp3, 'binomial');
fit_params(3,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'g')
hold on
resp3(resp3 == 1) = 1.1;
resp3(resp3 == 0) = -.1;
scatter(lineWidth3, resp3, 10, 'go', 'filled')
hold on

axis([-8 8 -0.15 1.15])
title('Motion Type Full Comparison');
save(['data_fit/P' int2str(par) '_fit_params.mat'], 'fit_params');
%% signal detection theory 

% [trial1c, trial1dp] = signalDetection(isRight(trial1), resp(trial1));
% [trial2c, trial2dp] = signalDetection(isRight(trial2), resp(trial2));
% [trial3c, trial3dp] = signalDetection(isRight(trial3), resp(trial3));

%% Plotting new data
fit_params = [];
figure
%continuous_slow
[B] = glmfit(lineWidthSlow, respSlow, 'binomial');
fit_params(1,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidthSlow, respSlow, 10, 'bo', 'filled')
hold on

%continuous_fast
[B] = glmfit(lineWidthFast, respFast, 'binomial');
fit_params(2,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
respFast(respFast == 1) = 1.05;
respFast(respFast == 0) = -.05;
scatter(lineWidthFast, respFast, 10, 'ro', 'filled')
hold on

axis([-8 8 -0.15 1.15])
title('Continuous Motion Comparison');
save(['data_fit/P' int2str(par) '_fit_params_continuous.mat'], 'fit_params');

fit_params = [];
figure
%jitter_half
[B] = glmfit(lineWidthHalf, respHalf, 'binomial');
fit_params(1,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidthHalf, respHalf, 10, 'bo', 'filled')
hold on

%jitter_full
[B] = glmfit(lineWidthFull, respFull, 'binomial');
fit_params(2,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
respFull(respFull == 1) = 1.1;
respFull(respFull == 0) = -.1;
scatter(lineWidthFull, respFull, 10, 'ro', 'filled')
hold on
axis([-8 8 -0.15 1.15])
title('Jitter Motion Comparison');
save(['data_fit/P' int2str(par) '_fit_params_jitter.mat'], 'fit_params');

fit_params = [];
figure
%trial type 1 (small circle)
[B] = glmfit(lineWidthLow, respLow, 'binomial');
fit_params(1,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidthLow, respLow, 10, 'bo', 'filled')
hold on
%trial type 2 (medium circle)
[B] = glmfit(lineWidthMedium, respMedium, 'binomial');
fit_params(2,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
respMedium(respMedium == 1) = 1.05;
respMedium(respMedium == 0) = -.05;
scatter(lineWidthMedium, respMedium, 10, 'ro', 'filled')
hold on

%trial type 3 (big circle)
[B] = glmfit(lineWidthHigh, respHigh, 'binomial');
fit_params(3,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'g')
hold on
respHigh(respHigh == 1) = 1.1;
respHigh(respHigh == 0) = -.1;
scatter(lineWidthHigh, respHigh, 10, 'go', 'filled')
hold on
axis([-8 8 -0.15 1.15])
title('Eccentricity Comparison');
save(['data_fit/P' int2str(par) '_fit_params_eccentricity.mat'], 'fit_params');
%% Compare data for each eccentricity
trialOne = trial1 & eccentricity_low;
trialTwo = trial2 & eccentricity_low;
trialThree = trial3 & eccentricity_low;
lineWidth1 = lineWidth(trialOne);
resp1 = resp(trialOne);
lineWidth2 = lineWidth(trialTwo);
resp2 = resp(trialTwo);
lineWidth3 = lineWidth(trialThree);
resp3 = resp(trialThree);
figure
jmpspace = linspace(-6, 6, 10000);
%trial type 1 (static)
[B] = glmfit(lineWidth1, resp1, 'binomial');
fit_params(1,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidth1, resp1, 10, 'bo', 'filled')
hold on

%trial type 2 (jitter)
[B] = glmfit(lineWidth2, resp2, 'binomial');
fit_params(2,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
resp2(resp2 == 1) = 1.05;
resp2(resp2 == 0) = -.05;
scatter(lineWidth2, resp2, 10, 'ro', 'filled')
hold on

%trial type 3 (continuous)
[B] = glmfit(lineWidth3, resp3, 'binomial');
fit_params(3,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'g')
hold on
resp3(resp3 == 1) = 1.1;
resp3(resp3 == 0) = -.1;
scatter(lineWidth3, resp3, 10, 'go', 'filled')
hold on
title('Eccentricity = 2.5');
axis([-8 8 -0.15 1.15])
save(['data_fit/P' int2str(par) '_fit_params_low.mat'], 'fit_params');


trialOne = trial1 & eccentricity_medium;
trialTwo = trial2 & eccentricity_medium;
trialThree = trial3 & eccentricity_medium;
lineWidth1 = lineWidth(trialOne);
resp1 = resp(trialOne);
lineWidth2 = lineWidth(trialTwo);
resp2 = resp(trialTwo);
lineWidth3 = lineWidth(trialThree);
resp3 = resp(trialThree);
figure
jmpspace = linspace(-6, 6, 10000);
%trial type 1 (static)
[B] = glmfit(lineWidth1, resp1, 'binomial');
fit_params(1,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidth1, resp1, 10, 'bo', 'filled')
hold on

%trial type 2 (jitter)
[B] = glmfit(lineWidth2, resp2, 'binomial');
fit_params(2,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
resp2(resp2 == 1) = 1.05;
resp2(resp2 == 0) = -.05;
scatter(lineWidth2, resp2, 10, 'ro', 'filled')
hold on

%trial type 3 (continuous)
[B] = glmfit(lineWidth3, resp3, 'binomial');
fit_params(3,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'g')
hold on
resp3(resp3 == 1) = 1.1;
resp3(resp3 == 0) = -.1;
scatter(lineWidth3, resp3, 10, 'go', 'filled')
hold on
title('Eccentricity = 5');
axis([-8 8 -0.15 1.15])
save(['data_fit/P' int2str(par) '_fit_params_medium.mat'], 'fit_params');

trialOne = trial1 & eccentricity_high;
trialTwo = trial2 & eccentricity_high;
trialThree = trial3 & eccentricity_high;
lineWidth1 = lineWidth(trialOne);
resp1 = resp(trialOne);
lineWidth2 = lineWidth(trialTwo);
resp2 = resp(trialTwo);
lineWidth3 = lineWidth(trialThree);
resp3 = resp(trialThree);
figure
jmpspace = linspace(-6, 6, 10000);
%trial type 1 (static)
[B] = glmfit(lineWidth1, resp1, 'binomial');
fit_params(1,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidth1, resp1, 10, 'bo', 'filled')
hold on

%trial type 2 (jitter)
[B] = glmfit(lineWidth2, resp2, 'binomial');
fit_params(2,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
resp2(resp2 == 1) = 1.05;
resp2(resp2 == 0) = -.05;
scatter(lineWidth2, resp2, 10, 'ro', 'filled')
hold on

%trial type 3 (continuous)
[B] = glmfit(lineWidth3, resp3, 'binomial');
fit_params(3,:) = B;
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'g')
hold on
resp3(resp3 == 1) = 1.1;
resp3(resp3 == 0) = -.1;
scatter(lineWidth3, resp3, 10, 'go', 'filled')
hold on
title('Eccentricity = 7.5');
axis([-8 8 -0.15 1.15])
save(['data_fit/P' int2str(par) '_fit_params_high.mat'], 'fit_params');

