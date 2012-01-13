function [ frames ] = makeBoard( x )
%PLAYBOARD Displays a monopoly game as a movie
%   xhist: a 40xN matrix, giving the probabilities of each space at times 1:N

n = size(x,1)/4;
steps = size(x,2);

frames = zeros(n+1,n+1,steps);

frames(end,end:-1:2,:) = x(1:n,:);
frames(end:-1:2,1,:) = x(n+1:2*n,:);
frames(1,1:end-1,:) = x(2*n+1:3*n,:);
frames(1:end-1,end,:) = x(3*n+1:end,:);

end

