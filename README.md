# 🎧 Audiobook Converter  

📚 **Audiobook Converter** is a Bash script that merges multiple MP3 files into a single **M4B audiobook** with metadata and cover art.  
It ensures a seamless listening experience, optimized for Apple Books, iTunes, and other audiobook players.

---

## 🔧 Requirements  

This script requires **FFmpeg**, a powerful multimedia framework for merging and converting audio files.  

### **Install FFmpeg**  

```bash
# macOS (Homebrew)
brew install ffmpeg

# Debian/Ubuntu
sudo apt install ffmpeg

# Arch Linux
sudo pacman -S ffmpeg
```

---

## 🚀 Features  

✅ **Automatically detects MP3 files** in a folder  
✅ **Merges multiple MP3 files** into a single audiobook  
✅ **Converts MP3 to M4B** for better playback in Apple Books  
✅ **Embeds cover art** (`cover.jpg` or `folder.jpg` if available)  
✅ **Extracts metadata** (title, author, album) from MP3 files  
✅ **Handles single or multiple MP3 files intelligently**  
✅ **Can be run from any folder** by passing a directory as an argument  

---

## 🛠 Installation  

### **1⃣ Clone the Repository**  

```bash
git clone https://github.com/YOUR-USERNAME/audiobook_converter.git
cd audiobook_converter
```

### **2⃣ Make the Script Executable**  

```bash
chmod +x convert_audiobook.sh
```

### **3⃣ (Optional) Install Globally**  

To use the script from any folder:  

```bash
sudo mv convert_audiobook.sh /usr/local/bin/convert_audiobook
```

Now, you can simply type:  

```bash
convert_audiobook /path/to/audiobook-folder
```

---

## 🎮 Usage  

### ✅ **Convert Audiobooks in the Current Folder**  

```bash
cd /path/to/audiobook
convert_audiobook
```
- **If the folder contains one MP3**, it is converted directly to M4B.  
- **If the folder contains multiple MP3s**, they are merged first before conversion.  

### ✅ **Convert Audiobooks from Any Location**  

```bash
convert_audiobook /path/to/audiobook-folder
```

---

## 🎨 Metadata & Cover Art  

- 🏷 **Extracts title, artist, and album** from the first MP3 file.  
- 🏷 Uses **folder name** if metadata is missing.  
- 🎨 **Automatically adds cover art** if `cover.jpg` or `folder.jpg` is found.  

---

## 🔧 Troubleshooting  

1⃣ **FFmpeg Not Installed?**  
   Install it with:  
   ```bash
   brew install ffmpeg  # macOS
   sudo apt install ffmpeg  # Linux
   ```

2⃣ **Permission Issues?**  
   If you get a permission error, run:  
   ```bash
   chmod +x convert_audiobook.sh
   ```

---

## ❤️ Contributing  

Pull requests are welcome! Please open an issue first for major changes.  

---

## 🐝 License  

This project is open-source under the **MIT License**.  

---

## 📢 Credits  

Developed by **Your Name** 🚀  

