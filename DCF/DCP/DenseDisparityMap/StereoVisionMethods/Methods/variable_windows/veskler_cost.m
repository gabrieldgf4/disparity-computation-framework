%%%%%%%%%%%%%%%
%
% INPUT
%   Cost_mean - the average measurement error in the window w
%   Cost_variance - the variance of the errors in a window w
%   w - a rectangular set of pixels
%   alpha, beta, gamma - are parameters assigning relative weights to
%   terms in equation, in [1] alpha = 1.5, beta = 7, gamma = -2
%
% OUTPUT
%   C_W - the window cost defined for Olga Veskler 


function C_W = veskler_cost(Cost_mean, Cost_variance, w, alpha, beta, gamma)

C_W = Cost_mean + (alpha.*(Cost_variance)) + (beta./(sqrt(w*w) + gamma));

end