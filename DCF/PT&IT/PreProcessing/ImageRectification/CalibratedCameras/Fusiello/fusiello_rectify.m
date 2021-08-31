
%
% I1 - left image
% I2 - right image
% pml - projective matrix camera left (camMatrix1)
% pmr - projective matrix camera right (camMatrix2)


function [JL, JR] = fusiello_rectify(I1, I2, pml, pmr)

% Rectification with calibration data

% This function reads a (stereo) pair of images and respective camera matrices
% (PPMs) from files and rectify them. It outputs on files the two rectified
% images in PNG format. It reads  RGB images in PNG format.
%
% The bounding box and the transformation that has been applied
% are saved in the PNG metadata

%         Andrea Fusiello, 2007 (andrea.fusiello@univr.it)


% At this point ml, pml and pmr are set.

[IL] = I1;
[IR] = I2;

%  rectification without centeriing
[TL,TR,pml1,pmr1] = rectify(pml,pmr);

% centering LEFT image
p = [size(IL,1)/2; size(IL,2)/2; 1];
px = TL * p;
dL = p(1:2) - px(1:2)./px(3) ;

% centering RIGHT image
p = [size(IR,1)/2; size(IR,2)/2; 1];
px = TR * p;
dR = p(1:2) - px(1:2)./px(3) ;

% vertical diplacement must be the same
dL(2) = dR(2);

%  rectification with centering
[TL,TR,pml1,pmr1] = rectify(pml,pmr,dL,dR);

% find the smallest bb containining both images
bb = mcbb(size(IL),size(IR), TL, TR);

% warp RGB channels,
for c = 1:3

    % Warp LEFT
    [JL(:,:,c),bbL,alphaL] = imwarp_fusiello(IL(:,:,c), TL, 'bilinear', bb);

    % Warp RIGHT
    [JR(:,:,c),bbR,alphaR] = imwarp_fusiello(IR(:,:,c), TR, 'bilinear', bb);

end

end

