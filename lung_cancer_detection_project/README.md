## Multiscale CNN (MSFF-CNN) for Lung Cancer Detection

This project implements a Multiscale Feature Fusion Convolutional Neural Network (MSFF-CNN) to classify lung CT scan images into benign, malignant, and normal categories using the IQ-OTHNCCD lung cancer dataset.
The model extracts features at three different convolution depths and fuses them to improve classification capability.

## Features

Custom MSFF-CNN architecture
Multi-scale feature fusion (Conv1 + Conv2 + Conv3)
Global Average Pooling for compact representation
Train/Validation split (80–20)
Accuracy curve visualization
Clean modular codebase (model, data loader, training loop)

## Dataset

Source: The IQ-OTHNCCD Lung Cancer Dataset

Benign: 120 images
Malignant: 561 images
Normal: 416 images

## Folder structure used for training:

data/
   train/
      benign/
      malignant/
      normal/
   val/
      benign/
      malignant/
      normal/


Use train_test_split.py to generate this structure automatically.

## Model Architecture (MSFF-CNN)

3 Convolution Blocks (32 → 64 → 128 filters)
Global Average Pooling at each block
Feature concatenation
Fully Connected Layers
Softmax output (3 classes)

## How to Run
pip install -r requirements.txt 
python train_test_split.py   # run once
python main.py

## Results:

Train Accuracy: ~50%
Validation Accuracy: ~49%
Accuracy curve generated automatically after training

## Project Files
main.py               # training loop
model.py              # MSFF-CNN architecture
utils.py              # transforms & dataloader
train_test_split.py   # dataset split script
requirements.txt
README.md

## Future Improvements: 
Add data augmentation
Use weighted loss
Implement transfer learning (ResNet/DenseNet)
Add attention modules