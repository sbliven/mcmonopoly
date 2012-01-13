%% Script to run Markov Chain monopoly statistics

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


D = zeros(40); % transition probabilities for dice movement

% Initialize transition matrix for dice movement
D(1,3:13) = [1:6, 5:-1:1]/36;
for i = 2:40,
    D(i,:) = circshift(D(i-1,:),[0 1]);
end

% Update probabilities for non-dice movement.
ND = eye(40);

% Go directly to jail
jailSquare = find(ismember(squares,'Jail'));
ND(31,:) = 0;
ND(31,jailSquare) = 1;

% This uses cards from the 'Here & Now' edition, but the traditional names
% are used.
% Cards are assumed to be drawn uniformly at random with replacement.

% Community Chest cards: 16 total
% 15 Unchanged
chestSquares = find(ismember(squares,'Community Chest'));
ND(chestSquares,:) = ND(chestSquares,:)*15/16;
% 1 Go directly to Jail
ND(chestSquares,jailSquare) = ND(chestSquares,jailSquare)+1/16;


% Chance cards: 16 total
% 6 Unchanged
chanceSquares= find(ismember(squares,'Chance'));
ND(chanceSquares,:) = ND(chanceSquares,:)*6/16;
% 1 Advance to GO
% 1 Advance to Reading Railroad
% 1 Go directly to Jail
% 1 Advance to St. Charles Place
% 1 Advance to Illinois
% 1 Advance to Boardwalk
dest = find(ismember(squares,{
    'GO','Reading Railroad','Jail','St. Charles','Illinois','Boardwalk'}));
ND(chanceSquares,dest) = ND(chanceSquares,dest) + 1/16;
% 1 Go back 3 spaces
ND(chanceSquares,chanceSquares-3) = ND(chanceSquares,chanceSquares-3) + eye(3)/16;
% 1 Advance to nearest utility
ND(8,13) = ND(8,13) + 1/16;
ND(23,29) = ND(23,29) + 1/16;
ND(37,29) = ND(37,29) + 1/16;

% 2 Advance to nearest railroad
ND(8,6) = ND(8,6) + 2/16;
ND(23,26) = ND(23,26) + 2/16;
ND(37,36) = ND(37,36) + 2/16;


% A turn consists of a dice roll and then some non-dice movement
A = D*ND;


%% Simulate the markov chain for a few steps
steps = 20;
fps = 10;

xhist = zeros(size(A,1),steps+1);
x = eye(1,size(A,1));
xhist(:,1) = x;

for t = 1:steps,
    x = x*A;
    xhist(:,t+1) = x;
end

boardHist = makeBoard(xhist);

% Play a movie (matlab) or simple animation (octave) of the simulation
%play(pToInt(boardHist),5);

%% Find steady state
[V, l] = eigs(A',1,'lm');

xss = V'/sum(V);

imshow(pToInt(makeBoard(xss')));

plot(xss);
line([1 40], [1 1]/40, 'color','red')

[xss_sorted,xss_order ]= sort(xss,'descend');
[ num2cell(xss_sorted(1:10)') squares(xss_order(1:10)) ]


