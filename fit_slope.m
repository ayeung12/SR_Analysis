function [m_fit] = fit_slope(subjects)

m_fit = [];
m_fit_func = @(B, x) B(2).*exp(-(B(1) + B(2).*x)) ./ (1 + exp(-(B(1) + B(2).*x))).^2;

for i = 1:length(subjects)
    sub = subjects(i);
    fit_params = load(['data_fit/P' int2str(sub) '_fit_params.mat']);
    fit_params = fit_params.fit_params;
    
    m_fit(i, :) = [ m_fit_func(fit_params(1,:), 0), ...
                    m_fit_func(fit_params(2,:), 0), ...
                    m_fit_func(fit_params(3,:), 0)];
    
end



end