# File Reference Guide - Spec Wizard (Real-time # with fzf)

## Prerequisites

Install both `gum` and `fzf`:

```bash
# macOS
brew install gum fzf

# Linux
sudo apt install fzf
# gum: download from https://github.com/charmbracelet/gum/releases
```

## How File References Work (GitHub Copilot-style!)

Type normally and press `#` **anytime** - fzf launches **immediately** with fuzzy search and preview. This is true real-time behavior, just like GitHub Copilot Chat!

## Workflow

### 1. Start Typing

```
Prompt: "Screens involved"
You type: "User starts on "
```

### 2. Press # - fzf Launches Instantly!

```
┌─ Select file/folder > ──────────────────┐  ┌─ Preview ───────────┐
│ LoginScreen.kt                           │  │ @Composable         │
│ HomeScreen.kt                            │  │ fun LoginScreen(    │
│ > ProfileScreen.kt                       │  │   viewModel: ...    │
│ ...                                      │  │ ) {                 │
└──────────────────────────────────────────┘  └─────────────────────┘
```

- **Type to fuzzy search**: `login` filters to LoginScreen.kt
- **Arrow keys**: Navigate
- **Enter**: Select and insert `[LoginScreen.kt](path)`
- **Esc**: Cancel (nothing inserted)

### 3. Continue Typing

fzf closes, you're back to typing:

```
You continue: " and navigates to "
```

Press `#` again, select HomeScreen.kt

### 4. Result

```
Final text: "User starts on [LoginScreen.kt](app/src/.../LoginScreen.kt) 
and navigates to [HomeScreen.kt](app/src/.../HomeScreen.kt)"
```

## Features

### ✅ Real-time # Detection
- Character-by-character input monitoring
- `#` launches fzf **immediately**
- File reference inserted **inline**
- Continue typing after selection

### ✅ Backspace Support
- Delete normally with backspace
- Works on regular text and inserted file references

### ✅ Multi-line Input
- Press `#` on any line
- Press **Enter** for new line
- Press **Ctrl+D** when finished

### ✅ fzf Fuzzy Search
- Type any part of filename: `login` → LoginScreen.kt
- Type path parts: `ui/log` → ui/LoginScreen.kt  
- Preview window shows file contents

## Examples

### Example 1: Inline File Reference

```
Type: "Implement auth in "
Press: #
fzf opens → type "auth" → select AuthRepository.kt
Continue: " with validation"

Result: "Implement auth in [AuthRepository.kt](...) with validation"
```

### Example 2: Multiple References

```
Type: "Data flows "
Press: #
Select: LoginScreen.kt
Type: " → "
Press: #
Select: AuthViewModel.kt  
Type: " → "
Press: #
Select: AuthRepository.kt

Result: "Data flows [LoginScreen.kt](...) → [AuthViewModel.kt](...) → [AuthRepository.kt](...)"
```

### Example 3: Multi-line

```
Type line 1: "Business rules:"
Press Enter
Type line 2: "- Auth via "
Press: #
Select: AuthRepository.kt
Press Enter
Type line 3: "- Token in "
Press: #
Select: SecureStorage.kt
Press Ctrl+D (finish)

Result:
Business rules:
- Auth via [AuthRepository.kt](...)
- Token in [SecureStorage.kt](...)
```

## Comparison to GitHub Copilot Chat

| Feature | GitHub Copilot Chat | spec-wizard (real-time) |
|---------|---------------------|-------------------------|
| Inline typing | ✅ Real-time | ✅ Real-time |
| File picker trigger | `#` while typing | ✅ `#` while typing |
| Fuzzy search | ✅ Yes | ✅ Yes (fzf) |
| Preview | ❌ No | ✅ Yes (file contents) |
| Backspace | ✅ Yes | ✅ Yes |
| Multi-line | ✅ Yes | ✅ Yes (Ctrl+D) |
| Tech stack | VS Code extension | Bash + fzf + gum |

**This implementation matches GitHub Copilot's UX!**

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `#` | Launch fzf file picker |
| **Backspace** | Delete character |
| **Enter** | New line (multi-line) or finish (single-line) |
| **Ctrl+D** | Finish multi-line input |
| **Esc** (in fzf) | Cancel file selection |

## Tips

1. **Type naturally**: No need to plan ahead, press `#` whenever you want a file reference
2. **Fuzzy search is smart**: Type any part - `auth`, `repo`, `ui/log`
3. **Preview helps**: Glance right to confirm it's the correct file
4. **Multiple refs**: Press `#` as many times as needed in one field
5. **Backspace works**: Delete file refs just like regular text

## Troubleshooting

**fzf not launching when I press #**
- Make sure you're in a field that uses `prompt_with_file_ref` or `write_with_file_ref`
- Check terminal supports raw input mode

**Can't backspace over file reference**
- Backspace works character-by-character
- File refs are markdown links, may need multiple backspaces

**fzf not found**
```bash
brew install fzf
```

**Preview not showing**
- Preview requires readable files
- Directories show `ls -la` output

