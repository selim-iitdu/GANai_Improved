clc;
clear all

mkdir E:\GANai\data\Lung_cancer_raw_data\NON_DICOM_ANONYM_FILES_p1\test_result easy
mkdir E:\GANai\data\Lung_cancer_raw_data\NON_DICOM_ANONYM_FILES_p1\test_result hard
mkdir E:\GANai\data\Lung_cancer_raw_data\NON_DICOM_ANONYM_FILES_p1\test_result average

easy_folder = 'E:\GANai\data\Lung_cancer_raw_data\NON_DICOM_ANONYM_FILES_p1\test_result\easy';
hard_folder = 'E:\GANai\data\Lung_cancer_raw_data\NON_DICOM_ANONYM_FILES_p1\test_result\hard';
avg_folder = 'E:\GANai\data\Lung_cancer_raw_data\NON_DICOM_ANONYM_FILES_p1\test_result\average';


path = dir('E:\GANai\data\Lung_cancer_raw_data\NON_DICOM_ANONYM_FILES_p1\test_result\images\*.png');

result = [];
file = [];
j=1;

for i=1:3:length(path)
    fake = fullfile(path(i+1).folder, path(i+1).name);
    real = fullfile(path(i+2).folder, path(i+2).name);
    
    im1 = imread(fake);
    im2 = imread(real);
    im_1 = rgb2gray(im1);
    im_2= rgb2gray(im2);
    
    KLDV = kldiv( im_1, im_2 );
    
    u = reshape(im_1,1,[]);
    v = reshape(im_2,1,[]) ;
    
    NMI = compute_nmi ( u, v );
    
    CS = 1 - pdist([u;v],'cosine');
    
    result(j,1) = CS;
    result(j,2) = NMI;
    result(j,3) = KLDV;
    result(j,4) = 0;
    result(j,5) = i;
    
    j= j+1;
end

result(:,1:3) =  zscore(result(:,1:3));
result(:,4) = abs(result(:,1)) + abs(result(:,2)) + abs(result(:,3));

result=sortrows(result,4);



csvwrite('zscore.csv', result);


for i = 1:length(result)-1
    filename = 'file*';
    source = fullfile(path(result(i,5)).folder, path(result(i,5)).name);
    target = fullfile(path(result(i,5)+2).folder, path(result(i,5)+2).name);
    img1 = imread(source);
    img2 = imread(target);
    
    combine= [img1, img2];
    
    if i<length(result)/3
        imwrite(combine, fullfile(easy_folder, path(result(i,5)).name));
        %destination = fullfile(easy_folder,path(result(i,5)).name);
    elseif i > (2*length(result)/3)
        imwrite(combine, fullfile(hard_folder, path(result(i,5)).name));
        %destination = fullfile(hard_folder,path(result(i,5)).name);
    else
        imwrite(combine, fullfile(avg_folder, path(result(i,5)).name));
        %destination = fullfile(avg_folder,path(result(i,5)).name);
    end
    
    %imwrite(combine, fullfile(out_files(1).folder, target_files(k).name+"_patch_"+p+"_rotate_"+i+".png"));
    %copyfile(source,combine)
end


%     im1 = imread('f.png');
%     im2 = imread('r.png');
%     im_1 = rgb2gray(im1);
%     im_2= rgb2gray(im2);
%
%     KLDV = kldiv( im_1, im_2 );
%
%     %https://github.com/areslp/matlab/blob/master/code_cospectral/compute_nmi.m
%     NMI = compute_nmi ( im_1, im_2 );
%
%
%
%     u = reshape(im_1,1,[]);
%     v = reshape(im_2,1,[]) ;
%
%     NMI = compute_nmi ( u, v );
%
%     CS = 1 - pdist([u;v],'cosine');
%
%     z = zscore([KLDV NMI CS]);
%
function d_kl = kldiv( im_1, im_2 )
%This function is used to compute the Kullback?Leibler divergence of two
%images
%   Kullback?Leibler divergence defines as following:
%   D_kl(P||Q) = sum(P(i) log(P(i)/Q(i)))
%   Q(i)=0 implies P(i)=0
%   P(i)=0, the contribution of the i-th term interpreted as zero
%
%   Input:
%       im_1, im_2  two images
%   Output:
%       d_kl    the Kullback?Leibler divergence of the two images


% assert two input has same shape
[r, c] = size(im_1);

assert(size(im_2,1) == r, 'two images having different shape')
assert(size(im_2,2) == c, 'two images having different shape')

% get the probability of each pixel value in two image
min_value = min(min(im_1(:)), min(im_2(:)));    % min pixel value amoung two images
max_value = max(max(im_1(:)), max(im_2(:)));    % max pixel value amoung two images


num_of_value = abs(max_value-min_value);
if isnan(num_of_value)
    num_of_value=0;
end

p_list_1 = zeros(1, num_of_value);   % list used to store probability of image 1
p_list_2 = zeros(1, num_of_value);

cur_value = min_value;
for i=1:num_of_value
    %i
    count_1 = 0;
    count_2 = 0;
    p_1 = 0;
    p_2 = 0;
    for m=1:r
        for n=1:c
            if im_1(m,n) == cur_value
                count_1=count_1+1;      % count number of cur_value in im_1
            end
            if im_2(m,n) == cur_value
                count_2=count_2+1;      % count number of cur_value in im_1
            end
        end
    end
    
    p1 = count_1/(r*c);
    p2 = count_2/(r*c);
    
    p_list_1(1,i) = p1;
    p_list_2(1,i) = p2;
    
    cur_value = cur_value+1;
end

% computer the kl_divergence
d_kl = 0;
for i=1:num_of_value
    p_1 = p_list_1(1,i);
    p_2 = p_list_2(1,i);
    
    if p_1~=0 && p_2~=0
        d = p_1*log(p_1/p_2);
        d_kl = d_kl+d;
        
    end
end

if num_of_value == 0
    d_kl=NaN;
end

end






function nmi = compute_nmi (T, H)

N = length(T);
classes = unique(T);
clusters = unique(H);
num_class = length(classes);
num_clust = length(clusters);

%%compute number of points in each class
for j=1:num_class
    index_class = (T(:)==classes(j));
    D(j) = sum(index_class);
end

%%mutual information
mi = 0;
A = zeros(num_clust, num_class);
avgent = 0;
for i=1:num_clust
    %number of points in cluster 'i'
    index_clust = (H(:)==clusters(i));
    B(i) = sum(index_clust);
    for j=1:num_class
        index_class = (T(:)==classes(j));
        %%compute number of points in class 'j' that end up in cluster 'i'
        A(i,j) = sum(index_class.*index_clust);
        if (A(i,j) ~= 0)
            miarr(i,j) = A(i,j)/N * log2 (N*A(i,j)/(B(i)*D(j)));
            %%average entropy calculation
            avgent = avgent - (B(i)/N) * (A(i,j)/B(i)) * log2 (A(i,j)/B(i));
        else
            miarr(i,j) = 0;
        end
        mi = mi + miarr(i,j);
        
        
        
    end
end

%%class entropy
class_ent = 0;
for i=1:num_class
    class_ent = class_ent + D(i)/N * log2(N/D(i));
end

%%clustering entropy
clust_ent = 0;
for i=1:num_clust
    clust_ent = clust_ent + B(i)/N * log2(N/B(i));
end

%%normalized mutual information
nmi = 2*mi / (clust_ent + class_ent);

end
