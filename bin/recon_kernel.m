function out = recon_kernel(raw_data, spokes, opt)

%   spokes is the number of spokes per frame
%   t_idx is the indices of the spokes used for recon
%   spokes should divide length(t_idx)
%   so that frames = length(t_idx)/spokes

[~,data_mat,~] = fileparts(raw_data);
q   =   matfile(data_mat);

if isempty(opt.range)
    opt.range = 1:q.nt;
end

fr  =   floor(length(opt.range)/spokes);
t_idx = opt.range(1:spokes*fr);
dd  =   q.dd(:,t_idx,:);
ps  =   q.sens;
nc  =   size(dd,3);

if opt.patch(3) > fr
    opt.patch(3) = fr;   
end

opt.lambda = opt.lambda*prctile(abs(dd(:)),99);

k   =   reshape(q.k(:,t_idx,:),[],fr,2);

E   =   xfm_NUFFT([opt.Nx,opt.Nx,1,fr],ps,[],k);

out =   pogm_LLR(E, E'*(E.w.*reshape(dd,[],fr,nc)), opt.lambda, opt.patch, [E.Nd E.Nt], opt.iters);

