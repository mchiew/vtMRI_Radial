function gen_movie(fname, data, fps, scale, mov_type)

if nargin < 5
    mov_type = 'Grayscale AVI';
end

scale   =   prctile(abs(data(:)), scale);
data    =   double(abs(data)/scale);
data(abs(data)>1)   =   1;

for t = 1:size(data, 3)
    switch mov_type
    case 'Grayscale AVI'
        M(t)=im2frame(repmat(data(:,:,t),1,1,3));
        M(t).cdata = rgb2gray(M(t).cdata);
    otherwise
        M(t)=im2frame(repmat(data(:,:,t),1,1,3));
    end
end

v   =   VideoWriter(fname, mov_type);

v.FrameRate =   fps;
open(v);
writeVideo(v, M);
close(v);
