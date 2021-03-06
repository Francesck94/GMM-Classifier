% Author = Francesco Arṇ
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
%% Training GMMs

GMModels = cell(1,kmax);

options = statset('MaxIter',500);
%  rng('default')
for k = kmin:kmax
     rng('default')
    GMModels{k} = fitgmdist(train_set.X,k,'Options',options,'SharedCovariance',true);
    
end

%% Indici dei cluster del GMM per il training_set
for k = kmin:kmax
    idx_train{k} = cluster(GMModels{k},train_set.X);
end
%% Associazione cluster - classe 

% Ad ogni cluster viene associata una classe in base frequenza
for k = kmin:kmax
    numComponents = k;
    for i=1:numComponents
        pos = nnz(train_set.class(idx_train{k} == i) == 1);
        neg = nnz(train_set.class(idx_train{k} == i) == 0);
    
        if pos >= neg
            cluster_class{k}(i) = 1;
        else
            cluster_class{k}(i) = 0;
        end
        clear pos neg
    end
end


%% Clustering e predizione label pattern del validation set
val_len = length(val_set.class);

for k = kmin:kmax
    gmm = GMModels{k};
    [cluster_val{k},~,prob_validation{k}] = cluster(gmm,val_set.X);
end

for k = kmin:kmax
    for i = 1:val_len
        idx_cluster = cluster_val{k}(i);
        pred_val{k}(i) = cluster_class{k}(idx_cluster);
    end
end

%% Accuracy on validation set for each k
 
for k = kmin:kmax
    acc_val(k) = (nnz(pred_val{k}' == val_set.class))/val_len;
end

[Accuracy_val_best,best_idx] = max(acc_val);

%% Best Accuracy val set
Accuracy_val = Accuracy_val_best;

%% Validation set prediction with best gmm

pred_val_best = pred_val{best_idx};


%% Posterior probability validation set
best_gmm = GMModels{best_idx};

% Probabilità a posteriori
P_val = posterior(best_gmm,val_set.X);

%Probabilità a posteriori di guasto
P_val_corr = max(P_val,[],2);

% Per pattern etichettati come '0' la probabilità è ottenuta dal
% complemento della probabilità a posteriori di appartenere al cluster

P_val_corr(find(pred_val_best==0)) = 1 - P_val_corr(find(pred_val_best==0));


%% Inserimento campi validation set
val_set.pred = pred_val_best';
val_set.prob = P_val_corr;

%% ROC curve val
[X_v,Y_v,~,AUC_v] = perfcurve(logical(val_set.class),val_set.prob,true);

%% Assegnazione pattern del test set ai cluster e probabilità a posteriori

[idx_test,~,P_test] = cluster(best_gmm,test_set.X);

%% Predizione label dei pattern del test set
for i=1:length(test_set.class)
    pred_t(i) = cluster_class{best_idx}(idx_test(i));
end
test_set.pred = pred_t';
%% Test set result

test_result = get_classifier_result2(test_set.class,test_set.pred);
%test_result contiene varie figure di merito tra cui l'Accuracy

test_accuracy = test_result.Accuracy;
%% Posterior probability test set

P_test_corr = max(P_test,[],2);

%Calcolo probabilità per pattern etichettati come '0'
P_test_corr(find(pred_t==0)) = 1 - P_test_corr(find(pred_t==0));
 
test_set.prob = P_test_corr;
 
%% Roc curve
[X,Y,~,AUC] = perfcurve(logical(test_set.class),test_set.prob,true);
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