# Matlab GMM - Classifier

This repository contains Matlab files that implements a binary classifier based on a Gaussian Mixture Model.
Three type of classifier are implemented:

1) GMM_Classifier_k_components
2) GMM_Classifier_two_components
3) GMM_Classifier_separate_training_set

GMM model is trained by using EM algorithm.
For this kind of classifier, dataset is divided in three disjoint sets:
- training set, for  training;
- validation set, for selection of best parameters;
- test set,  for the final test with best model;

Two datasets are provided for testing classifier:
- Ionosphere
- Breast - Cancer - Wisconsin

1. GMM Classifier k components

The parameter k represent the number of gaussian components of the mixture model. 
First of all a k-range is set (e.g. k=1:15), then for each k value the GMM is trained using training set data. After training, we obtained a GMM, and training set data are clusterized based on that model, that is each training pattern is assigned to a gaussian components, specifically to the gaussian component for which it has the maximum posterior probability. Each cluster is labeled according to the majority of class pattern (e.g. if cluster A contains 10 class 1 patterns and 8 class 0 patterns, it is labeled as class 1).
This process is repeted for each k value, so after training session we have k GMMs and we clusterized training set pattern k times.
Given a test pattern, classification is performed by assigning it to the gaussian component for which it has the maximum posterior probability, and consequently labeling it with the class associated to that gaussian component.
So after training session, validation set pattern are classified for each GMM obtained, and we choose the GMM that maximizes accuracy.
Finally this model is used to classify test set patterns.


2. GMM_Classifier_two_components

The value of k parameter is set to 2, that is GMM model will be composed only by two gaussian components. The idea is that first component will describe positive class and second components negative class. In order to obtain this achievement, initial values of guassian components parameters (covariance matrix and mean) are set according the distribution of training set pattern (e.g. for first components the initial mean value will be the mean between training set pattern of class 1).

For this classifier we consider four GMMs based on covariance matrix constraints:
 1) Shared Covariance - Diagonal (Covariance matrix is the same for the two guassian components and it must be diagonal)
 2) Unshared Covariance - Diagonal (Covariance matrix is not the same for the two guassian components and it must be diagonal)
 3) Shared Covariance - Full (Covariance matrix is the same for the two guassian components and it must be full)
 4) Unshared Covariance - Full (Covariance matrix is not the same for the two guassian components and it must be full)
 
After training GMMs for each case, a test pattern is classified by assigning it to the gaussian component for which it has the maximum posterior probability, and consequently it is assigned to the class represented by that component.
In order to choose the best combination (Shared/unshared - Diagonal/full), validation set patterns are classified for each GMM. The best model is choosen based on accuracy, and it is used to classify test set patterns.
