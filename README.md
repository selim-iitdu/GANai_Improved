# GANai_Improved

This project is an improved version of our previous CT image standaddization work. Here we want to work on our existing GAN model by controlling latent space with 
and adding penalty fo the images generated with distance distribution from the distribution of the target images.

# Update on 6/11/2019
* We have developed a model with the similar idea with mode collapse GAN. But here we want to minimize the distance between the latent distribution of the source fake mage and the target image, e.g.,

![equation](http://latex.codecogs.com/gif.latex?min%20%5Cfrac%7B%7Cfake_z%20-%20traget_z%7C%7D%7Btraget_z%7D)

* A MATLAB program is added in the repository which can generate dataset from DICOM image to train the model.
* A MATLAB programis aded to calculate texture feature of two features. In our previous work we have done texture comparison in the pixel domain. Here we have also added texture feature comparison of wevlet domain. The idea is drawn from the following paper "Comparison Between Color and Texture
Features for Image Retrieval".
* baed on the matrics I get some data table and will add here.
* Next week target: I will try to explore some GAN paper of this year and will generate some idea and want to play with that. 
