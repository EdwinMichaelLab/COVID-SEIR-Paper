function [] = Master(c)
	global countyid 
	countyid = c
	%ids =  [3, 6, 15, 19, 28, 43, 48, 50, 51, 52, 53]
	%ids =  [50, 51];
    %if ~ismember(c, ids)
    %    exit
    %end
	pause(10*countyid);
	%MainCounties
	Main1
	Main2
	Main3
	Main4
	Main5
	Main6
end
