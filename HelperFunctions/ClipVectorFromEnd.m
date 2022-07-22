function [ClippedV] = ClipVectorFromEnd(V)
    ClippedV = [];
for i=length(V):-1:1
    if V(i)~=0
        ClippedV=V(1:i);
        break;
    end
end
end