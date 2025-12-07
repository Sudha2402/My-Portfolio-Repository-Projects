import torch
import torch.nn as nn

class MSFF_CNN(nn.Module):
    def __init__(self, num_classes=3):
        super(MSFF_CNN, self).__init__()
        
        self.conv1 = nn.Sequential(
            nn.Conv2d(3, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2)
        )
        self.conv2 = nn.Sequential(
            nn.Conv2d(32, 64, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2)
        )
        self.conv3 = nn.Sequential(
            nn.Conv2d(64, 128, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2)
        )
        
        self.gap = nn.AdaptiveAvgPool2d(1)
        
        self.fc = nn.Sequential(
            nn.Linear(32 + 64 + 128, 64),
            nn.ReLU(),
            nn.Linear(64, num_classes)
        )

    def forward(self, x):
        f1 = self.conv1(x)
        f2 = self.conv2(f1)
        f3 = self.conv3(f2)
        
        f1 = self.gap(f1).view(x.size(0), -1)
        f2 = self.gap(f2).view(x.size(0), -1)
        f3 = self.gap(f3).view(x.size(0), -1)
        
        fusion = torch.cat([f1, f2, f3], dim=1)
        out = self.fc(fusion)
        return out
