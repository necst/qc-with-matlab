function sudoku = rand_option (sudoku)
      for i = 1:9
          options = setdiff (1:9,sudoku(i,:)); % for every row the possibilities whitout the starting values
          for j = 1:9
              if(sudoku(i,j) == 0) % randomize for every colum of the line
                  tmp = randsample(options,1);
                  options = setdiff(options,tmp);
                  sudoku(i,j) = tmp;
              end
          end
      end
end