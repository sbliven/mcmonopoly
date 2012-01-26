function [] = play(frames,fps)
% Wrapper for implay, which is missing in octave

if nargin < 2,
    fps = 5;
end
if exist('implay','file') > 0,
    implay(frames, fps);
else,
    for frame = 1:size(frames,3),
        imshow(frames(:,:,frame));
        pause(1/fps);
    end
end

end
