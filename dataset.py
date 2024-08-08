import torch
from torch.utils.data import Dataset
from torchvision import transforms
from PIL import Image
import os
import random
import numpy as np

class AugmentedPairedImageDataset(Dataset):
    def __init__(self, repaired_dir, damaged_dir, image_size=256, seed=None):
        self.repaired_dir = repaired_dir
        self.damaged_dir = damaged_dir
        self.image_size = image_size
        
        # Get list of files
        repaired_files = set(os.listdir(repaired_dir))
        damaged_files = set(os.listdir(damaged_dir))
        
        # Create a mapping between repaired and damaged filenames
        self.file_pairs = []
        for repaired_file in repaired_files:
            base_name = repaired_file.replace('-repaired', '')
            if base_name in damaged_files:
                self.file_pairs.append((repaired_file, base_name))
        
        if not self.file_pairs:
            raise ValueError("No matching file pairs found in the directories")
        
        print(f"Found {len(self.file_pairs)} valid image pairs")
        
        if seed is not None:
            random.seed(seed)
            torch.manual_seed(seed)
            np.random.seed(seed)

        self.transform = transforms.Compose([
            transforms.Resize((image_size, image_size)),
            transforms.RandomHorizontalFlip(),
            transforms.RandomVerticalFlip(),
            transforms.RandomRotation(10),
            transforms.ColorJitter(brightness=0.1, contrast=0.1),
            transforms.ToTensor(),
            transforms.Normalize((0.5, ), (0.5, )),
        ])

        self.affine_transform = transforms.RandomAffine(
            degrees=0, translate=(0.05, 0.05), scale=(0.95, 1.05), shear=5
        )

    def __len__(self):
        return len(self.file_pairs) * 4  # Multiplying by 4 to increase dataset size

    def __getitem__(self, idx):
        real_idx = idx % len(self.file_pairs)
        repaired_name, damaged_name = self.file_pairs[real_idx]
        repaired_path = os.path.join(self.repaired_dir, repaired_name)
        damaged_path = os.path.join(self.damaged_dir, damaged_name)

        try:
            repaired_image = Image.open(repaired_path).convert('L')
        except Exception as e:
            raise IOError(f"Error opening repaired image {repaired_path}: {str(e)}")

        try:
            damaged_image = Image.open(damaged_path).convert('L')
        except Exception as e:
            raise IOError(f"Error opening damaged image {damaged_path}: {str(e)}")

        # Ensure both images get the same random transforms
        seed = np.random.randint(2147483647)
        
        torch.manual_seed(seed)
        random.seed(seed)
        repaired_image = self.transform(repaired_image)
        
        torch.manual_seed(seed)
        random.seed(seed)
        damaged_image = self.transform(damaged_image)

        # Apply affine transformation
        if random.random() > 0.5:
            affine_seed = np.random.randint(2147483647)
            torch.manual_seed(affine_seed)
            repaired_image = self.affine_transform(repaired_image)
            torch.manual_seed(affine_seed)
            damaged_image = self.affine_transform(damaged_image)

        # Add slight Gaussian noise
        if random.random() > 0.5:
            noise = torch.randn_like(repaired_image) * 0.02
            repaired_image = torch.clamp(repaired_image + noise, 0, 1)
            damaged_image = torch.clamp(damaged_image + noise, 0, 1)

        return repaired_image, damaged_image