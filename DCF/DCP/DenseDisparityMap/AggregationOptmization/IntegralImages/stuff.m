% Precomputed images needed for the cost evaluation (μ, σ,...)

% Prepared by: Gabriel da Silva Vieira (Jan 2017)

function [meanI, normI, varI] = stuff(I, h, w)

I = I*255;

I_elev = I.^2;

I = make_border(I,h,w);
ii = integral_image(I);

I_elev = make_border(I_elev,h,w);
ii_elev = integral_image(I_elev);

[h_ii, w_ii] = size(ii);
rec = NaN(h_ii, w_ii);
rec_I_elev = NaN(h_ii, w_ii);

%prepare bordes 
p_h = (h-1)/2;
q_h = p_h+1;
p_w = (w-1)/2;
q_w = p_w+1;

%Start loops
begin_h = q_h+1;
begin_w = q_w+1;
max_h = h_ii - h;
max_w = w_ii - w;

r1_floor = floor(h/2);
r2_floor = floor(w/2);

for i=begin_h:max_h
    for j=begin_w:max_w
        rec(i+r1_floor,j+r2_floor) = sum_rectangle(ii, i, j, h, w);
        rec_I_elev(i+r1_floor,j+r2_floor) = sum_rectangle(ii_elev, i, j, h, w);
    end
end

meanI = rec/(h*w);

normI = sqrt(rec_I_elev);

varI = rec_I_elev./(h*w);
varI = varI-(meanI.*meanI);

meanI = crop_border(meanI,h,w);
varI = crop_border(varI,h,w);
normI = crop_border(normI,h,w);

meanI = meanI/255;
varI = varI/255;
normI = normI/255;

end