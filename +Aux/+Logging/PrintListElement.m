function PrintListElement(varName, formatSpec, varToPrint)
    fprintf(['* ', varName, ': ']);
    nEl = numel(varToPrint);
    if nEl > 1
        fprintf('[ ');
    end
    for i = 1 : nEl
        fprintf(formatSpec, varToPrint(i));
        if i ~= nEl
            fprintf(', ');
        end
    end
    if nEl > 1
        fprintf(' ]');
    end
    fprintf('\n');
end
