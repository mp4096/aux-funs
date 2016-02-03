function PrintTitle(titleString, level)
    levelMark = ones(level, 1) * '#';
    fprintf([levelMark, ' ', titleString, '\n']);
end
