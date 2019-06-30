%% Load Data
load ionosphere
X(:,2) = [];
%% Convert labels
y = grp2idx(Y);
y(y == 2) = 0;

%% Create table 
dataset = table(X,y);