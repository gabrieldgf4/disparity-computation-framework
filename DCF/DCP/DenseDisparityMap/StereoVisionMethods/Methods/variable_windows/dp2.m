% Dynamic Programming
% It works like shiftable_windows, but the windows need to be square and
% in this version the windows DOESN'T need to fixed (equal) for all lines
%
% Cost - the cost volume, like a cost calculate between two images using
% SAD, SSD ...
% vet_min_idx - the size of a window for each column, ex., 3 to pixel(1,1) means 
% that windows for that column is 3x3 
%
% M_out - the cost of the minimum cost window (x,y) belongs to
%

function M_out = dp2(Cost, Mx_out, My_out, Used_Windows)


    [heigth, width, channel] = size(Cost);
    M_out = NaN(heigth,width,channel);
         
    for disp=1:channel
       C_W = Cost(:,:,disp);
       Used_Windows_Disp = Used_Windows(:,:,disp)+1;
       Mx = Mx_out(:,:,disp)+1;
       My = My_out(:,:,disp)+1;
       
       % Prepare C_W to avoid illegal indexes
       C_W = padarray(C_W, [1, 1], NaN);
       Used_Windows_Disp = padarray(Used_Windows_Disp, [1, 1], NaN);
       
       h_max = max(Used_Windows_Disp(:));
       
       Mx = padarray(Mx, [1, 1], NaN);
       My = padarray(My, [1, 1], NaN);
       Mx(1,1:end) = 1:1:width+2;
       My(1:end,1) = 1:1:heigth+2;
       
       Mx_origen = Mx;
       My_origen = My;
       
       M = NaN(heigth+2, width+2);
            
       for x=2:heigth+1  

        for y=2:width+1   
                           
            if Mx(x-1,y) >= x && My(x,y-1) >= y
                [v, index] = min([M(x,y-1), M(x-1,y), C_W(x,y)]);
                if index==1
                    M(x,y) = M(x,y-1); 
                    Mx(x,y) = Mx(x,y-1); 
                    My(x,y) = My(x,y-1); 
                elseif index==2
                    M(x,y) = M(x-1,y); 
                    Mx(x,y) = Mx(x-1,y);
                    My(x,y) = My(x-1,y); 
                else
                    M(x,y) = C_W(x,y);  
                end
                
            elseif Mx(x-1,y) >= x && My(x,y-1) < y
                
                max_w = max(Used_Windows_Disp(x,2:y));
                
                c_min_marcador = NaN(1,1,3);
                y1 =  y - max_w + 1; % y1 = y -k +1;
    
                if y1 <= 1
                   y1 = 2;
                end
                
                for regressiva=y:-1:y1
                    
                    if (Mx_origen(x,regressiva) < x) || (My_origen(x,regressiva) < y)
                        continue;
                    end
                 
                    [c_min, index] = min([C_W(x,regressiva), c_min_marcador(1,1,1)]);
                    if index==1
                        c_min_marcador(1,1,:) = [c_min, Mx_origen(x,regressiva), My_origen(x,regressiva)];
                    end
                end
                
               [v, index] = min([c_min_marcador(1,1,1), M(x-1,y)]);
               if index==1
                   M(x,y) = c_min_marcador(1,1,1);   
                   Mx(x,y) = c_min_marcador(1,1,2);
                   My(x,y) = c_min_marcador(1,1,3);
               else
                   M(x,y) = M(x-1,y);
                   Mx(x,y) = Mx(x-1,y);
                   My(x,y) = My(x-1,y);
               end
               
            elseif Mx(x-1,y) < x && My(x,y-1) >= y
                
                max_w = max(Used_Windows_Disp(2:x,y));
                
                c_min_marcador = NaN(1,1,3);
                x1 =  x - max_w + 1; % x1 = x -k +1;

                if x1 <= 1
                   x1 = 2;
                end
                
                for regressiva=x:-1:x1
                
                    if (Mx_origen(regressiva,y) < x) || (My_origen(regressiva,y) < y)
                        continue;
                    end
                 
                    [c_min, index] = min([C_W(regressiva,y), c_min_marcador(1,1,1)]);
                    if index==1
                        c_min_marcador(1,1,:) = [c_min, Mx_origen(regressiva,y), My_origen(regressiva,y)];
                    end
                end
               
               [v, index] = min([c_min_marcador(1,1,1), M(x,y-1)]);
               if index==1
                   M(x,y) = c_min_marcador(1,1,1);   
                   Mx(x,y) = c_min_marcador(1,1,2);
                   My(x,y) = c_min_marcador(1,1,3);
               else
                   M(x,y) = M(x,y-1);
                   Mx(x,y) = Mx(x,y-1);
                   My(x,y) = My(x,y-1);
               end
           
            else 
              
                c_w = C_W(1:x,1:y);
                c_w(Mx_origen(1:x,1:y) < x | My_origen(1:x,1:y) < y) = NaN;
                
                [min_c_w, idx] = nanmin(c_w(:));

               [lin, col] = ind2sub(size(c_w),idx);

                    M(x,y) = min_c_w;%M(lin,col);
                    Mx(x,y) = Mx_origen(lin,col);
                    My(x,y) = My_origen(lin,col);
               
            end
           
        end
       end
       M = crop_border(M,1,1);
       M_out(:,:,disp) = M;
    end
end
