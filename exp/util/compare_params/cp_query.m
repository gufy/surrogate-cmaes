function [ result ] = cp_query( query, url )

if nargin < 2
    url = 'http://vojtechkopal.cz/regressions/query.php';
end

query_result = urlread([url, '?', cp_struct2str(query, '&')]);
n = 9;
format_str = '%d%s%s%d%d%d%d%f%f';
delimiter = ',';

C = textscan(query_result, format_str, 'Delimiter', delimiter,'EndOfLine','\n');
result = cell2struct(C,{'fun','covfun','covhyp','gen','numtrains','trainrange','testgen','mse','kendall'},2);

end

