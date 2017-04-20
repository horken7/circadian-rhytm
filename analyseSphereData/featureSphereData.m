function featureSphereData (a,t)
    for i=1:size(a,2) % 3 times for x,y,z coordinates (to be sure)
        t(isnan(a(:,i))) = []; % removes values where NaN in data 
        a(isnan(a(:,i)),:) = []; % removes colums with NaN values
    end


end