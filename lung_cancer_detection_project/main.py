import torch
import torch.nn as nn
import torch.optim as optim
import matplotlib.pyplot as plt

from utils import load_data
from model import MSFF_CNN

# Load Dataset
train_loader, val_loader, classes = load_data("data")

# Device setup
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Using:", device)

# Model
model = MSFF_CNN(num_classes=len(classes)).to(device)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

train_acc_list = []
val_acc_list = []

# Training Loop
for epoch in range(5):
    correct, total = 0, 0
    model.train()
    
    for images, labels in train_loader:
        images, labels = images.to(device), labels.to(device)
        
        optimizer.zero_grad()
        outputs = model(images)
        
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        
        _, predicted = torch.max(outputs, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()
    
    train_acc = 100 * correct / total
    train_acc_list.append(train_acc)
    
    # Validation Accuracy
    correct, total = 0, 0
    model.eval()
    
    with torch.no_grad():
        for images, labels in val_loader:
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            
            _, predicted = torch.max(outputs, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    
    val_acc = 100 * correct / total
    val_acc_list.append(val_acc)
    
    print(f"Epoch {epoch+1}: Train Acc = {train_acc:.2f}%, Val Acc = {val_acc:.2f}%")



train_loader, val_loader, classes = load_data("data")

# -------------------------
# SHOW 8 IMAGES FROM BATCH
# -------------------------
import matplotlib.pyplot as plt
import numpy as np
import torch

# get one batch
batch = next(iter(train_loader))
images, labels = batch

# show first 8 images
plt.figure(figsize=(12, 6))
for i in range(8):
    img = images[i].permute(1, 2, 0).numpy()     # CHW → HWC
    img = (img - img.min()) / (img.max() - img.min() + 1e-5)   # normalize to 0–1

    plt.subplot(2, 4, i+1)
    plt.imshow(img)
    plt.title(classes[labels[i]])
    plt.axis('off')

plt.tight_layout()
plt.show()
plt.close() 


# Plot Result
plt.figure(figsize=(8,5))
plt.plot(train_acc_list, label="Train Accuracy")
plt.plot(val_acc_list, label="Val Accuracy")
plt.legend()
plt.title("Accuracy Curve")
plt.show()
plt.close()
