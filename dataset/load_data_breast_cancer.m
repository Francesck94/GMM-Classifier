%% Breast - Cancer - Wisconsin

dataset = readtable('breast-cancer-wisconsin')

%% delete 1st column (id number)
dataset(:,1) = [];

%% Adjust data type
dataset.Var7 = double(categorical(dataset.Var7));
%% Merge var attributes
dataset = mergevars(dataset,[1:9],'NewVariableName','X')

%% Set label name
dataset.Properties.VariableNames{2} = 'y';

%% Set label 0 and 1
dataset.y(dataset.y == 2) = 0;
dataset.y(dataset.y == 4) = 1;