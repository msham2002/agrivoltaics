import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import numpy as np
from sklearn.metrics import classification_report, f1_score
from tqdm import tqdm
import torchvision.models as models
import torchvision.transforms.functional as TF
import random
import random
import torchvision.transforms.functional as TF
import torch

DATA_DIR = "./training_data"
BATCH_SIZE = 32
EPOCHS = 500
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

class RandomAugmentation(object):
    def __init__(self, rotation_range=15, translation_range=5, p_flip=0.5):
        self.rotation_range = rotation_range
        self.translation_range = translation_range
        self.p_flip = p_flip

    def __call__(self, tensor):
        #tensor shape: (C, H, W)
        #Random horizontal flip
        if random.random() < self.p_flip:
            tensor = torch.flip(tensor, dims=[2])
        #Random rotation: angle between -rotation_range and rotation_range
        angle = random.uniform(-self.rotation_range, self.rotation_range)
        tensor = TF.rotate(tensor, angle, interpolation=TF.InterpolationMode.BILINEAR)
        #Random translation: shift by up to ±translation_range pixels
        tx = random.uniform(-self.translation_range, self.translation_range)
        ty = random.uniform(-self.translation_range, self.translation_range)
        tensor = TF.affine(tensor, angle=0, translate=(tx, ty), scale=1.0, shear=0, interpolation=TF.InterpolationMode.BILINEAR)
        return tensor

def adjust_brightness_multichannel(tensor, brightness_factor):
    #Multiply every channel by brightness_factor.
    return tensor * brightness_factor

def adjust_contrast_multichannel(tensor, contrast_factor):
    #For each channel, adjust contrast:
    #out = (tensor - mean) * contrast_factor + mean, computed per channel.
    mean = tensor.mean(dim=(1, 2), keepdim=True)
    return (tensor - mean) * contrast_factor + mean
    
class StrongAugmentation(object):
    def __init__(self, rotation_range=15, translation_range=5,
                 brightness_range=(0.8, 1.2), contrast_range=(0.8, 1.2),
                 p_flip=0.5):
        self.rotation_range = rotation_range
        self.translation_range = translation_range
        self.brightness_range = brightness_range
        self.contrast_range = contrast_range
        self.p_flip = p_flip

    def __call__(self, tensor):
        #tensor shape: (C, H, W)
        #Random horizontal flip
        if random.random() < self.p_flip:
            tensor = torch.flip(tensor, dims=[2])
            
        #Random rotation using torchvision (this works for multi-channel tensors)
        angle = random.uniform(-self.rotation_range, self.rotation_range)
        tensor = TF.rotate(tensor, angle, interpolation=TF.InterpolationMode.BILINEAR)
        
        #Random translation
        tx = random.uniform(-self.translation_range, self.translation_range)
        ty = random.uniform(-self.translation_range, self.translation_range)
        tensor = TF.affine(tensor, angle=0, translate=(tx, ty), scale=1.0, shear=0,
                           interpolation=TF.InterpolationMode.BILINEAR)
        
        #Random brightness adjustment (custom for multi-channel)
        brightness_factor = random.uniform(*self.brightness_range)
        tensor = adjust_brightness_multichannel(tensor, brightness_factor)
        
        #Random contrast adjustment (custom for multi-channel)
        contrast_factor = random.uniform(*self.contrast_range)
        tensor = adjust_contrast_multichannel(tensor, contrast_factor)
        
        return tensor


