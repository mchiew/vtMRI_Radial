function prep_dat(raw_data, data_name, compress, shift)

if exist(strcat(data_name,'.mat'), 'file')
    return
end

if nargin < 4
shift = [-10, -40];
end

disp('Reading Data');
map =   mapVBVD(raw_data,'rampSampRegrid',true,'removeOS',false);
map =   map{end};
dd  =   conj(map.image()); %   Flips brains upside down
nr  =   size(dd,1);
nc  =   size(dd,2);
dd  =   reshape(dd, nr, nc, []);

%   Check if data truncated for whatever reason
if map.image.NAcq < map.image.NLin*map.image.NRep
    dd  =   dd(:,:,1:map.image.NLin*(map.image.NRep-1));
end
nt  =   size(dd,3);


if nargin < 3
    compress = nc;
end

disp('Coil Compress');
dd = permute(dd,[1,3,2]);
[u,s,v] = lsvd(reshape(dd,[],nc), compress);
dd = reshape(u*s,nr,[],compress);
nc = compress;
clear u s v;

k   =   gen_radial(0,nr,size(dd,2),1,360,1);
k   =   cat(3,k(:,:,1),-1*k(:,:,2));

inc = (0:size(dd,2)-1)*180/((1+sqrt(5))/2);

p   = exp(-1j*2*pi*linspace(-0.5,0.5,nr)'*(shift(2)*cosd(inc)+shift(1)*sind(inc)));
dd  = bsxfun(@times, p, dd);

disp('Estimate Coil Sensitivities');
E =   xfm_NUFFT([nr,nr,1,1],[],[],reshape(k(round(nr/3)+1:2*round(nr/3),1:nr*5,:),[],1,2),'wi',1);
m   =   zeros(nr*nr,nc);
for c = 1:nc
    m(:,c)  =   E.iter(reshape(bsxfun(@times, hann(round(nr/3)), dd(round(nr/3)+1:2*round(nr/3),1:nr*5,c)),[],1).*E.w, @pcg, 1E-4, 10);
end

m       =   E.fftfn(reshape(m, nr, nr, []),1:2);
m       =   m(nr/2-12+1:nr/2+12,nr/2-12+1:nr/2+12,:);
sens    =   rx_espirit(reshape(m,24,24,1,12),[nr,nr],[5,5]);

disp('Write Data');
%   Crop to 160x160 FOV
N       =   (nr-160)/2;
q       =   matfile(data_name,'Writable',true);
q.dd    =   dd;
q.sens  =   sens(N+1:N+160,N+1:N+160,:,:);
%q.m     =   m(N+1:N+160,N+1:N+160,:,:);
q.k     =   k;
q.nt    =   nt;
