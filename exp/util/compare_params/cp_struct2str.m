function [ string_out ] = cp_struct2str( struct_in, delimiter )
% cp_struct2str( struct_in, delimiter )
%   Converts a struct into a string.
%
%   Parameters
%       struct_in:      a structure to be converted into string
%       delimiter:      a delimiter used, default ',' (a comma)
%
%   Returns
%       string_out:     a result string
%
%   Example
%       >> struct2str( struct('method', 'rbf-nn', 'dataset', 'f16-10d-5000') )
%       ans =
%       method=rbf-nn,dataset=f16-10d-5000
%
%       >> struct2str( struct('method', 'rbf-nn', 'dataset', 'f16-10d-5000'), '&' )
%       ans =
%       method=rbf-nn&dataset=f16-10d-5000
%


if nargin < 2
    delimiter = ',';
end

fields = fieldnames(struct_in);
string_out = '';
for J = 1:numel(fields)
    key = fields{J};
    if length(struct_in) > 1
        value = '[';
        for I = 1:length(struct_in)
            if I > 1
                value = [value ','];
            end
            value = [value cp_struct2str(struct_in(I))];
        end
        value = [value ']'];
    else
        if isstruct(struct_in.(key))
            value = urlencode(cp_struct2str(struct_in.(key), '='));
        else
            if ischar(struct_in.(key))
                value = struct_in.(key);
            else
                if isa(struct_in.(key), 'function_handle')
                    value = func2str(struct_in.(key));
                else
                    value = mat2str(struct_in.(key));
                end
            end
            value = urlencode(value);
        end
    end
    
    string_out = [string_out, key, '=', value];
    
    if J < numel(fields) 
        string_out = [string_out, delimiter];
    end
end

end

