% Author = Francesco Arnò
% mail = francesco.arno94@gmail.com


%%
clc
clear all
close all


%% Select data
addpath('./dataset')
data_type = 'breast_cancer'
% data_type = 'ionosphere'

switch data_type
    case 'breast_cancer'
        load_data_breast_cancer
    case 'ionosphere'
        load_data_ionosphere
    otherwise
        disp('data uncorrect')
        return
end
    
%% Split dataset
pt = cvpartition(dataset.y,'Holdout',0.40);
idx_tr = training(pt);

train_set = dataset(idx_tr,:);

idx_val_set = test(pt);
val_test = dataset(idx_val_set,:);

pt2 = cvpartition(val_test.y,'Holdout',0.50);
idx_val = training(pt2);
idx_test = test(pt2);

val_set = val_test(idx_val,:);
test_set = val_test(idx_test,:);
%% Change label name 

train_set.Properties.VariableNames{2} = 'class';
val_set.Properties.VariableNames{2} = 'class';
test_set.Properties.VariableNames{2} = 'class';

%% Dimensione
n_dim = size(train_set.X);

%% Set k
kmin = 1;
kmax = 15;

% k = kmin:kstep:kmax;
%% Training Set 1 e Training Set 0
train_set0 = train_set(find(train_set.class == 0),:);
train_set1 = train_set(find(train_set.class == 1),:);

%% Training dei GMMs 

GMModels_1 = cell(1,kmax);
GMModels_0 = cell(1,kmax);
 options = statset('MaxIter',1000);

for k = kmin:kmax
    rng('default')
    GMModels_1{k} = fitgmdist(train_set1.X,k,'RegularizationValue',0.1,'Options',options,'SharedCovariance',true);
    GMModels_0{k} = fitgmdist(train_set0.X,k,'RegularizationValue',0.1,'Options',options,'SharedCovariance',true);

end


%% Clustering validation set per training set 0
for k = kmin:kmax
    idx0{k} = cluster(GMModels_0{k},val_set.X);
end

%% Clustering validation set per training set 1
for k=kmin:kmax
    idx1{k} = cluster(GMModels_1{k},val_set.X);
end

%% Probabilità a posteriori pattern validation set per GMM0 e GMM1
for k=kmin:kmax
    P0_val_tot{k} = posterior(GMModels_0{k},val_set.X);
    P1_val_tot{k} = posterior(GMModels_1{k},val_set.X);

end

% Per ciascun pattern si seleziona la probabilità a posteriori maggiore in
% riferimento al GMM0 e al GMM1
for k=kmin:kmax
    P0_val{k} = max(P0_val_tot{k},[],2);
    P1_val{k} = max(P1_val_tot{k},[],2);
end

%% Predizione label basata su probabilità a posteriori 
len_val = length(val_set.class);
for k = kmin:kmax
    
    pos_val = P1_val{k} >= P0_val{k};
    pred_val{k} = zeros(len_val,1);
    pred_val{k}(pos_val) = 1;
    
    %per ogni k si calcola l'Accuracy sul validation set
    acc_val(k) = (nnz(val_set.class == pred_val{k}))/len_val;
end

%% Best GMM0 e GMM1 
[best_acc_val,best_idx] = max(acc_val,[],2);

BestModel_1 = GMModels_1{best_idx};
BestModel_0 = GMModels_0{best_idx};

%% Predizioni validation set
val_set.pred = pred_val{best_idx};

%% Posterior probability validation set
pos_val = P1_val{best_idx} >= P0_val{best_idx};

val_prob = zeros(len_val,1);
val_prob(pos_val) = P1_val{best_idx}(pos_val);
val_prob(~pos_val) = 1 - P0_val{best_idx}(~pos_val);

val_set.prob = val_prob;


%% ROC curve val
[X_v,Y_v,~,AUC_v] = perfcurve(logical(val_set.class),val_set.prob,true);

%% Assegnazione pattern test set ai cluster dei due GMM
 
[idx3,~,P0_test] = cluster(BestModel_0,test_set.X);
[idx4,~,P1_test] = cluster(BestModel_1,test_set.X);

%% Posterior probability test set
P0_test = max(P0_test,[],2);
P1_test = max(P1_test,[],2);

% Indici dei pattern che hanno maggiore probabilità di appartenere ad un
% cluster del GMM_1 piuttosto che ad un cluster del GMM_0
pos_test = P1_test >= P0_test;

%% Predizioni classi per il test set

%il vettore delle label predette è dapprima costruito come un vettore di 0,
%che vengono sostituiti da 1 in corrispondenza degli indici indicati da
%pos_test
test_set.pred = zeros(length(P1_test),1);
test_set.pred(pos_test) = 1;         
%% Posterior probability per il test set

test_prob = zeros(length(P1_test),1);
test_prob(pos_test) = P1_test(pos_test);
test_prob(~pos_test) = 1 - P0_test(~pos_test);
test_set.prob = test_prob;

%% Test Set result


test_result = get_classifier_result2(test_set.class,test_set.pred);
Accuracy_test = test_result.Accuracy;

%% ROC curve

[X,Y,~,AUC] = perfcurve(logical(test_set.class),test_set.prob,true)
figure
plot(X,Y)
xlabel('False positive rate')
ylabel('True positive rate')
title(['ROC curve Test set ',data_type])

%% Brier score 

Bs_test = brier_score(test_set.prob,test_set.class);

%% Log - Loss score
Log_loss_test = log_loss(test_set.class,test_set.prob);

%% Add Brier score and Log - Loss score to test_result

test_result.Brier_score = Bs_test;
test_result.Log_Loss = Log_loss_test;

%% Print result
fprintf('Validation Set Accuracy: %1.4f',Accuracy_val_best);
fprintf('Test Set Accuracy: %1.4f',test_accuracy);