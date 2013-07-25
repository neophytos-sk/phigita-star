function [Priors,Mu,Sigma] = readGmmFile(filename)

fid = fopen(filename);
w = fscanf(fid,'%d',2);
dims = w(1);
nState = w(2);
Priors = fscanf(fid,'%f',nState);
Mu = fscanf(fid,'%f',[dims nState]);
for i=1:nState
  Sigma(:,:,i) = fscanf(fid,'%f',[dims dims]);
end
fclose(fid);