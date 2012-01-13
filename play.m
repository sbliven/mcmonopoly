function [] = play(frames,fps)
% Wrapper for implay, which is missing in octave
if exist('implay') == 2,
    implay(frames, fps);
else,
    for frame = 1:size(frames,3),
        imshow(frames(:,:,frame));
        pause(1/fps);
    end
end

end