class BotrytisDataset(Dataset):
    def __init__(self, data_dir, transform=None):
        self.data_dir = data_dir
        self.transform = transform
        self.samples = []
        for f in sorted(os.listdir(data_dir)):
            if f.endswith(".npy"):
                label_path = os.path.join(data_dir, f.replace("image_", "label_").replace(".npy", ".txt"))
                if os.path.exists(label_path):
                    self.samples.append(f)
        #Load global normalization stats
        self.global_mean = np.load("global_mean.npy")  #shape (7,)
        self.global_std = np.load("global_std.npy")    #shape (7,)

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        image_path = os.path.join(self.data_dir, self.samples[idx])
        label_path = image_path.replace("image_", "label_").replace(".npy", ".txt")
        image = np.load(image_path).astype(np.float32)  #shape (7, H, W)
        label = int(open(label_path).read().strip())
        image = torch.tensor(image)  #Convert to tensor
        #Apply augmentations if provided (applied on the 7-channel tensor)
        if self.transform is not None:
            image = self.transform(image)
        #Normalize each channel using global mean and std (pre-computed from training set)
        for c in range(image.shape[0]):
            image[c] = (image[c] - self.global_mean[c]) / (self.global_std[c] + 1e-8)
        return image, torch.tensor(label, dtype=torch.long)

def build_resnet18_multispectral():
    model = models.resnet18(pretrained=False)  #training from scratch
    #Modify first conv layer to accept 7 channels instead of 3
    model.conv1 = nn.Conv2d(7, 64, kernel_size=7, stride=2, padding=3, bias=False)
    model.fc = nn.Linear(512, 2)  #binary classification
    return model

USE_RESNET = True

def train(model, loader, optimizer, criterion):
    model.train()
    total_loss = 0
    for images, labels in tqdm(loader):
        images, labels = images.to(DEVICE), labels.to(DEVICE)
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    return total_loss / len(loader)

def evaluate(model, loader):
    model.eval()
    all_preds, all_labels = [], []
    with torch.no_grad():
        for images, labels in loader:
            images = images.to(DEVICE)
            outputs = model(images)
            preds = torch.argmax(outputs, dim=1).cpu().numpy()
            all_preds.extend(preds)
            all_labels.extend(labels.numpy())
    report = classification_report(all_labels, all_preds, digits=4)
    print(report)
    return f1_score(all_labels, all_preds, average='macro')

def main():
    #Use custom augmentation transform
    augmentation = RandomAugmentation(rotation_range=15, translation_range=0, p_flip=0.5)
    
    #don't use strong augmentation it produced worse results
    #augmentation = StrongAugmentation(rotation_range=15, translation_range=5, brightness_range=(0.8, 1.2), contrast_range=(0.8, 1.2), p_flip=0.5)
    
    dataset = BotrytisDataset(DATA_DIR, transform = augmentation)#transform=augmentation)
    train_size = int(0.8 * len(dataset))
    val_size = len(dataset) - train_size
    train_set, val_set = torch.utils.data.random_split(dataset, [train_size, val_size])

    train_loader = DataLoader(train_set, batch_size=BATCH_SIZE, shuffle=True)
    val_loader = DataLoader(val_set, batch_size=BATCH_SIZE)

    if USE_RESNET:
        model = build_resnet18_multispectral().to(DEVICE)
    else:
        pass
        #model = VineClassifier().to(DEVICE)  #old custom CNN
    
    optimizer = optim.Adam(model.parameters(), lr=1e-3, weight_decay=1e-5)
    criterion = nn.CrossEntropyLoss(weight=torch.tensor([1.0, 1.0]).to(DEVICE))

    best_val_score = 0.0
    best_model_path = "disease_model_resnet_aug.pth"
    patience = 50
    no_improve_epochs = 0

    for epoch in range(EPOCHS):
        print(f"\nEpoch {epoch+1}/{EPOCHS}")
        loss = train(model, train_loader, optimizer, criterion)
        print(f"Train Loss: {loss:.4f}")
        val_f1 = evaluate(model, val_loader)
        if val_f1 > best_val_score:
            best_val_score = val_f1
            torch.save(model.state_dict(), best_model_path)
            print(f"✅ New best model saved with F1={val_f1:.4f}")
            no_improve_epochs = 0
        else:
            no_improve_epochs += 1
            print(f"No improvement for {no_improve_epochs} epoch(s).")
        if no_improve_epochs >= patience:
            print("Early stopping triggered.")
            break

    print(f"\nBest model saved to {best_model_path}")

if __name__ == "__main__":
    main()
