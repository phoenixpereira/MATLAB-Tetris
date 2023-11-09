function [] = tetris()

rng('shuffle');  % Shuffles the seed for the random number generator.
backgroundColor = [0 0 0]; % Background color of the figure.

gameWindow = figure('menubar','none',...
    'NumberTitle','off',...
    'Position',[450 90 657 687],...
    'color',backgroundColor,...
    'resize','off',...
    'closereq',@figureCloseRequest,...
    'busyaction','cancel');

button = uicontrol('units','pix',...
    'style','pushbutton',...
    'position',[430 130 130 40],...
    'fontweight','bold',...
    'fontsize',20,...
    'string','Start',...
    'callback',@buttonCall,...
    'enable','off',...
    'busyaction','cancel');

figureAxes = axes('units','pix',...
    'position',[420 460 200 200],...
    'ycolor',backgroundColor,...
    'xcolor',backgroundColor,...
    'color',backgroundColor,...
    'xtick',[],'ytick',[],...
    'xlim',[-.1 7.1],...
    'ylim',[-.1 7.1],...
    'visible','off'); % This axes holds the preview.

gameTimer = timer('Name','Tetris_Timer',...
    'Period',1,... % 1 second delay between moves time.
    'StartDelay',1,... %
    'TasksToExecute',50,... % Will be restarted many times.
    'ExecutionMode','fixedrate',...
    'TimerFcn',@gameStep); % Function defined below.

infoAxes = axes('units','pix',...
    'position',[410 130 220 320],...
    'ycolor',backgroundColor,...
    'xcolor',backgroundColor,...
    'xtick',[],'ytick',[],...
    'xlim',[-.1 1.1],...
    'ylim',[-.1 1.1],...
    'visible','off'); % Points and Lines holder

mainAxes = axes('units','pix',...
    'position',[30 30 360 630],...
    'ycolor',backgroundColor,...
    'xcolor',backgroundColor,...
    'xtick',[],'ytick',[],...
    'xlim',[-1 11],...
    'ylim',[-1 20],...
    'color',backgroundColor,...
    'visible','off'); % The main game board

% Template positions for the patch objects for both axes.
X = [0 .2 0;.2 .8 .2;.2 .8 .8;.8 .2 .8;1 .2 1;0 .2 1;0 .2 0];
Y = [0 .2 0;.2 .2 .2;.8 .8 .2;.8 .8 .8;1 .2 1;1 .2 0;0 .2 0];
g1 = repmat([.9 .65 .4],[1,1,3]); % Grey color used throughout.

previewPosition{1} = [1.5 2.5 3.5 4.5;3 3 3 3]; % Positions of the previews
previewPosition{2} = [2 3 3 4;2.5 2.5 3.5 2.5]; % 1-I,2-T,3-L,4-J,5-Z,6-S,
% 7-O
previewPosition{3} = [2 3 4 4;2.5 2.5 2.5 3.5];
previewPosition{4} = [2 2 3 4;3.5 2.5 2.5 2.5];
previewPosition{5} = [2 3 3 4;3.5 3.5 2.5 2.5];
previewPosition{6} = [2 3 3 4;2.5 2.5 3.5 3.5];
previewPosition{7} = [2.5 2.5 3.5 3.5;3.5 2.5 3.5 2.5];

% Makes the board borders.
for i = [-1 10]
    Xi = X + i;
    for j = -1:19
        patch(Xi,Y+j,g1,...
            'edgecolor','none',...
            'handlevis','callback')
    end
end

for i = 0:9
    patch(X+i,Y-1,g1,'edgecolor','none','handlevis','callback')
end

patchHandles = zeros(10,20); % Handles for the patches.

for i = 0:19 % Assigns the patch handles.
    for j = 0:9
        patchHandles(j+1,i+1) = patch(X+j,Y+i,'black','edgecolor',...
            'black');
    end
end

% Creates the axes for the side board
boardArea = axes('units','pix',...
    'position',[360 30 360 630],...
    'ycolor',backgroundColor,...
    'xcolor',backgroundColor,...
    'xtick',[],'ytick',[],...
    'xlim',[-1 11],...
    'ylim',[-1 20],...
    'color',backgroundColor,...
    'visible','off');

