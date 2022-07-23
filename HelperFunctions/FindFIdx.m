function [FIdx1, FIdx2] = FindFIdx(Input, fs)

BW=fs/2;
n_f_steps = length(Input);
f_step = (n_f_steps-1)/BW;
f=[];f(1) = 0; 
for ff=2:n_f_steps
    f(ff) = f(ff-1)+(1/f_step);
end
% Find relevant frequency indices
% Delta band
FIdx1 = find(f<10); FIdx2 = find(f>0);
end