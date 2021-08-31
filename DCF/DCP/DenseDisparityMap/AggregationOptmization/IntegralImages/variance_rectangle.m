% Function to compute variance value of a patch

% Prepared by: Gabriel da Silva Vieira (Jan 2017)

function variancia = variance_rectangle(I, h, w)

I = I*255;

I_elev = I.^2;
I = make_border(I,h,w);
I_elev = make_border(I_elev,h,w);

ii = integral_image(I);
ii_elev = integral_image(I_elev);

[h_ii, w_ii] = size(ii);
rec_I = NaN(h_ii, w_ii);
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
        rec_I(i+r1_floor,j+r2_floor) = sum_rectangle(ii, i, j, h, w);
        rec_I_elev(i+r1_floor,j+r2_floor) = sum_rectangle(ii_elev, i, j, h, w);
    end
end

media = rec_I/(h*w);

variancia = rec_I_elev/(h*w);
variancia = variancia-(media.*media);
variancia = crop_border(variancia,h,w);

variancia = variancia /255;

end