# MarkItDown — Setup Guide (Windows)

A step-by-step guide to install Microsoft's MarkItDown tool on Windows, so you can convert PDF, PPTX, DOCX, XLSX and other files to Markdown from the command line or via a right-click menu.

---

## Prerequisites

- Windows 10 or 11
- Git installed — download from https://git-scm.com/download/win
- Internet connection

---

## Step 1 — Install Python 3.12

MarkItDown requires Python 3.10 or higher. Install it using **winget** (built into Windows):

```powershell
winget install Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements
```

After installation, open a **new** PowerShell window and verify:

```powershell
python --version
pip --version
```

Expected output:
```
Python 3.12.10
pip 25.x.x from ...
```

---

## Step 2 — Clone the Repository

Choose a folder where you want to keep MarkItDown. In this guide we use `G:\EffCorp_Products\markitdown\`.

If the folder is empty, clone directly into it:

```powershell
git clone https://github.com/microsoft/markitdown.git "G:\EffCorp_Products\markitdown"
```

If the folder already exists and has some files in it (e.g. a `.claude` folder), clone into a temporary folder and move the files across:

```powershell
git clone https://github.com/microsoft/markitdown.git "G:\EffCorp_Products\_markitdown_tmp"
Get-ChildItem "G:\EffCorp_Products\_markitdown_tmp" -Force | ForEach-Object { Move-Item $_.FullName "G:\EffCorp_Products\markitdown\" -Force }
Remove-Item "G:\EffCorp_Products\_markitdown_tmp" -Recurse -Force
```

---

## Step 3 — Create a Virtual Environment

Navigate to the markitdown folder and create a virtual environment called `.venv`:

```powershell
cd "G:\EffCorp_Products\markitdown"
python -m venv .venv
```

Verify it was created with the right Python version:

```powershell
.venv\Scripts\python.exe --version
```

Expected output:
```
Python 3.12.10
```

---

## Step 4 — Install MarkItDown (with All Optional Dependencies)

Install MarkItDown in **editable mode** from source, with all optional format support:

```powershell
.venv\Scripts\pip.exe install -e "packages/markitdown[all]"
```

This installs support for: PDF, PPTX, DOCX, XLSX, XLS, audio, YouTube transcription, Azure Document Intelligence, Azure Content Understanding, and more.

Verify the installation:

```powershell
.venv\Scripts\markitdown.exe --version
```

Expected output:
```
markitdown 0.1.6
```

---

## Step 5 — Add MarkItDown to the PATH

So you can type `markitdown` from any terminal without the full path, add the venv Scripts folder to your **User PATH** permanently:

```powershell
$scriptsPath = "G:\EffCorp_Products\markitdown\.venv\Scripts"
$currentUserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
[System.Environment]::SetEnvironmentVariable("PATH", "$currentUserPath;$scriptsPath", "User")
```

Open a **new** PowerShell window and verify:

```powershell
markitdown --version
```

Expected output:
```
markitdown 0.1.6
```

> **Note:** The PATH change only applies to new terminal windows — your current terminal will not pick it up until restarted.

---

## Step 6 — Basic Usage from Command Line

Convert any file to Markdown and save it in the same folder:

```powershell
# Using -o flag (recommended)
markitdown "path\to\file.pdf" -o "path\to\file.md"

# Using redirect
markitdown "path\to\file.pdf" > "path\to\file.md"
```

Examples:

```powershell
# PDF
markitdown "C:\Documents\report.pdf" -o "C:\Documents\report.md"

# PowerPoint
markitdown "C:\Documents\presentation.pptx" -o "C:\Documents\presentation.md"

# Word
markitdown "C:\Documents\document.docx" -o "C:\Documents\document.md"

# Excel
markitdown "C:\Documents\spreadsheet.xlsx" -o "C:\Documents\spreadsheet.md"
```

---

## Step 7 — Add a Right-Click "Convert to Markdown" Option in Windows Explorer

### 7a — Create a helper batch script

Save the following as `G:\EffCorp_Products\markitdown\convert_to_md.bat`:

```batch
@echo off
set "INPUT=%~1"
set "OUTPUT=%~dpn1.md"
"G:\EffCorp_Products\markitdown\.venv\Scripts\markitdown.exe" "%INPUT%" -o "%OUTPUT%"
if %ERRORLEVEL% == 0 (
    echo Done! Saved to: %OUTPUT%
) else (
    echo Conversion failed.
)
pause
```

- `%~1` — the file path passed by Windows when you right-click
- `%~dpn1` — extracts drive + directory + filename (without extension), so the output is always in the same folder with a `.md` extension

### 7b — Add the Registry Entry

Run the following in PowerShell (adds the menu entry for your user only — no admin required):

```powershell
$batPath = "G:\EffCorp_Products\markitdown\convert_to_md.bat"

# Create the menu entry
New-Item -Path "HKCU:\Software\Classes\*\shell\ConvertToMarkdown" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\*\shell\ConvertToMarkdown" -Name "(Default)" -Value "Convert to Markdown"
Set-ItemProperty -Path "HKCU:\Software\Classes\*\shell\ConvertToMarkdown" -Name "Icon" -Value "shell32.dll,70"

# Set the command to run
New-Item -Path "HKCU:\Software\Classes\*\shell\ConvertToMarkdown\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\*\shell\ConvertToMarkdown\command" -Name "(Default)" -Value "cmd.exe /c `"$batPath`" `"%1`""
```

### 7c — Verify the Registry Entry

```powershell
Get-ItemProperty "HKCU:\Software\Classes\*\shell\ConvertToMarkdown"
Get-ItemProperty "HKCU:\Software\Classes\*\shell\ConvertToMarkdown\command"
```

You should see:
```
(default) : Convert to Markdown
(default) : cmd.exe /c "G:\EffCorp_Products\markitdown\convert_to_md.bat" "%1"
```

### 7d — How to use it

1. Open **Windows Explorer** and navigate to any file (PDF, PPTX, DOCX, etc.)
2. **Right-click** the file
3. Click **"Convert to Markdown"**
4. A terminal window opens, runs the conversion, and prints `Done! Saved to: ...`
5. Press any key to close the terminal
6. The `.md` file appears in the same folder as the original file

---

## Optional — Remove the Right-Click Menu Entry

If you ever want to remove the context menu option:

```powershell
Remove-Item -Path "HKCU:\Software\Classes\*\shell\ConvertToMarkdown" -Recurse -Force
```

---

## Notes

- **ffmpeg warning:** You may see a warning about ffmpeg not being found. This is harmless unless you need audio/video transcription. To fix it: `winget install Gyan.FFmpeg`
- **Supported formats:** PDF, PPTX, DOCX, XLSX, XLS, HTML, CSV, JSON, XML, images (with EXIF/OCR), audio, YouTube URLs, EPubs, ZIP files
- **LLM image descriptions:** For image-heavy files (e.g. PPTX with diagrams), you can pass an OpenAI client for richer descriptions — see the [MarkItDown README](https://github.com/microsoft/markitdown)
