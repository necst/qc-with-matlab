 % this is the node object for sudoku graph
 % I create the struct refer for every nodes, whit this i can associate
 % number and if it is a editable number or not
classdef Node_sudoku
    properties
        Value % is the number in the node corrisponde to the matrix number
        Qbit % is the value in binary
        State % is a boolean that say if this node is editable or not (because is one of the initial number)
    end
    methods % associate number to the properties
        function obj = Node_sudoku(val, state)
            obj.State = state;
            obj.Value = val;
            obj.Qbit = dec2bin(val,4); % I convert the binery number in a string, in the livescript I can transfer in the Qbit value whit this idea
        end
    end
end