% Creates the texts for 'Level' and 'Score.
levelTitleText = text(2.3, 13,'Level','Color','w','FontSize',25,...
    'FontWeight','bold');
levelValueText = text(3.5, 11.5,'1','Color','w','FontSize',25,...
    'FontWeight','bold', 'HorizontalAlignment','center');
scoreTitleText = text(2.3, 9,'Score','Color','w','FontSize',25,...
    'FontWeight','bold');
scoreValueText = text(3.5, 7.5,'0','Color','w','FontSize',25,...
    'FontWeight','bold', 'HorizontalAlignment','center');

% Surronds the Level and Score text with blocks.
for i = -1:19
    if (i >= -1 && i <= 1) || (i >= 4 && i <= 5) || i == 14 || i == 19
        for j = 0:7
            patch(X+j,Y+i,g1,'edgecolor','none','handlevis','callback')
        end
    end

    if i == 0 || i == 6 || i == 7
        for j = 0:18
            patch(X+i,Y+j,g1,'edgecolor','none','handlevis','callback')
        end
    end
end

% Hold the colors of the pieces, and board index where each first appears.
% Has colour format [r1, r2, r3, g1, g2, g3, b1, b2, b3].
blockColors = {reshape([0.67 0.37 0.17 1 0.94 0.47 1 0.94 0.47],1,3,3),...
    reshape([0.83 0.58 0.29 0.61 0.14 0.05 0.99 10.93 0.47],1,3,3),...
    reshape([0.99 0.91 0.45 0.86 0.62 0.31 0.61 0.10 0.03],1,3,3),...
    reshape([0.59 0 0 0.61 0.14 0.05 0.99 0.93 0.47],1,3,3),...
    reshape([0.96 0.89 0.44 0.60 0 0 0.60 0.02 0],1,3,3),...
    reshape([0.68 0.39 0.18 1 0.93 0.47 0.62 0.16 0.05],1,3,3),...
    reshape([1 0.95 0.59 0.99 0.93 0.58 0.62 0.16 0.08],1,3,3)};

% startingBlockLocations holds the location where each piece first appears
% on the board.
startingBlockLocations = {194:197,[184 185 186 195],[184 185 186 196],...
    [184 185 186 194],[194 195 185 186],[184 195 185 196],...
    [185 186 195 196]};

currentPreview = []; % Holds current preview patches.
previewNumber = []; % Holds the preview piece number, 1-7.
createBlockPreview;  % Calls the function to choose the piece to go next.
matrixGameBoard = false(10,20); % The matrix game board.
currentRotation = 1; % Holds the current rotation of the current piece.
currentScore = 0; % Holds the current score during play.
playerLevel = 1; % The level the player chooses to start.
pointValues = [40 100 300 800]; % Holds the points per number of lines.
currentLevel = 1; % The current level.
currentLines = 0;
stopTimer = 0; % Stops timer when user is pressing keyboard buttons.
timerDelayPercent = .825;  % Percent of previous timer delay.
currentLocation = 0; % Initialise variable
correctColor = 0; % Initialise variable
currentPreviewNumber = 0; % Initialise variable
lineIncrement = 10; % Increment level every lineIncrement lines.

% Reads in the sound files
[y, Fs] = audioread('music/startScreenMusic.mp3');
[y2, Fs2] = audioread('music/mainGameMusic.mp3');
[y3, Fs3] = audioread('music/gameOver.mp3');
[y4, Fs4] = audioread('music/fall.mp3');
[y5, Fs5] = audioread('music/line.mp3');

% Creates audioplayer for the music and soundFx.
musicPlayer = audioplayer(y,Fs); 
soundFxPlayer = audioplayer(y4,Fs4);

% Creates a timer to call the function to loop the music.
audioPlayerStateTimer = timer;
audioPlayerStateTimer.TimerFcn = @checkForMusicPlaying;
audioPlayerStateTimer.Period = 1;
audioPlayerStateTimer.ExecutionMode = 'fixedRate';
start(audioPlayerStateTimer);
musicSpeedMultiplier = 1;

% Loads the variable from the high score file if found.
try
    score = load('tetrisHighScore.mat');
    currentHighScore = score.score; % The user has a previous High Score.
catch
    currentHighScore = 0;
end

