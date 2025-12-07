from sklearn.model_selection import train_test_split
import os
import shutil

src = "dataset"     # raw dataset
dst = "data"        # final folder used for training

classes = ["benign", "malignant", "normal"]

# --- Ensure directories exist ---
for cls in classes:
    os.makedirs(f"{dst}/train/{cls}", exist_ok=True)
    os.makedirs(f"{dst}/val/{cls}", exist_ok=True)

# --- Split and copy ---
for cls in classes:
    print(f"\nProcessing class: {cls}")

    files = [
        f for f in os.listdir(f"{src}/{cls}")
        if os.path.isfile(f"{src}/{cls}/{f}") and f.lower().endswith((".jpg", ".jpeg", ".png"))
    ]

    if len(files) == 0:
        print(f"⚠ WARNING: No images found for class {cls}")
        continue

    train_files, val_files = train_test_split(files, test_size=0.2, random_state=42)

    # Copy train images
    for f in train_files:
        shutil.copy(f"{src}/{cls}/{f}", f"{dst}/train/{cls}/{f}")

    # Copy val images
    for f in val_files:
        shutil.copy(f"{src}/{cls}/{f}", f"{dst}/val/{cls}/{f}")

    print(f"✔ Done: {cls} → {len(train_files)} train, {len(val_files)} val")
