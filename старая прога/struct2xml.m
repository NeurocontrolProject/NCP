

function xml = struct2xml(v,level)

%
% Transforms a struct or struct array into an XML string
%
% v = struct variable containing fields of type char or numeric
%
if nargin < 2
    level = -1;
end
xml = [];

% New line character:
nl = char(13);
sp = '';
% Use nl = '' to remove new line characters.

names = fieldnames(v);
for n = 1:length(names)
    a = getfield(v, names{n});

    if isstruct(a)
        level = level + 1;
        % If it is a struct, recursive call
        Nitems = length(a);
        % loop if it is a struct array
        for i = 1:Nitems
            if level ==0
                tabs = '';
            else
                tabs = repmat(char(9),1,level);
            end
            xml = [xml tabs '<' names{n} '>' nl struct2xml(a(i),level)  tabs '</' names{n} '>' nl];
        end
        level = level-1;
    else
        % write field contents:
        if iscell(a); Nitems = length(a); else Nitems=1; a={a};end
        for i = 1:Nitems
            
            xml = [xml repmat(char(9),1,level+1) '<' names{n} '>' sp];
            if ischar(a{i})
                xml = [xml a{i} sp];
            else
                xml = [xml num2str(a{i}) sp];
            end
            xml = [xml '</' names{n} '>' nl];
        end
    end
end

