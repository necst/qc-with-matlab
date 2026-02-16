function plotSudoku(sudoku)
% plotSudoku Plots a 9x9 Sudoku grid with bold 3x3 subgrid lines.
%   plotSudoku(sudoku) displays the Sudoku matrix with numbers
%   and thicker lines every 3 rows/columns to highlight blocks.
    % Check that input is 9x9
    if ~isequal(size(sudoku), [9 9])
        error('Input matrix must be 9x9.');
    end
    figure;
    imagesc(sudoku);         % Display the matrix as an image
    colormap("white");          % Use grayscale colormap
    axis equal;              % Equal scaling for X and Y
    axis([0.5 9.5 0.5 9.5]); % Set axis limits to fit the grid
    set(gca, 'XTick', 1:9, 'YTick', 1:9, ...
             'XTickLabel', [], 'YTickLabel', []);
    grid on;
    set(gca, 'GridColor', 'k', 'GridAlpha', 0.2); % Light grid lines
    hold on;
    % Draw horizontal and vertical grid lines with thicker lines every 3 cells
    for i = 0:9
        lw = 1 + (mod(i,3) == 0); % Line width: 2 if multiple of 3, else 1
        line([0.5 9.5], [i+0.5 i+0.5], 'Color', 'k', 'LineWidth', lw); % horizontal
        line([i+0.5 i+0.5], [0.5 9.5], 'Color', 'k', 'LineWidth', lw); % vertical
    end
    % Add numbers to the grid
    for row = 1:9
        for col = 1:9
            val = sudoku(row, col);
            if val ~= 0
                text(col, row, num2str(val), ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', ...
                    'FontSize', 14, ...
                    'FontWeight', 'bold', ...
                    'Color', 'black'); % Non-zero values in red
            end
        end
    end
    hold off;
end