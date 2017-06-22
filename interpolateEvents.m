function idata = interpolateEvents(x, data, events, addsamples)

valid = true(size(x));
events(:,1) = events(:,1)-addsamples;
events(:,2) = events(:,2)+addsamples;

valid(isnan(data)) = false; % also set Nan to invalid

for i = 1:size(events,1)
    valid(find(x==events(i,1)):find(x==events(i,2))) = false; % invalid
end

ipoints = interp1(find(valid), data(valid,:), find(~valid),  'linear');

idata = data;

idata(~valid,:) = ipoints;

end