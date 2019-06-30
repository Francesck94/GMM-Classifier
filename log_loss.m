%% log loss
% -(y*log(p) + (1-y)*log(1-p))

% tab = table(train_set.class,set.prob);
% tab = sortrows(tab,2);
% tab.Properties.VariableNames = {'class','score'};


function loss_tot = log_loss(class,score)

    eps = 1e-15;
    N = length(score); 
    score(score == 0) = eps;
    score(score == 1) = 1 - eps;
   
    %%
    for i = 1:length(score)
        if class(i) == 1
            l_loss(i) = -log(score(i));
        else 
            l_loss(i) = -log(1-score(i));
        end
    end
    
    %%
    loss_tot = sum(l_loss)/N;