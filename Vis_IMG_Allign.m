% Description : This  Script extracts visible images from a file folder 
% 				and alligns images to the POV of an infrared camera nearby	
%				using a simple matrix transform such that objects are alligned
%---------------------------------------------------------------------%
close all; clear; clc; tictime = tic;
%---------------------------------------------------------------------%
%% User Input: Source & Destination directory locations
% Source location: raw un registered frame files
unRegfrmfldr = 'F:\Fire_Data_Target_DirectoryUCLWIR\';
% Target location: raw frames will be stored here
Regfrmfldr =
'F:\Fire_Data_Target_DirectoryUCLWIR_SpacialAllignment_test';
%% Initialize
band = 'UCLWIR';
nIRcols = 640;
nIRrows = 480;
nVISrows = 873;
nVIScols = 1068;
frmnum = 0;
vidlabels = { 'charcoal1'
 'oats1'
 };
%% Generate Transformation coefficients
VIS_x = [464 542 573 608 662 728 130 215 914 849 63 418 700 253 14 1030
863 541 609 331 ]-2';
VIS_y = [577 573 571 566 291 639 625 157 146 751 721 846 801 433 805
646 565 436 685 328 ]-27';
n = length(VIS_x);
% the length of all the correlation lists
A = ones ([n 3]);
A(:,1) = VIS_x;
A(:,2) = VIS_y;
cIR_x = [299 330 343 357 381 408 158 195 486 458 131 280 397 210 112
532 461 326 358 243 ]'; % 578
cIR_y = [361 357 356 354 239 388 379 180 178 437 419 476 459 296 457
392 349 298 406 253 ]'; % 424
abc_IR = A\cIR_x;
def_IR = A\cIR_y;
%% Transform frames
% create a reference grid where integer intersections represent the
% locations of pixels (pixel centers?) in the visible frame
[visible_x visible_y] = meshgrid (1:nVIScols, 1:nVISrows);
52
visible_x = visible_x(:);
visible_y = visible_y(:);
% create IR grids to sample from
[ir_x ir_y] = meshgrid (1:nIRcols, 1:nIRrows);
% create grids that will store the locations in the IR frames where
pixels
% in the visible image lie. start with an empty array, that is the size
% of the visible image, and then fill it up pixel-by-pixel, using the
% [a b c] and [d e f] transformations calculated above
% each point (visible_x, visible_y) in the visible image corresponds to
% a location in an IR image, here called (resmpl_IR_x, resmpl_IR_y).
% The re-sample locations in each of the IR frames can be found using
the
% [a b c] and [d e f] transformations
resmpl_IR_xy = ([abc_IR';def_IR']*[visible_x visible_y
ones(nVISrows*nVIScols,1)]')';
resmpl_IR_x = reshape(resmpl_IR_xy(:,1),nVISrows,nVIScols);
resmpl_IR_y = reshape(resmpl_IR_xy(:,2),nVISrows,nVIScols);
for i=1:length(vidlabels)
 disp(['Aligning Frames from : ' vidlabels{i} ' test']);

 % Update file names & locations
 testname = vidlabels{i};
 unRegPath = [unRegfrmfldr testname '\']; % made change here
 prefix = [band '_' testname '_'];
 frmnum = numel(dir([unRegPath '*.raw']));
 savefldr = [Regfrmfldr '\' band '\' testname '\'];
 mkdir(savefldr)

 % make folder for each video (or test)
 % Align each frame within test video
 %h = waitbar(0,['Aligning frame FOVs for uclwir ' testname '
test']);
 for k = 1:frmnum
 fid = fopen([unRegPath prefix num2str(k) '.raw'],'r');
%source file
 unRegfrm = uint16(fread(fid,[nIRcols, nIRrows],'uint16'))';
 fclose(fid);

 % resample the IR images on the new grids.
 Regfrm = uint16 (interp2 (ir_x, ir_y, double (unRegfrm),
resmpl_IR_x, resmpl_IR_y, 'bicubic'));

 % save new registered frame
 fid = fopen([savefldr prefix num2str(k) '_fov.raw'],'w')
%end file
 fwrite(fid,Regfrm(:,:)','uint16');
 fclose(fid)
 disp(['Frames Registered : ' num2str(k)]);
 end
end
%% End of Function ---------------------------------------------------%
53
function img_agc = agc (img, n_rows, n_cols)
 % perform Plateau AGC on unsigned 14-bit image
 max_bit = 2^14;
 hist_bins = zeros (max_bit, 1);
 img_agc = uint8 (zeros (n_rows, n_cols));

 % set up the histogram bins, one for each 16-bit grayscale level
 for i_bin = 1:max_bit
 hist_bins(i_bin) = i_bin - 1;
 end
 % matlab calculates the image histogram
 img_hist = histc (img(:), hist_bins);

 % for Plateau Equalization, clip the bins to some plateau level
 img_hist(img_hist > 150) = 150;

 % calculate the cumulative frequency histogram from the clipped
 % histogram
 cum_hist = cumsum (img_hist);

 % scale the cumulative frequency histogram to 8-bit grayscale
 cum_hist = uint8 (255 * cum_hist / cum_hist(max_bit));
 % use the scaled cumulative frequency histogram as an intensity
 % transform table to map the original 16-bit data to 8-bit level
 for i_row = 1:n_rows
 for j_col = 1:n_cols
 img_agc(i_row,j_col) = cum_hist(img(i_row,j_col) + 1);
 end
 end

return