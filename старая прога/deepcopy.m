function return_obj = deepcopy(object)
% >> a = 1;
% >> b = deepcopy(a);
% >> a == b
% ans =
%   1
% >> a = 2;
% >> b 
% b = 
%    1
% >> a = struct('a','b','c','d')
% a = 
%    a: 'b'
%    c: 'd'
% >> b = deepcopy(a);
% >> a.a = 'z';
% >> isequal(a,b)
% ans =
%     0
% >> a = ones(5,1);
% >> b = deepcopy(a);
% >> a(3) = 0;
% >> isequal(a,b)
% ans =
%     0
%
%
% Returns a deepcopy of object;
% If the object is structure or handle, deepcopies its members too;
% Input:
%       object - a matlab object
% Output: 
%       return_obj - a deepcopy of object






if isa(object,'handle')
    return_obj = feval(class(object));
    
    % Copy all non-hidden properties.
    p = properties(object);
    for i = 1:length(p)
        return_obj.(p{i}) = object.(p{i});
    end
else
    return_obj = object;
end

end