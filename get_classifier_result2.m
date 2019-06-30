function [Results]=get_classifier_result2(Index_Label_test,predict_label)


%INPUT: Index_Label_test --> true labels; predict_label --> predicted labels
%OUTPUT: Results, data structure containing classifier performances


%Enrico De Santis - 5/12/2018 - Ver. 1.1


% classification results for binary classification

if islogical(predict_label)
predict_label=double(predict_label);    
end
if islogical(Index_Label_test)
Index_Label_test=double(Index_Label_test);    
end
predict_label=predict_label(:);
Index_Label_test=Index_Label_test(:);

[confusionMatrix,order] = confusionmat(Index_Label_test, predict_label);
confusionMatrix=confusionMatrix'; %Alessio Hack %grande!
% figure
% plotConfMat(confusionMatrix);


%##################### || TP, FN, FP, TN || ######################

% TRUE POSITIVES
TP = confusionMatrix(1,1);

% FALSE NEGATIVES
FN=confusionMatrix(2,1);

% FALSE POSITIVES
FP=confusionMatrix(1,2);

% TRUE NEGATIVES    
TN=confusionMatrix(2,2);

% Sensitivity, hit rate, recall, or true positive rate (TP/(TP+FN))
if TP+FN ~=0
    recall = (TP/(TP+FN));
else
    recall=0;
end

% Precision or positive predictive value (TP/(TP+FP))
if TP+FP ~=0
    precision = (TP/(TP+FP));
else
    precision=0;
end

% Specificity or true negative rate (TN/(TN+FP))
if TN+FP ~=0
    specificity = (TN/(TN+FP));
else
    specificity=0;
end

% Negative predictive value (TN/(TN+FN))
if TN+FN ~=0
    NPV = (TN/(TN+FN));
else
    NPV=0;
end
% Fall out or false positive rate (FP/(FP+TN))
if FP+TN ~=0
    FPR = (FP/(FP+TN));
else
    FPR=0;
end

% False negative rate (FN/(TP+FN))
if TP+FN ~=0
    FNR = (FN/(TP+FN));
else
    FNR=0;
end

% False discovery rate (FP/(TP+FP))
if TP+FP ~=0
    FDR = (FP/(TP+FP));
else
    FDR=0;
end
% False omission rate (FN/(TN+FN))
if TN+FN ~=0
    FOR = (FN/(TN+FN));
else
    FOR=0;
end
% F1 Score
if (precision+recall) ~= 0
    F1_Score = (2*precision*recall)/((precision+recall));
else
    F1_Score=0;
end

% Accuracy
acc=(TP+TN)/(TP+TN+FP+FN);


Results.TP=TP;
Results.FN=FN;
Results.FP=FP;
Results.TN=TN;
Results.Accuracy=acc;
Results.recall=recall;
Results.precision=precision;
Results.specificity=specificity;
Results.NPV=NPV;
Results.FPR=FPR;
Results.FNR=FNR;
Results.FDR=FDR;
Results.FOR=FOR;
Results.F1_Score=F1_Score;
Results.confmat=confusionMatrix;


% % % Overall accuracy ((TP+TN)/(TP+FP+FN+TN))
% %  Acc = [round((TP[i] + sum(TN[i]))/float(TP[i]+sum(FP[i])+sum(FN[i])+sum(TN[i])),2) for i in range(len(confusionMatrix))]
% % 
% % % Accuracy
% % accuracy = sum(confusionMatrix[i][i] for i in range(len(confusionMatrix)))/float(sum([sum(row) for row in confusionMatrix]))
% 
% % fprintf ('\n')
% % fprintf('Accuratezza Complessiva Classificatore: %01.3f \n' accuracy)
% fprintf ('\n')
% % fprintf('------------------------------------------')
% % fprintf('Accuratezza:   ',"".join("%01.2f  " % x for x in Acc), "|"
% fprintf ('------------------------------------------\n')
% fprintf('TP: %4d \n' ,TP)
% fprintf ('------------------------------------------\n')
% fprintf('FN: %4d \n' ,FN)
% fprintf ('------------------------------------------\n')
% fprintf('FP: %4d \n' ,FP)
% fprintf ('------------------------------------------\n')
% fprintf('TN: %4d \n' ,TN)
% fprintf ('------------------------------------------\n')
% fprintf('Sensitivity, hit rate, recall, or true positive rate (TP/(TP+FN): %d \n', recall)
% fprintf ('------------------------------------------\n')
% fprintf('Precision or positive predictive value (TP/(TP+FP):  %d \n',  precision)
% fprintf ('------------------------------------------\n')
% fprintf('Specificity or true negative rate (TN/(TN+FP)): %d\n', specificity)
% fprintf ('------------------------------------------\n')
% fprintf('NPV - Negative predictive value (TN/(TN+FN)):  %d \n', NPV)
% fprintf ('------------------------------------------\n')
% fprintf('FPR - Fall out or false positive rate (FP/(FP+TN)): %d \n', FPR)
% fprintf ('------------------------------------------\n')
% fprintf('FNR - False negative rate (FN/(TP+FN)):  %d\n', FNR)
% fprintf ('------------------------------------------\n')
% fprintf('FDR - False discovery rate (FP/(TP+FP)): %d \n', FDR)
% fprintf ('------------------------------------------\n ')
% fprintf('FOR - False omission rate (FN/(TN+FN)): %d \n', FOR)
% fprintf ('------------------------------------------\n')
% fprintf('F1_Score - F1_Score = (2*precision*recall)/(precision+recall): %d \n', F1_Score)
% fprintf ('------------------------------------------\n')
% fprintf('Accuracy - Acc = (TP+TN)/(TP+TN+FP+FN): %d \n', acc)
% fprintf ('------------------------------------------\n')
% fprintf ('\n')
% fprintf ('\n')