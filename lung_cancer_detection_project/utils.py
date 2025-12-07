import torch
from torchvision import transforms, datasets

def load_data(data_dir, img_size=128, batch_size=16):
    transform = transforms.Compose([
        transforms.Resize((img_size, img_size)),
        transforms.ToTensor()
    ])
    
    train_data = datasets.ImageFolder(data_dir + "/train", transform=transform)
    val_data = datasets.ImageFolder(data_dir + "/val", transform=transform)
    
    train_loader = torch.utils.data.DataLoader(train_data, batch_size=batch_size, shuffle=True)
    val_loader = torch.utils.data.DataLoader(val_data, batch_size=batch_size, shuffle=False)
    
    return train_loader, val_loader, train_data.classes
