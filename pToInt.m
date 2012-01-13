function [ y ] = pToInt( x, midpoint )
%PTOINT Transforms a probability [0,1] to a uint8 [0,255]
% uses a exponential transforma such that pToInt(midPoint) = 127.
if nargin < 2,
    midpoint = 1/40;
end

y = uint8(floor(x.^(-1/log2(midpoint))*255));

end

