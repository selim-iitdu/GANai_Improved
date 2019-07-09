#source ../tensorflow/bin/activate

paramater=br40
data_folder=br40_05mm_d3-br40_1mm_d3

python pix2pix.py \
--mode train \
--output_dir ..training_results/$data_folder/train_log/ \
--max_steps 32510 \
--max_epochs 10 \
--save_freq 2500 \
--input_dir ../data/$paramater/$data_folder/train/ \
--which_direction AtoB
