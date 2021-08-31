% Function to compute norm value of a patch

% Prepared by: Gabriel da Silva Vieira (Jan 2017)

function n = norm_rectangle(I, h, w)

I = I*255;

I = I.^2;

I = make_border(I,h,w);

ii = integral_image(I);

[h_ii, w_ii] = size(ii);
rec = NaN(h_ii, w_ii);

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
    end
end

n = sqrt(rec);

n = crop_border(n,h,w);

n = n/255;

end