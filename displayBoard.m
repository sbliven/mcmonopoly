function [board] = displayBoard(x)
% Takes a 40x1 vector and wraps it around the edge of an 11x11 matrix, starting
% in the lower right corner.
n = length(x)/4;
board = zeros(n+1);

board(end,end:-1:2) = x(1:n);
board(end:-1:2,1) = x(n+1:2*n);
board(1,1:end-1) = x(2*n+1:3*n);
board(1:end-1,end) = x(3*n+1:end);

% display board
imshow(board,[0,1]);

end
