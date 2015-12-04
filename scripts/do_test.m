arg_list = argv ();
filename = arg_list{1};
SR = 64;            % Sample rate in herz
stepSize=32;        % Step size in samples
offDelay=2;         % Evaluation delay in seconds: tolerates delay after detecting
onDelay=2;          % Evaluation delay in seconds: tolerates delay before detecting

% Parameters to optimize per sensor placement/orientation and subject
TH.freeze  =  1.5;
% TH.power   = 2.^ 12 ;
TH.power   = 2.^ 11.5 ;

% Imports data from a csv file located in the first argument
data = importdata(filename);

%array to hold data converted into complex numbers
newData = [];

dataSize = size(data); %2D array thats the size of the original data file

counter = 1;
i = 1;
%for loop to merge the data back into complex numbers
while i <= dataSize(1)
	j = 1;
	if i+1 <= dataSize(1)
		while j <= dataSize(2)
			newData(counter, j) = complex(data(i, j), data(i+1, j));
			j = j + 1;
		end
	end
	counter = counter + 1;
	i = i + 2;
end

% Moore's algorithm
res = givenFFT_x_fi(newData,SR,stepSize);

% Extension of Baechlin to handle low-enery situations
% (e.g. standing)
res.quot(res.sum < TH.power) = 0;

% Classification
lframe = (res.quot>TH.freeze)';

printf('%1.0f\n', lframe);
