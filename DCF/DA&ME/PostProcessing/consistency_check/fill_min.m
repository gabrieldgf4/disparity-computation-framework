function D_occ = fill_min(D_occ)
[r,c] = size(D_occ);
D_occ(D_occ == -1) = NaN;
rigth = 1000;
for i=1:r
    for j=2:c
        left = D_occ(i,j-1);
        % fill in the occluded pixel with a valid disparity in the scanline
        if isnan(D_occ(i,j))
            for k=j+1:c
                if ~isnan(D_occ(i,k))
                    rigth = D_occ(i,k);
                    break;
                end
            end
            D_occ(i,j) = nanmin(left, rigth);
        end
    end
end
end