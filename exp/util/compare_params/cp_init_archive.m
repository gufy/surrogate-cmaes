function [ Arch ] = cp_init_archive( C )
% cp_init_archive( C )
%   C is element from cmaes_out

Arch = Archive(C.dim);

for gen = 1:length(C.generationStarts)
    idx = C.generations == gen;
    Arch = Arch.save(C.arxvalids(:, idx)', C.fvalues(idx)', gen);
end

end

