%   rtSpeech Data Recon Example Script
%   Mark Chiew
%   mark.chiew@ndcn.ox.ac.uk


%   Setup path
addpath('bin');
addpath('bin/irt');
irtdir = strcat(pwd, '/bin/irt');
setup_irt;
    
%   If raw data has not been "prepared", prepare it
%   This only needs to be done once ever for each dat file
%
%   prep_dat('INPUT.dat', 'OUTPUT_NAME', [Nc], [shift])
%
%   This takes 2 mandatory and 2 optional parameters:
%
%       'INPUT.dat'     is the raw data filename
%       'OUTPUT_NAME'   is the name of the prepared mat-file
%       [Nc]            is optional, the number of output coils to use
%                       the bigger this is, the more accurate the recon
%                       but slower and more memory intensive
%                       If you leave it out it uses the maximum number
%                       of coils by default
%                       I recommend a value somewhere between Nc = 8 and 16
%       [shift]         is the amount to shift the image to better centre
%                       the head. 
%                       Defaults to [-10, -40] to shift the head up 40 pixels
%                       and to the left 10 pixels. Modify if necessary
%       

twix_data = 'TWIX_FILENAME.dat';
coil_compression = 12;
prep_dat(twix_data, 'test', coil_compression, [-10, -30]);

%   Setup and run reconstruction
%   
%   recon_kernel('MATFILE_NAME', spokes, index, opts) 
%
%   This takes 4 mandatory parameters:
%
%       'MATFILE_NAME'  is the name of the prepared mat-file
%                       this should be the same as 'OUTPUT_NAME' from above
%       spokes          is the number of spokes/shots/TRs to combine into 
%                       a single image. Each shot is acquired with a TR=2.5 ms
%                       so using 12 spokes for example, gives 1 image every
%                       30 ms, resulting in 1/.03 = 33.33 FPS
%                       More spokes means better images, but lower FPS
%                       Recommend 12 spokes, definitely no lower than 8 (50 FPS)
%       index           dictates the total number of spokes to use
%                       index = 1:12000 for example, uses the first 12000 shots,
%                       which when spokes = 12, means a total of 1000 frames over
%                       a duration of 30s.
%                       index = 2001:14000, also uses 12000 shots over 30s, but starts
%                       5s in, so the images span 5-35s in the dataset
%                       The total number of spokes available is stored as the variable
%                       'nt' in the MATFILE_NAME object
%                       The reconstruction parameters can depend on the number of frames
%                       in the data, so some care has to be taken when choosing this
%                       Pre-determined parameters have been chosen for spokes=12, and
%                       an index length of 12000
%       opts            is a struct() that has fields corresponding to reconstruction options
%                       These options are:
%       opts.lambda     lambda weighting for LLR reconstruction
%       opts.patch      patch size for LLR reconstruction
%       opts.iters      applies to both, denotes the number of iterations to perform
%       opts.Nx         output image matrix size

opts.lambda = 1E-6;
opts.patch  = [7 7 50];
opts.iters  = 100;
opts.Nx     = 160;

%   Run recon
spokes_per_frame = 12;
out = recon_kernel('test', spokes_per_frame, 2001:3000, opts);
    
%   Generate movie
%
%   gen_movie('MOV_NAME', data, FPS, scale, ['mov_type'])
%
%   This takes 4 mandatory and 1 optional parameter
%   
%       'MOV_NAME'      is the filename for the output movie
%       data            is the [Nx, Ny, Nt] dataset returned by recon_kernel
%                       any cropping of the images can be done here
%                       By default, data is [160,160,Nt] so to crop to 128x128xNt
%                       you would input data(17:144,17:144,:) for a centred crop
%       FPS             is the frames-per-second for the movie
%                       this should be 1/(0.0025*spokes)
%       scale           is the scaling of the display of the data (0-100)
%                       this  dictates the magnitude of signal that will appear
%                       white on the video, as well as any signal values higher
%                       it is defined as a percentile, so that a parameter
%                       of e.g. 99 means that all signals above the 99th
%                       percentile of voxel magnitudes will be pure white
%       mov_type        is a string dictating the type of movie to output
%                       options, taken from the help for the MATLAB builtin VideoWriter
%                       
%           'Grayscale AVI'    - Uncompressed AVI file with Grayscale video.
%                                (default)
%           'Archival'         - Motion JPEG 2000 file with lossless compression
%           'Motion JPEG AVI'  - Compressed AVI file using Motion JPEG codec.
%           'Motion JPEG 2000' - Compressed Motion JPEG 2000 file
%           'MPEG-4'           - Compressed MPEG-4 file with H.264 encoding
%                                (Windows 7 and Mac OS X 10.7 only)
%           'Uncompressed AVI' - Uncompressed AVI file with RGB24 video.
%           'Indexed AVI'      - Uncompressed AVI file with Indexed video.
%                       
    
gen_movie('test_movie', out(17:144,17:144,:), 1/(0.0025*spokes_per_frame), 99, 'MPEG-4');
