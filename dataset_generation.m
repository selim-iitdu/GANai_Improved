% Author @ Md Selim
% Date :: 07/03/2019
% Version :: 1.0
% 
% Input  :: Two image directeroy from source and target DICOM images
% Output :: 512X256 image pathch where half of the image is source image and half of is the target 
% 
% Description :: This program will read dicom files and create 512X215 image patches. The program randomly hover the source image and crop 256X256 area from the source 
% and target DICOM files and concat it togather to make the dataset.


sources_files=dir('E:\GANai\data\from_CD\Selim_data\patient 1\data\7583585\w9988612\*.dcm');
target_files=dir('E:\GANai\data\from_CD\Selim_data\patient 1\data\7583585\w9988612\*.dcm');

mkdir 'E:\GANai\data\from_CD\Selim_data\patient 1\data\7583585\w9988612_patch\';
out_files =dir('E:\GANai\data\from_CD\Selim_data\patient 1\data\7583585\w9988612_patch\*.*');


for k=3:length(sources_files)
    [X, ] = dicomread(fullfile(sources_files(k).folder, sources_files(k).name));
    [Y, ] = dicomread(fullfile(target_files(k).folder, target_files(k).name));
    %[n m] = size(X);
    n = 512;
    m = 512;
    L = 256;
    
    small_patches = 15;
    Large_patches = 5;
    
    total_pixet = 512*512;
    % Crop
    for p=1:small_patches                % image from small patches
        size = randi(255);
        if size < 10
            size = size + 10;
        end
        %size = 255;
        start = randi(n-size+1)+(0:size-1);
        stop = randi(m-size+1)+(0:size-1);
        s_crop = X(start,stop);
        [count, hist] = imhist(s_crop);
        black = sum(count(1:2))/total_pixet;
        white = sum(count(240:256))/total_pixet;
        
        if black+white < 0.2
            disp('valid data')
            t_crop = Y(start,stop);
            
            for i = 1:1
                %random rotation
                angle = randi(360);
                
                s_crop_r = rotatetor(X, angle);
                t_crop_r = rotatetor(Y, angle);
                
                s_crop_r = s_crop_r(start,stop);
                t_crop_r = t_crop_r(start,stop);
                
                
                [count, hist] = imhist(s_crop_r);
                black = sum(count(1:5))/total_pixet;
                white = sum(count(250:256))/total_pixet;
        
                if black+white < 0.2
                    I = mat2gray([s_crop_r,t_crop_r]);
                    I = imresize(I,[256 512]);
                    imwrite(I, fullfile(out_files(1).folder, target_files(k).name+"_patch_"+p+"_rotate_"+i+".png"));
                end
                
                %Random shift
                shift_pos = randi(size-1);
                
                direction = randi(100);
                
                if mod(direction, 2) == 0 %left rotation
                    s_crop_shift = [s_crop(: , shift_pos:size), s_crop(: , 1:shift_pos-1)]; 
                    t_crop_shift = [t_crop(: , shift_pos:size), t_crop(: , 1:shift_pos-1)]; 
                else % right rotation
                    s_crop_shift = [s_crop(shift_pos:size, :); s_crop( 1:shift_pos-1, :)]; 
                    t_crop_shift = [t_crop( shift_pos:size ,:); t_crop(1:shift_pos-1, :)]; 
                end
                
                
                I = mat2gray([s_crop_shift,t_crop_shift]);
                I = imresize(I,[256 512]);
                imwrite(I, fullfile(out_files(1).folder, target_files(k).name+"_patch_"+p+"_shift_"+i+".png"));
                
                %random shift + rotate
                angle = randi(360); %rotate
                
                s_crop_r = rotatetor(X, angle);
                t_crop_r = rotatetor(Y, angle);
                
                s_crop_r = s_crop_r(start,stop);
                t_crop_r = t_crop_r(start,stop);
                
                shift_pos = randi(size-1); %shift on rotate image
                
                s_crop_rotate_shift = [s_crop_r(: , shift_pos:size), s_crop_r(: , 1:shift_pos-1)]; 
                t_crop_rotate_shift = [t_crop_r(: , shift_pos:size), t_crop_r(: , 1:shift_pos-1)];
                
                I = mat2gray([s_crop_rotate_shift,t_crop_rotate_shift]);
                I = imresize(I,[256 512]);
                imwrite(I, fullfile(out_files(1).folder, target_files(k).name+"_patch_"+p+"_rotate_shift_"+i+".png"));
                
            end
            
        end
    end

    for p=1:Large_patches                % image from large patches
        size = randi(500);
        if size < 256
            size = size + 256;
        end
        %size = 255;
        start = randi(n-size+1)+(0:size-1);
        stop = randi(m-size+1)+(0:size-1);
        s_crop = X(start,stop);
        [count, hist] = imhist(s_crop);
        black = sum(count(1:2))/total_pixet;
        white = sum(count(240:256))/total_pixet;
        
        if black+white <= 0.2
            disp('valid data')
            t_crop = Y(start,stop);
            
            for i = 1:1
                %random rotation
                angle = randi(360);
                
                s_crop_r = rotatetor(X, angle);
                t_crop_r = rotatetor(Y, angle);
                
                s_crop_r = s_crop_r(start,stop);
                t_crop_r = t_crop_r(start,stop);
                
                
                [count, hist] = imhist(s_crop_r);
                black = sum(count(1:2))/total_pixet;
                white = sum(count(240:256))/total_pixet;
        
                if black+white < 0.2
                    I = mat2gray([s_crop_r,t_crop_r]);
                    I = imresize(I,[256 512]);
                    imwrite(I, fullfile(out_files(1).folder, target_files(k).name+"_patch_"+p+"_rotate_"+i+".png"));
                end
                
                %Random shift
                shift_pos = randi(size-1);
                
                direction = randi(100);
                
                if mod(direction, 2) == 0 %left rotation
                    s_crop_shift = [s_crop(: , shift_pos:size), s_crop(: , 1:shift_pos-1)]; 
                    t_crop_shift = [t_crop(: , shift_pos:size), t_crop(: , 1:shift_pos-1)]; 
                else % right rotation
                    s_crop_shift = [s_crop(shift_pos:size, :); s_crop( 1:shift_pos-1, :)]; 
                    t_crop_shift = [t_crop( shift_pos:size ,:); t_crop(1:shift_pos-1, :)]; 
                end
                
                
                I = mat2gray([s_crop_shift,t_crop_shift]);
                I = imresize(I,[256 512]);
                imwrite(I, fullfile(out_files(1).folder, target_files(k).name+"_patch_"+p+"_shift_"+i+".png"));
                
                %random shift + rotate
                angle = randi(360); %rotate
                
                s_crop_r = rotatetor(X, angle);
                t_crop_r = rotatetor(Y, angle);
                
                s_crop_r = s_crop_r(start,stop);
                t_crop_r = t_crop_r(start,stop);
                
                shift_pos = randi(size-1); %shift on rotate image
                
                s_crop_rotate_shift = [s_crop_r(: , shift_pos:size), s_crop_r(: , 1:shift_pos-1)]; 
                t_crop_rotate_shift = [t_crop_r(: , shift_pos:size), t_crop_r(: , 1:shift_pos-1)];
                
                
                [count, hist] = imhist(s_crop_rotate_shift);
                black = sum(count(1:50))/total_pixet;
                white = sum(count(200:256))/total_pixet;
        
                if black+white < 0.2
                    I = mat2gray([s_crop_rotate_shift,t_crop_rotate_shift]);
                    I = imresize(I,[256 512]);
                    imwrite(I, fullfile(out_files(1).folder, target_files(k).name+"_patch_"+p+"_rotate_shift_"+i+".png"));
                end
                       
                
            end
            
        end
    end    
 
end


function f = rotatetor(img, angle)
    f = imrotate(img,angle);
end 
