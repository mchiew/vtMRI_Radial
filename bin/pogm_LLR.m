function x = pogm_LLR(E, dd, lambda, patch_size, im_size, niter)

%   Mark Chiew  
%   May 2021
%
%   Locally-low-rank constrained reconstruction using POGM
%   (p1306, Taylor et al., 2017)

%   Initialise
    x   =   zeros(im_size);
    y   =   zeros(im_size);
    z   =   zeros(im_size);
    w   =   zeros(im_size);
    
    dd  =   reshape(dd, im_size);

    p   =   patch_size;
    L   =   10;

    a   =   1;  % theta in algorithm
    b   =   1;  % gamma in algorithm

%   Main loop
fprintf(1, '%-5s %-16s\n', 'Iter','Cost');
for iter = 1:niter

    %   y-update
    y0  =   y;
    y   =   x - (1/L)*(E.mtimes2(x)-dd);

    %   a-update (theta)
    a0  =   a;
    if iter < niter
        a = (1+sqrt(4*a^2+1))/2;
    else
        a = (1+sqrt(8*a^2+1))/2;
    end

    %   z-update
    z   =   y + ((a0-1)/a)*(y-y0) + (a0/a)*(y-x) + ((a0-1)/(L*b*a))*(z - x);

    %   b-update (gamma)
    b   =   (2*a0+a-1)/(L*a);

    %   x-update
    [ii,jj,kk]  =   meshgrid(randperm(floor(p(1)/2),1):p(1)/2:im_size(1),randperm(floor(p(2)/2),1):p(2)/2:im_size(2),randperm(floor(p(3)/2),1)-floor(p(3)/2)+1:floor(p(3)/2):im_size(4)-floor(p(3)/2));
    
    
    w = 0*w;
    for idx = 1:length(ii(:))
        q   =   get_patch(z, ii(idx), jj(idx), kk(idx), p);
        [u,s,v]     =   svd(reshape(q,[],size(q,4)),'econ');
        s   =   shrink(s, lambda*b); 
        q   =   reshape(u*s*v', size(q));
        w   =   put_patch(w, q, ii(idx), jj(idx), kk(idx), p);
    end
    x(w ~= 0) = w(w ~= 0);
    
    %   Display iteration summary data
    fprintf(1, '%-5d -\n', iter);
end

end

function q = get_patch(X, i, j, k, p)

    [sx,sy,~,st]    =   size(X);
    q               =   X(i:min(i+p(1)-1,sx),j:min(j+p(2)-1,sy), 1, max(k,1):min(k+p(3)-1,st));
    
    if size(q,4) < p(3)
        q = padarray(q, [p(1)-size(q,1), p(2)-size(q,2), 0, p(3)-size(q,4)], 'replicate', 'post');
    end
end

function X = put_patch(X, q, i, j, k, p)

    [sx,sy,~,st]    =   size(X);
    mask = X(i:min(i+p(1)-1,sx),j:min(j+p(2)-1,sy), 1, max(k,1):min(k+p(3)-1,st)) ~= 0;
    X(i:min(i+p(1)-1,sx),j:min(j+p(2)-1,sy), 1, max(k,1):min(k+p(3)-1,st)) = X(i:min(i+p(1)-1,sx),j:min(j+p(2)-1,sy), 1, max(k,1):min(k+p(3)-1,st)) + q(1:length(i:min(i+p(1)-1,sx)),1:length(j:min(j+p(2)-1,sy)),1,1:length(max(k,1):min(k+p(3)-1,st)));
    X(i:min(i+p(1)-1,sx),j:min(j+p(2)-1,sy), 1, max(k,1):min(k+p(3)-1,st)) = X(i:min(i+p(1)-1,sx),j:min(j+p(2)-1,sy), 1, max(k,1):min(k+p(3)-1,st))./(mask+1);
    
end

function y = shrink(x, thresh)
    y = diag(max(diag(x)-thresh,0));
end
