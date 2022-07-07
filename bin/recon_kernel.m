function out = recon_kernel(data_mat, spokes, t_idx, opt)

%   spokes is the number of spokes per frame
%   t_idx is the indices of the spokes used for recon
%   spokes should divide length(t_idx)
%   so that frames = length(t_idx)/spokes

q   =   matfile(data_mat);
fr  =   floor(length(t_idx)/spokes);
t_idx = t_idx(1:spokes*fr);
dd  =   q.dd(:,t_idx,:);
ps  =   q.sens;
nc  =   size(dd,3);

k   =   reshape(q.k(:,t_idx,:),[],fr,2);

E   =   xfm_NUFFT([opt.Nx,opt.Nx,1,fr],ps,[],k);

out =   pogm_LLR(E, E'*(E.w.*reshape(dd,[],fr,nc)), opt.lambda, opt.patch, [E.Nd E.Nt], opt.iters);
out =   reshape(out,160,160,[]);

