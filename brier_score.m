function bs = brier_score(prob,class)

N_prob = length(prob);
N_class = length(class);

if N_prob~=N_class
    disp('errore: N_prob e N_class diversi')
end

bs = (1/N_prob)*sum((class - prob).^2);

end
