clc;
clear;
close all;


%Getting the video
vid=VideoReader('Stephan.mp4');

errorsRange= 0.0001:0.01:0.2;
 errorProbability=[];
%Getting the number of frames in the vedio
Frames_num = vid.NumFrames;
frame_rate = vid.FrameRate;

 decodedFrames={};
 errorFrames={};
 


% create a VideoWriter object with a specified filename and frame rate
% Wecould change the output vedio path
outputVideo = VideoWriter('output3','Uncompressed AVI');


%Creating the trellis (change the numbers however u like :))

trellis1 = poly2trellis(7,[135 135 147 163]);
trellis2=poly2trellis(7, [133 177]);
trellis3 = poly2trellis(7,[133 145 175])
trellis4 = poly2trellis(4,[15 6 15 6 15 17])

%defining the probability of error (also change it however u like :))
pe=0.1;
pe2=0.0001;

for j=1:1:size(errorsRange,2)
    

counter=0;

%getting components for each color as binary
for i=1:Frames_num
    frame = read(vid, i);
   
   
%      %getting  red components 
     R = frame(:,:,1);
%      %getting  green components
     G = frame(:,:,2);
%      %getting  blue components
     B = frame(:,:,3);
% 
% 


 R=reshape(R,1,[]); %we reshape to put the red as a stream of 1 row 
 G=reshape(G,1,[]); %we reshape to put the green as a stream of 1 row 
 B=reshape(B,1,[]); %we reshape to put the blue as a stream of 1 row 

 R=double(R);%convert red component to decimal 
 G=double(G);%convert green component to decimal 
 B=double(B);%convert blue component to decimal 

 Rbin=de2bi(R,8);%convert red decimal to binary in 8 bits
 Gbin=de2bi(G,8);%convert green decimal to binary in 8 bits
 Bbin=de2bi(B,8);%convert blue decimal to binary in 8 bits
 


%this is for the plots (encoding,error,decoding)
%Red 
decodedRed1=transmit_channel_coding(Rbin,trellis4,errorsRange(j));


%Green
decodedGreen1=transmit_channel_coding(Gbin,trellis4,errorsRange(j));

%Blue
decodedBlue1=transmit_channel_coding(Bbin,trellis4,errorsRange(j));


%getting the number of bits in error after decoding

counter=counter+sum(sum(xor(decodedRed1,Rbin)))+sum(sum(xor(decodedGreen1,Gbin)))+sum(sum(xor(decodedBlue1,Bbin)));



% we do not run the code for the videos and graphs together we comment some
% lines.

%For the videos

%decoding with error 0.1 and error 0.0001 with channel codding

 decodedRed  =transmit_channel_coding(Rbin,trellis1,0.0001);
 decodedGreen=transmit_channel_coding(Gbin,trellis1,0.0001);
 decodedBlue =transmit_channel_coding(Bbin,trellis1,0.0001);



%0.1 error and 0.0001 without channel codding
 
  errorRed=introduceBitErrors(0.1,Rbin);
  errorGreen=introduceBitErrors(0.1,Gbin);
  errorBlue=introduceBitErrors(0.1,Bbin);

 
 Rd=bi2de(decodedRed);%  return the Red bits to dec
 Gd=bi2de(decodedGreen);%return the Green bits to dec
 Bd=bi2de(decodedBlue);%return the Blue bits to dec
 
 Ru=uint8(Rd); %  return the Red dec to uint8
 Gu=uint8(Gd);%  return the green dec to uint8
 Bu=uint8(Bd);%  return the blue dec to uint8

 %reshaping the colors to be the size of the original frame
 Rframe=reshape(Ru,size(frame,1),size(frame,2),[]);
 Gframe=reshape(Gu,size(frame,1),size(frame,2),[]);
 Bframe=reshape(Bu,size(frame,1),size(frame,2),[]);
 



% concatenate the color components to form the decoded frame

decodedFrame = cat(3, Rframe,Gframe, Bframe);%with channel codding
errorFrame=cat(3, Rframe,Gframe, Bframe);%no Channel codding

%collecting all frames in a cell Arrey
errorFrames=cat(2,errorFrames,errorFrame);
decodedFrames=cat(2,decodedFrames,decodedFrame);
 
  



end

%getting the probability of error
p=counter/(Frames_num*(numel(Rbin)*3));
errorProbability=[errorProbability,p];
%getting the rates of the codes (trellis number could be changed)
rate=numel(Rbin)/numel(toEncode(Rbin,trellis4))

end
% open the video for writing
  open(outputVideo);
%creating the output vedio
  for i=1:Frames_num
      f=decodedFrames{i};
  writeVideo(outputVideo, f);
  end
  
 
  close(outputVideo);


% plot error probability vs. error range using different trellises

figure;
plot(errorsRange, errorProbability);
xlabel('Error Range');
ylabel('Error Probability');
title('Error Probability vs. Error Range');















%Here starts the functions that encodes, decodes and puts the error


%1)Getting the Trellis with different rates and then encoding
function [encodedData] = toEncode(data2,trellis)
data= reshape(data2, [], 1);
encodedData=convenc(data,trellis);
encodedData=reshape(encodedData,size(data2,1),[]);
end



%error function

function y = introduceBitErrors(p, x)
    % x: input binary matrix
    % p: probability of bit error
    % y: output binary matrix with errors
    
    r = rand(size(x)); % generate random matrix
    y = x; % initialize output matrix
    
    % compare random matrix with error probability matrix and flip bits
    y(r < p) = 1 - y(r < p);
end



%3)Decoding using a specific trellis
function [decodedData] = toDecode(data2,trellis)
%number_of_bits=numel(encodedData);
data= reshape(data2, [], 1);
decodedData =vitdec(data,trellis,50,'trunc','hard');
decodedData=reshape(decodedData,size(data2,1),[]);
end

%4)Function that encodes, decodes and puts error
function[decodedData]=transmit_channel_coding(data,trellis,error)
encodedData=toEncode(data,trellis);
errorData=introduceBitErrors(error,encodedData);
decodedData= toDecode(errorData,trellis);
end