% Sets the figure title to the high score.
set(gameWindow,'name',['Tetris',' High Score : ',...
    sprintf('%i',currentHighScore)])
set(button,'enable','on') % Enable the start button once the game is ready.

% Creates a 'How to Play" message box.
msgbox("To move the piece, use the left and right arrow keys. To" + ...
    " rotate the piece clockwise use the up arrow key or use shift +" + ...
    " up arrow key to rotate the piece counter clockwise. To drop" + ...
    " the block down faster, use the down arrow key. Clear multiple" + ...
    " lines to get points faster!", "How To Play");

    % Chooses which piece is going next and displays it.
    function [] = createBlockPreview(varargin)
        if nargin
            previewNumber = varargin{1};
        else
            previewNumber = ceil(rand*7); % Randomly choose a piece.
        end
        if ~isempty(currentPreview)
            delete(currentPreview) % Delete previous preview.
        end
        C = blockColors{previewNumber};  % User wants to show preview.
        for i = 1:4  % Create a new preview.
            currentPreview(i) = patch(X-1+previewPosition...
                {previewNumber}(1,i),Y+0.5+previewPosition...
                {previewNumber}(2,i),C,'edgecolor','none',...
                'parent',figureAxes);
        end
        [y4, Fs4] = audioread('music/fall.mp3');
        soundFxPlayer = audioplayer(y4,Fs4);
        play(soundFxPlayer);
    end

