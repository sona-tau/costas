% TODO: documentation

n = str2num(fgetl(stdin));
perm = str2num(fgetl(stdin));

function result = iscostas(perm)
    n = length(perm);
    result = length(unique(perm)) == n;
    if result
        for k = 1:n-1
            diffs = perm(k+1:n) - perm(1:n-k);
            if length(unique(diffs)) ~= length(diffs)
                result = false;
                return;
            end
        end
    end
end

if iscostas(perm)
    disp(1)
else
    disp(0)
end
