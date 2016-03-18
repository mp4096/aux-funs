function PrintTitle(titleString, level)
    levelMark = ones(1, level) * '#';
    fprintf([levelMark, ' ', titleString, '\n']);
end
