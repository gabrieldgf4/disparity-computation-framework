function D = nearest_interp(D)

[heigth, width] = size(D);

for i=1:heigth
    neigboor = NaN;
    for j=1:width
        if ~(isnan(D(i,j)))
            neigboor = D(i,j);
        else
            D(i,j) = neigboor;
        end
        
    end
end

end