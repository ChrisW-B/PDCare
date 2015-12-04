arg_list = argv ();
filename = arg_list{1};
SR = 64;            % Sample rate in herz
stepSize=32;        % Step size in samples
offDelay=2;         % Evaluation delay in seconds: tolerates delay after detecting
onDelay=2;          % Evaluation delay in seconds: tolerates delay before detecting

% Parameters to optimize per sensor placement/orientation and subject
%TH.freeze  =  3 ;
% subject [1 3 7 8 10] threshold 3
TH.freeze  =  [3 1.5 3 1.5 1.5 1.5 3 3 1.5 3];
%TH.freeze  =  [1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5];
TH.power   = 2.^ 12 ;
%TH.power   = 2.^ 11.5 ;


data = importdata(filename);
resrun=[0 0 0 0 0];
%%%%%%%%%%%%%%%%%%
%Temp for testing
isensor = 0;
iaxis=1;
isubject=1;
%%%%%%%%%%%%%%%%%%%
newData = [];

dataSize = size(data);
dataSize
counter = 1;
i = 1;
while i <= dataSize(1)
	j = 1;
	if(i+1<dataSize(1))
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
 % res = x_fi(data(:,2+0*3+1),SR,stepSize);
% Extension of Baechlin to handle low-enery situations
% (e.g. standing)
res.quot(res.sum < TH.power) = 0;

% Classification
lframe = (res.quot>TH.freeze(2))';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We do not want to compute performance on the "non experiment" part, 
% e.g. when the sensors are attached on body or the user is not yet
% doing the task. 
% Therefore we remove the non-experiment parts, which correspond
% to label '0'.
% After transformation, there are only frames corresponding to the
% experiment with label 0=no freeze, 1=freeze
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

printf('%1.0f\n', lframe);


