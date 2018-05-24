clear; close all
%% Process Raw Data

 %par0 = 0;   % starting participant not processed
 %parf = 7;   % final participant
 
 for par = 8:9
     SR_init_load(['P' int2str(par)]);
 end

%% Concatenate data for all test subjects
% TODO: dont have a fixed end particpant (determine it from the file names)
par0 = 0;
parf = 7;
subs = par0:parf;


total_testing = [];
for par = 8:9
    load(['data/P' int2str(par) '_testing_table.mat'])
    total_testing = [total_testing; testing];
end

testing = total_testing;
save('data/total_testing_table.mat', 'testing')
%% Analysis per subject
par0 = 0;

for par = 8:9
    load(['data/P' int2str(par) '_testing_table.mat'])
    init_analysis;
end

%% Analysis total
load('data/total_testing_table.mat', 'testing')

% Standard Error of the Mean fit
se_fit = comp_analysis(testing, subs);

% slopes
m_fits = fit_slope(subs);

%% Saving fit data to excel 
widths = -8:0.1:8;
i = 1;
fit_data = [];

sub = 8;
par0 = 0;
parf = 7;
subs = par0:parf;
try
while sub > -1
    fit_params = load(['data_fit/P' int2str(sub) '_fit_params.mat']);
    fit_params = fit_params.fit_params;
    
    % Static model fit
    ind = 1; % index for static information
    B = fit_params(ind,:);
    zplot = B(1) + B(2).*widths;
    yfit = 1./(1+exp(-zplot));
    fit_data(:, i, ind) = yfit;
    
    % Jitter model fit
    ind = 2; % index for static information
    B = fit_params(ind,:);
    zplot = B(1) + B(2).*widths;
    yfit = 1./(1+exp(-zplot));
    fit_data(:, i, ind) = yfit;
    
    % Continuous model fit
    ind = 3; % index for static information
    B = fit_params(ind,:);
    zplot = B(1) + B(2).*widths;
    yfit = 1./(1+exp(-zplot));
    fit_data(:, i, ind) = yfit;
    
    i = i+1;
    sub = sub + 1;
end
catch e
end

data_write = reshape(fit_data, size(fit_data,1), size(fit_data,2)*size(fit_data,3));
xlswrite('fitted_data.xlsx', [widths', data_write]);