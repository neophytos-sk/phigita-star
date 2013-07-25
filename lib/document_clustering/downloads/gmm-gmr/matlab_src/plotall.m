function plotall
%
% Copyright (c) 2008 Sylvain Calinon, 
% LASA Lab, EPFL, CH-1015 Lausanne, Switzerland, 
% http://www.calinon.ch, http://lasa.epfl.ch


nbSamples=3;

[priors,Mu,Sigma] = readGmmFile('../outdata/gmm.txt');

Data=[];
for n=1:nbSamples
  Datatmp = load(['../outdata/data' num2str(n,'%.2d') '_rescaled.txt'])';
  Data = [Data , Datatmp];
end
nbVar = size(Datatmp,1);
nbData = size(Datatmp,2);

regr = load(['../outdata/gmr_Mu.txt'])';
rgSigma = load(['../outdata/gmr_Sigma.txt'])';
size(regr)
rgSigma = reshape(rgSigma,nbVar-1,nbVar-1,nbData);

%% Plot GMM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axis parameters
minX = min(Data(1,:));
maxX = max(Data(1,:));
dYmax=1E-10;
for i=1:nbVar-1
  dY(i) = max(Data(i+1,:)) - min(Data(i+1,:));
  if dY(i)>dYmax
    dYmax=dY(i);
  end
end
for i=1:nbVar-1
  minY(i) = min(Data(i+1,:))+(dY(i)/2)-1.3*(dYmax/2); 
  maxY(i) = min(Data(i+1,:))+(dY(i)/2)+1.3*(dYmax/2);
end

figure('position',[20,-80,1200,700],'GMM/GMR');
%Plot GMM
for i=1:nbVar-1
  subplot(2,nbVar-1,i); hold on; box on;
  plotGMM(Mu([1 i+1],:),Sigma([1 i+1],[1 i+1],:),[0.3 0.1 0],1);
  for n=1:nbSamples
    plot(Data(1,(n-1)*nbData+1:n*nbData),Data(i+1,(n-1)*nbData+1:n*nbData),'k-');
  end
  axis([minX maxX minY(i) maxY(i)]);
  xlabel('t'); ylabel(['x_' num2str(i)]);
end
%Plot GMR
for i=1:nbVar-1
  subplot(2,nbVar-1,i+nbVar-1); hold on; box on;
  plotGMM(regr([1 i+1],:),rgSigma(i,i,:),[0 0.3 0.1],3);
  axis([minX maxX minY(i) maxY(i)]);
  xlabel('t'); ylabel(['x_' num2str(i)]);
end

pause;
close all;
