function [testing] = SR_init_load(par)
    testing = [];
    count = 1;
    try
        while count > 0
            testing1 = dlmread_empty(['TestData/' par '_testing' int2str(count) '.txt'], '\t', 1, 0, NaN);
            testing = [testing;testing1];
            count = count + 1;
        end
    catch e
    end
    names = {'Trial', 'Side', 'LineWidth', 'TrialType', 'minDeg', 'maxDeg', 'startTheta', 'endTheta', 'Response', 'RT', 'Eccentricity', 'dTheta'};
    testing = array2table(testing);
    testing.Properties.VariableNames = names;

    testing.Response(testing.Response > 6) = NaN;
    testing.Response(testing.Response == 5) = NaN;
    testing.Response(testing.Response < 4) = NaN;

    save(['data/' par '_testing_table.mat'], 'testing')

end
