clear all;
detector = posenet.PoseEstimator; 

player = vision.DeployableVideoPlayer; 
I = zeros(256,192,3,'uint8'); 

arr = {uint8(size(I)),uint8(size(I))}; 

player(I); 
angleArr(2,2) = 0;

for i =1:2
    flag = 1; 
    cam = webcam; 
while flag == 1
    I = snapshot(cam);
    
    % Input size of 256x192 
    Iinresize = imresize(I,[256 nan]);
    Itmp = Iinresize(:,(size(Iinresize,2)-192)/2:(size(Iinresize,2)-192)/2+192-1,:);
    Icrop = Itmp(1:256,1:192,1:3);

    heatmaps = detector.predict(Icrop);
    keypoints = detector.heatmaps2Keypoints(heatmaps);
  
    Iout = detector.visualizeKeyPoints(Icrop,keypoints);
    player(Iout);
   
    rightAnkle =  keypoints(17,1:2);
    leftAnkle = keypoints(16,1:2);
    rightHip  = keypoints(13,1:2);
    leftHip = keypoints(12,1:2);
    rightKnee = keypoints(15,1:2);
    leftKnee = keypoints(14,1:2);
    
    
    x10 = rightHip(1) - rightKnee(1);
    y10 = rightHip(2) - rightKnee(2);
    x20 = rightAnkle(1) - rightKnee(1);
    y20 = rightAnkle(2) - rightKnee(2);
    x11 = leftKnee(1) - leftHip(1);
    y11 = abs(leftKnee(2) - leftHip(2));
    x22 = leftKnee(1) - leftAnkle(1);
    y22 = abs(leftKnee(2) - leftAnkle(2));
    
    
    angle1 = atan2(abs(x10*y20-x20*y10),x10*y10+x20*y20) *180/pi;
    
    
    angle2 = (atan2(abs(x11*y22-x22*y11),x11*y11+x22*y22) *180/pi);
    
    angleArr(i,1) = angle1;
    angleArr(i,2) = angle2;

    arr{1,i} = Iout;
    
    if ~isOpen(player)
       flag = 2; 
      release(player); 
    end

end

clear cam
end

sprintf('The angle at the right knee when squatting is %g \n', angleArr(2,1))
sprintf('The angle at the left knee when squatting is %g \n', angleArr(2,2))
if angleArr(2,1) > 90
    warning('Right knee may have muscular imbalances');
end

if angleArr(2,2) > 90
    warning('Left knee may have muscular imbalances');
    
end

A = cell2mat(arr(1,1)); 
B = cell2mat(arr(1,2));
str1 = sprintf('Angle of right knee: %g degrees', angleArr(1,1));
str2 = sprintf('Angle of left knee: %g degrees', angleArr(1,2));

subplot(1,2,1)

image(A)
title('Standing Position');
subplot(1,2,2)

image(B)
title('Squat Position Right Knee Angle ', num2str(angleArr(1,1)));