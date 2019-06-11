%original Source : https://www.mathworks.com/matlabcentral/answers/350752-texture-feature-extraction-from-a-mammography-image
% Use the Extracted ROI named as "ROI" in the uploaded Images
% Use the following angles "offset":(0,45,90,135)

clc;
clear all    

%model = "GANai_original";
model = "reverse_MSGAN";
path_1 = "E:\GANai\selim\"+ model+ "\bl57_05mm_d3\";
% path_2 = "E:\GANai\selim\reverse_MSGAN\bl57_05mm_d3\";


files_1 = dir (strcat(path_1,'*.png'));
%files_2 = dir (strcat(path_2,'*.png'));

L = length (files_1);
fake = [];
real = [];
fake_dwt = [];
real_dwt = [];
data =[];
for i=1:L
    if contains(files_1(i).name,"output")
        data = matrics(imread(strcat(path_1,files_1(i).name))); 
        fake = [fake;data];

        data = dwt_texture(strcat(path_1,files_1(i).name)); 
        fake_dwt = [fake_dwt;data];
    end
    if contains(files_1(i).name,"target")
        data = matrics(imread(strcat(path_1,files_1(i).name))); 
        real = [real;data];

        data = dwt_texture(strcat(path_1,files_1(i).name)); 
        real_dwt = [real_dwt;data];
    end
end
fake_summary = abs((fake - real))./real;
summary = [mean(fake_summary); std(fake_summary)];

fake_dwt_summary = abs((fake_dwt - real_dwt))./real_dwt;
summary_dwt = [mean(fake_dwt_summary); std(fake_dwt_summary)];

header ={"mean","std","contrast","correlation","energy","entropy","homoginity","kertosis","skwness"};

data = [summary ; summary_dwt];
csvwrite(model+'.txt',data);

function f = matrics(img)
    ROI = rgb2gray(img);
    GLCM = graycomatrix(ROI,'Offset',[0 1;-1 1;-1 0;-1 -1]);
    % Calculate the four built-in MATLAB features
    stats=graycoprops(GLCM,{'Contrast','Homogeneity','Correlation','Energy'});
    contrast=(stats.Contrast);  
    en=(stats.Energy);
    co=(stats.Correlation);
    hom=(stats.Homogeneity);
    entro = entropy(ROI);
    %dissimilarity = 
    I1 = im2double(ROI);
    skw = skewness(I1(:));

    kert = kurtosis(I1(:));

    % Calculate mean and standard deviation
    m=mean(mean(ROI));    
    s=std2((ROI));
    % The first feature vector 
    f=[m s mean(contrast) mean(co) mean(en) entro mean(hom) kert skw];
end

function f = dwt_texture(img)
    myimage=imread(img);
    image = myimage;
    wavename = 'haar';
    [cA,cH,cV,cD] = dwt2(im2double(image),wavename);
    Level1 = [cA,cH,cV,cD];
    [cAA,cAH,cAV,cAD] = dwt2(cA,wavename); % Recompute Wavelet of Approximation Coefs.
    Level2=[cAA,cAH; cAV,cAD]; %contacinat

    [cAAA,cAAH,cAAV,cAAD] = dwt2(cAA,wavename); % Recompute Wavelet of Approximation Coefs.
    Level3=[cAAA,cAAH;cAAV,cAAD]; %contacinat

    im3 = [Level3,cAH; cAV,cAD];
    Level3_img = [im3,cH; cV,cD];

   % imshow(Level3_img, 'Colormap', gray); %2 level


    %% calculating features in wavelet domain
            ROI = rgb2gray(Level3_img);
            GLCM = graycomatrix(ROI,'Offset',[0 1;-1 1;-1 0;-1 -1]);
            % Calculate the four built-in MATLAB features
            stats=graycoprops(GLCM,{'Contrast','Homogeneity','Correlation','Energy'});
            contrast=(stats.Contrast);  
            en=(stats.Energy);
            co=(stats.Correlation);
            hom=(stats.Homogeneity);
            entro = entropy(ROI);

            % Calculate mean and standard deviation
            m=mean(mean(ROI));    
            s=std2((ROI));
     f  =  [m s mean(contrast) mean(co) mean(en) entro mean(hom)];     
     f = matrics(Level3_img);
end   