function idx = getROIidx(dims, centre, r)

if length(dims)==2
    centre  =   centre(1:2);
    [sx, sy]    =   ndgrid(-r:r,-r:r);
    xy = bsxfun(@plus, centre, [sx(:) sy(:)]);
    xy = bsxfun(@min, max(xy,1), dims); 
    xy = unique(xy,'rows');                     

    test    =   sum((xy-repmat(centre,size(xy,1),1)).^2,2).^0.5;
    roi     =   find(test <= r);

    idx =   sub2ind(dims, xy(roi,1), xy(roi,2));
elseif length(dims) == 3
    [sx, sy, sz]    =   ndgrid(-r:r,-r:r,-r:r);
    xyz = bsxfun(@plus, centre, [sx(:) sy(:) sz(:)]);
    xyz = bsxfun(@min, max(xyz,1), dims); 
    xyz = unique(xyz,'rows');                     

    test    =   sum((xyz-repmat(centre,size(xyz,1),1)).^2,2).^0.5;
    roi     =   find(test <= r);

    idx =   sub2ind(dims, xyz(roi,1), xyz(roi,2), xyz(roi,3));
end
