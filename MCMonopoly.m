%% Script to run Markov Chain monopoly statistics

x0 = eye(1,40); % probability of being on each square
A = zeros(40); % transition probabilities from dice rolls

% Initialize transition matrix for dice movement
A(1,3:13) = [1:6, 5:-1:1]/36;
for i = 2:40,
    A(i,:) = circshift(A(i-1,:),[0 1]);
end

% Update probabilities for movement via Chance and Community Chest cards. 
% This uses cards from the 'Here & Now' edition, but names have been translated to the traditional version.
% Cards are assumed to be drawn uniformly at random with replacement.

squares = {
    'GO';               %1
    'Mediterranean';
    'Community Chest';
    'Baltic';
    'Income Tax';
    'Reading Railroad';
    'Oreintal';
    'Chance';
    'Vermont';
    'Connecticut';
    'Jail';             %11
    'St. Charles';
    'Electric Co';
    'States';
    'Virginia';
    'Pennsylvania Railroad';
    'St. James';
    'Communtity Chest';
    'Tennessee';
    'New York';
    'Free Parking';     %21
    'Kentucky';
    'Chance';
    'Indiana';
    'Illinois';
    'B&O Railroad';
    'Atlantic';
    'Venture';
    'Water Works';
    'Marvin Gardens';
    'Go To Jail';       %31
    'Pacific';
    'North Carolina';
    'Community Chest';
    'Pennsylvania';
    'Short Line Railroad';
    'Chance';
    'Park Place';
    'Luxury Tax';
    'Boardwalk'
};

% Go directly to jail
jailSquare = 11;
A(31,:) = 0;
A(31,jailSquare) = 1;

% Community Chest cards: 16 total
% 15 Unchanged
chestSquares = find(ismember(squares,'Community Chest'));
A(chestSquares,:) = A(chestSquares,:)*15/16;
% 1 Go directly to Jail
A(chestSquares,jailSquare) = A(chestSquares,jailSquare)+1/16;


% Chance cards: 16 total
% 6 Unchanged
chanceSquares= find(ismember(squares,'Chance'));
A(chanceSquares,:) = A(chanceSquares,:)*6/16;
% 1 Advance to GO
% 1 Advance to Reading Railroad
% 1 Go directly to Jail
% 1 Advance to St. Charles Place
% 1 Advance to Illinois
% 1 Advance to Boardwalk
dest = find(ismember(squares,{
    'GO','Reading Railroad','Jail','St. Charles','Illinois','Boardwalk'}));
A(chanceSquares,dest) = A(chanceSquares,dest) + 1/16;
% 1 Go back 3 spaces
A(chanceSquares,chanceSquares-3) = A(chanceSquares,chanceSquares-3) + eye(3)/16;
% 1 Advance to nearest utility
A(8,13) = A(8,13) + 1/16;
A(23,29) = A(23,29) + 1/16;
A(37,29) = A(37,29) + 1/16;

% 2 Advance to nearest railroad
A(8,6) = A(8,6) + 2/16;
A(23,26) = A(23,26) + 2/16;
A(37,36) = A(37,36) + 2/16;



%% Animate board
steps = 20;
fps = 10;

xhist = zeros(length(x0),steps+1);
xhist(:,1) = x0;
x = x0;
%boardhist = zeros(length(x)/4+1,length(x)/4+1,steps+1);

%boardhist(:,:,1) = displayBoard(x);
%pause(1/fps);
for t = 1:steps,
    x = x*A;
    xhist(:,t+1) = x;
    %boardhist(:,:,t+1) = displayBoard(x.^(log(.5)/log(1/40)) );
    %pause(1/fps);
end

boardHist = makeBoard(xhist);

%play(pToInt(boardHist),5);

%% Find steady state
[V, l] = eigs(A',1,'lm');

xss = V'/sum(V);

imshow(pToInt(makeBoard(xss')));
