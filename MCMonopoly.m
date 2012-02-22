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
steps = 50;
fps = 10;

xhist = zeros(size(A,1),steps);
x = eye(1,size(A,1));
xhist(:,1) = x;

for t = 1:steps,
    x = x*A;
    xhist(:,t+1) = x;
end

boardHist = makeBoard(xhist);

%% Find steady state
[V, l] = eigs(A',1,'lm');

xss = V'/sum(V); %x at steady state, eg t->infinity



%% Plots

return; % don't create plots

%% Play a movie (matlab) or simple animation (octave) of the simulation
play(pToInt(boardHist),5);

%% Display steady state

imshow(pToInt(makeBoard(xss')));

%% Print a table of the top 10 squares
[xss_sorted,xss_order ]= sort(xss,'descend');
[ num2cell(1:20)' num2cell(xss_sorted(1:20)') squares(xss_order(1:20)) ]

%% plot the steady state probability and label the 10 most extreme peaks
plot(xss);
line([1 40], [1 1]/40, 'color','red');
xlabel('Square','fontname','Vera','fontsize',14);
ylabel('Probability','fontname','Vera','fontsize',14);
lim = ylim();
ylim([0,lim(2)]);
text(xss_order([1:5 end-4:end]),xss_sorted([1:5 end-4:end]), ...
    squares(xss_order([1:5 end-4:end])), ...
    'fontname','Vera','fontsize',14);



%% Plot some individual squares through the game
lineStyleOrder = get(0,'DefaultAxesLineStyleOrder');
set(0,'DefaultAxesLineStyleOrder','-|-*|-s|-o|--|--*|--s|--o');
plottedSquares = 1:40;%[xss_order(1:10) 12];
plot(xhist(plottedSquares,:)');
xlim([0 20]);
ylim([0 .15]);
legend(squares{plottedSquares});
set(0,'DefaultAxesLineStyleOrder',lineStyleOrder)

%% Early-game advantage
% Since the game does not start at steady state, some squares will be
% landed on more often in the early game than would be expected from their
% steady state distribution.
%
% For a given turn and square, define the advantage to be the ratio of
% expected number of times someone has landed on that square starting at
% GO! at time 1 vs starting at steady state.
advantage = zeros(size(xhist));
for i=1:size(xhist,2),
    advantage(:,i) = sum(xhist(:,1:i),2)./xss'/i;
end
%sort based on order at turn 10
[advantage_sorted, advantage_order] = sort(advantage(:,10),'descend');

lineStyleOrder = get(0,'DefaultAxesLineStyleOrder');
set(0,'DefaultAxesLineStyleOrder','-|-*|-s|-o|--|--*|--s|--o');
plottedSquares = [advantage_order([1:5 end-5:end])' 12 24 25];
plottedSquares = 1:40;
plot(advantage(plottedSquares,:)');
xlim([0 20]);
ylim([0 4]);
legend(squares{plottedSquares});
set(0,'DefaultAxesLineStyleOrder',lineStyleOrder)
