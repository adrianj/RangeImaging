% function cu = cleverUnwrap(d,tol)
% Smarter version of unwrap.
% sorts our massive jumps of size 'tol' to bring them back in line with the
% first data of the series. Works only for 1D or 2D arrays, and along 1st
% dimension.
function cu = cleverUnwrap(d,tol)

%load('DISTANCE_DATA_40MHZ_NOISEY.mat');
%d = DISTANCE_DATA_40MHZ_NOISEY;
%tol = 3750;

frame_one = median(d,2);
cu = zeros(size(d));
for i = 1:length(frame_one)
    l = d(i,:);
    l(l>frame_one(i)+tol/2) = l(l>frame_one(i)+tol/2) - tol;
    l(l<frame_one(i)-tol/2) = l(l<frame_one(i)-tol/2) + tol;
    cu(i,:) = l;
end
