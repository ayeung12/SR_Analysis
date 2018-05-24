function [se_fit] = comp_analysis(testing, subjects)
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

%% Calculate variance among subjects (trial widths of 300)
fit_data = [];
varspace = -6:1:6;
i = 1;
for sub = subjects
    fit_params = load(['data_fit/P' int2str(sub) '_fit_params.mat']);
    fit_params = fit_params.fit_params;

    % Static model fit
    ind = 1; % index for static information
    B = fit_params(ind,:);
    zplot = B(1) + B(2).*varspace;
    yfit = 1./(1+exp(-zplot));
    fit_data(i, :, ind) = yfit;
    
    % Jitter model fit
    ind = 2; % index for jitter information
    B = fit_params(ind,:);
    zplot = B(1) + B(2).*varspace;
    yfit = 1./(1+exp(-zplot));
    fit_data(i, :, ind) = yfit;
    
    % Continuous model fit
    ind = 3; % index for continuous information
    B = fit_params(ind,:);
    zplot = B(1) + B(2).*varspace;
    yfit = 1./(1+exp(-zplot));
    fit_data(i, :, ind) = yfit;
    
    i = i+1;
end

se_fit = std(fit_data)./length(subjects);

%% plot psychometric curves
figure
jmpspace = linspace(-6, 6, 10000);
%trial type 1 (static)
[B] = glmfit(lineWidth1, resp1, 'binomial');
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
p1 = plot(jmpspace, yplot, 'color', 'b');
hold on
p2 = scatter(lineWidth1, resp1, 10, 'bo', 'filled');
ze = B(1) + B(2).*varspace; % error plotting
ye = 1./(1+exp(-ze));
p3 = errorbar(varspace,ye,se_fit(:, :, 1), 'LineStyle','None', 'Color', 'blue');

%trial type 2 (jitter)
[B] = glmfit(lineWidth2, resp2, 'binomial');
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
p4 = plot(jmpspace, yplot, 'color', 'r');
resp2(resp2 == 1) = 1.05;
resp2(resp2 == 0) = -.05;
p5 = scatter(lineWidth2, resp2, 10, 'ro', 'filled');
ze = B(1) + B(2).*varspace; % error plotting
ye = 1./(1+exp(-ze));
p6 = errorbar(varspace,ye,se_fit(:, :, 2), 'LineStyle','None', 'Color', 'red');

%trial type 3 (continuous)
[B] = glmfit(lineWidth3, resp3, 'binomial');
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
p7 = plot(jmpspace, yplot, 'color', 'g');
resp3(resp3 == 1) = 1.1;
resp3(resp3 == 0) = -.1;
p8 = scatter(lineWidth3, resp3, 10, 'go', 'filled');
ze = B(1) + B(2).*varspace; % error plotting
ye = 1./(1+exp(-ze));
p9 = errorbar(varspace,ye,se_fit(:, :, 3), 'LineStyle','None', 'Color', 'green');

axis([-8 8 -0.15 1.15])
legend([p1 p2 p4 p5 p7 p8], 'static', '', 'jitter', '', 'continuous', '', 'Location', 'east');
xlabel('Gap Width (pixels)')
ylabel('Portion "Right" Responses');

%% Plot Fast vs Slow Motion
figure
%continuous_slow
[B] = glmfit(lineWidthSlow, respSlow, 'binomial');
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidthSlow, respSlow, 10, 'bo', 'filled')
hold on

%continuous_fast
[B] = glmfit(lineWidthFast, respFast, 'binomial');
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
respFast(respFast == 1) = 1.05;
respFast(respFast == 0) = -.05;
scatter(lineWidthFast, respFast, 10, 'ro', 'filled')
hold on
axis([-8 8 -0.15 1.15])
title('Continuous Motion Speed Comparison');

figure
%jitter_half
[B] = glmfit(lineWidthHalf, respHalf, 'binomial');
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'b')
hold on
scatter(lineWidthHalf, respHalf, 10, 'bo', 'filled')
hold on

%jitter_full
[B] = glmfit(lineWidthFull, respFull, 'binomial');
zplot = B(1) + B(2).*jmpspace;
yplot = 1./(1+exp(-zplot));
plot(jmpspace, yplot, 'color', 'r')
hold on
respFull(respFull == 1) = 1.1;
respFull(respFull == 0) = -.1;
scatter(lineWidthFull, respFull, 10, 'ro', 'filled')
hold on
axis([-8 8 -0.15 1.15])
title('Jitter Speed Comparison');

%% Compare Different Eccentricities
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

%% signal detection theory 

% [trial1c, trial1dp] = signalDetection(isRight(trial1), resp(trial1));
% [trial2c, trial2dp] = signalDetection(isRight(trial2), resp(trial2));
% [trial3c, trial3dp] = signalDetection(isRight(trial3), resp(trial3));

end