% Starts playing music.
play(musicPlayer);

    % Callback for the button.
    function [] = buttonCall(varargin)
        switch get(button,'string')
            case 'Start'
                % Clear board.
                set(patchHandles(:),'facecol','black','edgecol','black');
                set(button,'string','Pause'); % Change button label.
                currentLevel = playerLevel; % Sets the game level.
                timerCount = round(1000*timerDelayPercent^...
                    (playerLevel-1))/1000;% Update Timer.
                set(gameTimer,'startdelay',timerCount,'period',timerCount);
                currentScore = 0; % Resets score before game starts.
                levelValueText.String = '1';
                scoreValueText.String = '0';
                playGame; % Initiate Gameplay.
                stop(musicPlayer);
                musicPlayer = audioplayer(y2,Fs2);
            case 'Pause'
                stopGame;  % Stop the timer, set the callbacks
                set(button,'string','Continue')
            case 'Continue'
                set(button,'string','Pause')
                startGame;  % Restart the timer.
            otherwise
        end
    end

    % Picks the next piece and puts the preview in correct axes.
    function [] = playGame()
        currentPreviewNumber = previewNumber;
        currentLocation = startingBlockLocations{previewNumber}; % Current
        % location of current piece.
        correctColor = blockColors{previewNumber}; % Transfer correct color
        currentRotation = 1; % Initial rotation number.
        set(patchHandles(currentLocation),'facec','flat','cdata',...
            correctColor,'edgecol','none')
        if any(matrixGameBoard(currentLocation))
            cleanGame;  % Clean up the board.
            return
        else
            matrixGameBoard(currentLocation) = true; % Updates matrix.
        end
        createBlockPreview; % Sets up the next piece.
        startGame; % Starts the timer.
    end

    % Advances the current piece down the board.
    function [] = gameStep(varargin)
        if stopTimer && nargin  % Only calls timer with an argument.
            return  % So that timer can't interrupt.
        end
        col = ceil(currentLocation/10); % currentLocation defined in
        % playGame.
        row = rem(currentLocation-1,10) + 1;  % For the board matrix.
        if any(col==1)  % Piece is at the bottom of the board.
            stopGame;
            checkRows;
            playGame;
        else
            ur = unique(row);  % Check to see if the piece can drop down.
            for i = 1:length(ur)
                if (matrixGameBoard(ur(i),min(col(row==ur(i)))-1))
                    stopGame;
                    checkRows;
                    playGame;
                    return
                end
            end
            mover(-10)  % Drops the piece.
        end
    end

    % Cleans up the board and board matrix after game over.
    function [] = cleanGame()
        stopGame;  % Stops the timer.
        stop(musicPlayer);
        musicPlayer = audioplayer(y3,Fs3);
        for i = 1:20
            set(patchHandles(:,i),'cdata',g1,'edgecol','none')
            drawnow % Gives the effect of grey climbing up.
        end
        set(button,'string','Start')
        matrixGameBoard(:) = false; % Resets the board matrix.
        pause(2);
        musicPlayer = audioplayer(y,Fs);
    end

    % Sets the correct callbacks and timer for a new game.
    function [] = startGame()
        set([gameWindow,button],'keypressfcn',@keyPressFunction)
        start(gameTimer);
    end

    % Figure and button keyPressFunction
    function [] = keyPressFunction(varargin)
        stopTimer = 1;  % Stop timer interrupts - See gameStep
        if strcmp(varargin{2}.Key,'downarrow')
            gameStep; % Just call another step.
            stopTimer = 0;  % Unblock the timer.
            return
        end
        col = ceil(currentLocation/10); % currentLocation in playGame.
        row = rem(currentLocation-1,10) + 1;  % These index into board
        % matrix.
        switch varargin{2}.Key
            case 'rightarrow'
                % Without this if, the piece will wrap around!
                if max(row)<=9
                    uc = unique(col);  % Check if object to the right.
                    for i = 1:length(uc)
                        if (matrixGameBoard(max(row(col==uc(i)))+1,...
                                uc(i)))
                            stopTimer = 0;
                            return
                        end
                    end
                    mover(1)   % Can move.
                end
            case 'leftarrow'
                if min(row)>=2
                    uc = unique(col);  % Check if object to the left.
                    for i = 1:length(uc)
                        if (matrixGameBoard(min(row(col==uc(i)))-1,...
                                uc(i)))
                            stopTimer = 0;
                            return
                        end
                    end
                    mover(-1)  % O.k. to move.
                end
            case 'uparrow'
                if strcmp(varargin{2}.Modifier,'shift')
                    arg = 1;  % User wants counter-clockwise turn.
                else
                    arg = 0;
                end
                rotateBlock(row,col,arg);  % Turns the piece.
            otherwise
        end
        stopTimer = 0;  % Unblock the timer.
    end

    % Moves a piece on the board.
    function [] = mover(N)
        matrixGameBoard(currentLocation) = false; % currentLocation,
        % correctColor defined in play_tet.
        matrixGameBoard(currentLocation+N) = true; % All checks should be
        % done already.
        currentLocation = currentLocation + N;
        set([patchHandles(currentLocation-N),...
            patchHandles(currentLocation)],...
            {'facecolor'},{'black';'black';'black';'black';'flat';...
            'flat';'flat';'flat'},...
            {'edgecolor'},{'black';'black';'black';'black';'none';...
            'none';'none';'none'},...
            {'cdata'},{[];[];[];[];correctColor;correctColor;...
            correctColor;correctColor})
    end

    % Rotates the pieces once at a time.
    function [] = rotateBlock(row,col,arg)
        % r is for left/right, c is for up/down.
        % For the switch:  1-I,2-T,3-L,4-J,5-Z,6-S,7-O.
        switch currentPreviewNumber % Defined in playGame.
            % Turn is dependent on shape.
            case 1
                if any(col>19) || all(col<=2)
                    return
                else
                    if currentRotation == 1
                        r = [row(2),row(2),row(2),row(2)];
                        c = [col(2)-2,col(2)-1,col(2),col(2)+1];
                        currentRotation = 2;
                    elseif all(row>=9)
                        r = 7:10;
                        c = [col(2),col(2),col(2),col(2)];
                        currentRotation = 1;
                    elseif all(row==1)
                        r = 1:4;
                        c = [col(2),col(2),col(2),col(2)];
                        currentRotation = 1;
                    else
                        r = [row(2)-1,row(2),row(2)+1,row(2)+2];
                        c = [col(2),col(2),col(2),col(2)];
                        currentRotation = 1;
                    end
                end
            case 2
                if sum(col==1)==3
                    return
                end
                if arg
                    currentRotation = mod(currentRotation+1,4)+1;
                end
                switch currentRotation
                    case 1
                        r = [row(2),row(2),row(2),row(2)+1];
                        c = [col(2)-1,col(2),col(2)+1,col(2)];
                    case 2
                        if sum(row==1)==3
                            r = [1 2 3 2];
                            c = [col(2),col(2),col(2),col(2)-1];
                        else
                            r = [row(2)-1,row(2),row(2),row(2)+1];
                            c = [col(2),col(2),col(2)-1,col(2)];
                        end
                    case 3
                        r = [row(2)-1,row(2),row(2),row(2)];
                        c = [col(2),col(2),col(2)-1,col(2)+1];
                    case 4
                        if sum(row==10)==3
                            r = [9 9 8 10];
                            c = [col(2)+1,col(2),col(2),col(2)];
                        else
                            r = [row(2)-1,row(2),row(2),row(2)+1];
                            c = [col(2),col(2),col(2)+1,col(2)];
                        end
                end
                currentRotation = mod(currentRotation,4) + 1;
            case 3
                if sum(col==1)==3
                    return
                end
                if arg
                    currentRotation = mod(currentRotation+1,4)+1;
                end
                switch currentRotation
                    case 1
                        r = [row(2),row(2),row(2),row(2)+1];
                        c = [col(2)+1,col(2),col(2)-1,col(2)-1];
                    case 2
                        if sum(row==1)==3
                            r = [1:3 1];
                            c = [col(2),col(2),col(2),col(2)-1];
                        else
                            r = [row(2)-1,row(2),row(2)-1,row(2)+1];
                            c = [col(2),col(2),col(2)-1,col(2)];
                        end
                    case 3
                        r = [row(2)-1,row(2),row(2),row(2)];
                        c = [col(2)+1,col(2),col(2)+1,col(2)-1];
                    case 4
                        if sum(row==10)==3
                            r = [10 9 10 8];
                            c = [col(2)+1,col(2),col(2),col(2)];
                        else
                            r = [row(2)-1,row(2),row(2)+1,row(2)+1];
                            c = [col(2),col(2),col(2),col(2)+1];
                        end
                end
                currentRotation = mod(currentRotation,4) + 1;
            case 4
                if sum(col==1)==3
                    return
                end
                if arg
                    currentRotation = mod(currentRotation+1,4)+1;
                end
                switch currentRotation
                    case 1
                        r = [row(2),row(2),row(2),row(2)+1];
                        c = [col(2)-1,col(2),col(2)+1,col(2)+1];
                    case 2
                        if sum(row==1)==3
                            r = [1 2 3 3];
                            c = [col(2),col(2),col(2),col(2)-1];
                        else
                            r = [row(2)-1,row(2),row(2)+1,row(2)+1];
                            c = [col(2),col(2),col(2),col(2)-1];
                        end
                    case 3
                        r = [row(2)-1,row(2),row(2),row(2)];
                        c = [col(2)-1,col(2),col(2)-1,col(2)+1];
                    case 4
                        if sum(row==10)==3
                            r = [8 9 8 10];
                            c = [col(2)+1,col(2),col(2),col(2)];
                        else
                            r = [row(2)-1,row(2),row(2)-1,row(2)+1];
                            c = [col(2),col(2),col(2)+1,col(2)];
                        end
                end
                currentRotation = mod(currentRotation,4) + 1;
            case 5
                if any(col(2)>19) || sum(col==1)==2
                    return
                elseif currentRotation==1
                    r = [row(2),row(2),row(2)-1,row(2)-1];
                    c = [col(2)+1,col(2),col(2),col(2)-1];
                    currentRotation = 2;
                else
                    if sum(row==10)==2
                        r = [10 9 9 8];
                        c = [col(2)-1,col(2)-1,col(2),col(2)];
                    else
                        r = [row(2)-1,row(2),row(2),row(2)+1];
                        c = [col(2),col(2),col(2)-1,col(2)-1];
                    end
                    currentRotation = 1;
                end
            case 6
                if any(col(2)>19)|| sum(col==1)==2
                    return
                elseif currentRotation==1
                    r = [row(2)+1,row(2),row(2)+1,row(2)];
                    c = [col(2)-1,col(2),col(2),col(2)+1];
                    currentRotation = 2;
                else
                    if sum(row==1)==2
                        r = [1 2 2 3];
                        c = [col(2)-1,col(2)-1,col(2),col(2)];
                    else
                        r = [row(2)-1,row(2),row(2),row(2)+1];
                        c = [col(2)-1,col(2),col(2)-1,col(2)];
                    end
                    currentRotation = 1;
                end
            otherwise
                return % The O piece.
        end
        ind = r + (c-1)*10; % Holds new piece locations.
        tmp = currentLocation; % Want to call SET last! currentLocation
        % defined in playGame.
        matrixGameBoard(currentLocation) = false;
        if any(matrixGameBoard(ind)) % Check if any pieces are in the way.
            matrixGameBoard(currentLocation) = true;
            return
        end
        matrixGameBoard(ind) = true;
        currentLocation = ind; % currentLocation, correctColor defined in
        % playGame
        set([patchHandles(tmp),patchHandles(ind)],...
            {'facecolor'},{'black';'black';'black';'black';'flat';...
            'flat';'flat';'flat'},...
            {'edgecolor'},{'black';'black';'black';'black';'none';...
            'none';'none';'none'},...
            {'cdata'},{[];[];[];[];correctColor;correctColor;...
            correctColor;correctColor});
    end

    % Sets the correct callbacks and timer to stop game.
    function [] = stopGame()
        stop(gameTimer)
        set([gameWindow,button],'keypressfcn','fprintf('''')')
    end

    % Checks if any row(s) needs clearing and clears it (them).
    function [] = checkRows()
        fullRows = all(matrixGameBoard); % Finds the rows that are full.
        if any(fullRows)  % There is a row that needs clearing.
            set(button,'enable','off')  % Don't allow user to mess it up.
            numberOfRows = sum(fullRows); % How many rows are there?
            B = false(size(matrixGameBoard));  % Temp store to switch.
            B(:,1:20-numberOfRows) = matrixGameBoard(:,~fullRows);
            matrixGameBoard = B;
            fullRows1 = find(fullRows); % Only need to drop those rows
            % above.
            rowLength = length(fullRows1);
            fullRows = fullRows1-(0:rowLength-1);
            currentLines = currentLines + rowLength;
            currentScore = currentScore + pointValues(rowLength)*currentLevel;
            scoreValueText.String = currentScore;
            soundFxPlayer = audioplayer(y5,Fs5);
            play(soundFxPlayer);
            for i = 1:rowLength % Make these rows to flash for effect.
                set(patchHandles(:,fullRows1(:)),'facecolor','r');
                pause(.1)
                set(patchHandles(:,fullRows1(:)),'facecolor','g');
                pause(.1)
            end
            for i = 1:rowLength % 'Delete' these rows.
                set(patchHandles(:,fullRows(i):19),...
                    {'facecolor';'edgecolor';'cdata'},...
                    get(patchHandles(:,fullRows(i)+1:20),...
                    {'facecolor';'edgecolor';'cdata'}));
            end
            % Level display check.
            if (floor(currentLocation/lineIncrement)+1)>currentLevel
                currentLevel = currentLevel + 1; % Increases level.
                levelValueText.String = currentLevel;
                musicSpeedMultiplier = musicSpeedMultiplier + 0.05;
                musicPlayer = audioplayer(y2,Fs2 * musicSpeedMultiplier);
                timerCount = round(get(gameTimer,'startdelay')*...
                    timerDelayPercent*1000)/1000;
                timerCount = max(timerCount,.001);
                % Update timer
                set(gameTimer,'startdelay',timerCount,'period',timerCount)
            end
            if currentScore>=currentHighScore  % So that figure name is
                % current.
                currentHighScore = currentScore;
                set(gameWindow,'name',...
                    sprinfullRows('Tetris High Score : %i',...
                    currentHighScore))
            end
            set(button,'enable','on')  % Now user can go.
        end
    end

    % Clean-up if user closes figure while timer is running.
    function [] = figureCloseRequest(varargin)
        try  % Try here so user can close after error in creation of GUI.
            warning('off','MATLAB:timer:deleterunning')
            % Deletes timers and music player.
            delete(gameTimer); 
            delete(audioPlayerStateTimer);
            delete(musicPlayer);
            warning('on','MATLAB:timer:deleterunning')
            score = currentHighScore;

            % Tries saving the high score file, displays error message if
            % error occurs.
            try
                save('tetrisHighScore.mat','score')
            catch
                disp('Error saving high score. Please check permissions.')
            end
        catch
        end
        delete(varargin{1})  % Now the figure can close
    end

    % Loops game music.
    function [] = checkForMusicPlaying(~, ~)
        if ~isplaying(musicPlayer)
            play(musicPlayer);
        end
    end
end