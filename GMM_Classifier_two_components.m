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

%% Valori iniziali da passare alla funzione fitgmidst

%Il vettore y contiene le label dei pattern del training set
y = ones(length(train_set.class),1);

%In corrispondenza di pattern di classe 0, i valori di y sono pari a 2
y(train_set.class == 0) = 2;

options = statset('MaxIter',600);

%% Vari tipi di matrice di covarianza
Sigma = {'diagonal','diagonal','full','full'};

SharedCovariance = {true,false,true,false};
SCText = {'true','false','true','false'};
%% Training di 4 tipi di GMM in base al tipo di matrice di covarianza e alla sua condivisione fra le componenti

rng('default')
for i=1:4

    gmmodel{i} = fitgmdist(train_set.X,2,'Start',y,'CovarianceType',Sigma{i},...
        'SharedCovariance',SharedCovariance{i},'RegularizationValue',0.1,'Options',options);
end


%% Accuracy di ogni GMM sul validation set 
val_class = val_set.class;
val_class(val_class == 0) = 2;
for i=1:4
    cluster_val{i} = cluster(gmmodel{i},val_set.X);
    acc_val(i) = nnz(cluster_val{i} == val_class)/length(val_set.class);
end


%% Selezione del GMM con la miglior accuracy

[accuracy_val,best_idx] = max(acc_val);
accuracy_val
best_gmm = gmmodel{best_idx};


%% Predizione label val set

pred = cluster_val{best_idx};
pred(pred == 2) = 0; % i pattern associati alla seconda componente sono considerati come di classe 0
val_pred = pred;

%% Posterior Probability per il val set
P_val = posterior(best_gmm,val_set.X);

p_validation = P_val(:,1);

%% Add probability and prediction to val_set table
val_set.pred = val_pred;
val_set.prob = p_validation;

%% ROC curve val
[X_v,Y_v,~,AUC_v] = perfcurve(logical(val_set.class),val_set.prob,true);

%% Test set cluster, predizioni e posterior probabity
[idx_t,~,P_test] = cluster(best_gmm,test_set.X);

pred_t = idx_t;
pred_t(idx_t==2) = 0;
test_pred = pred_t;
test_set.prob = P_test(:,1);
test_set.pred = test_pred;
%% Test Set result

test_result = get_classifier_result2(test_set.class,test_set.pred);
Accuracy_test = test_result.Accuracy;

%% ROC curve
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