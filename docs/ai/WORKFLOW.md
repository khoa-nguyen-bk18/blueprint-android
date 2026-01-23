# AI Development Workflow

## Quick Start (Automated)

### Start a new feature
```bash
./tools/ai-start-copilot.sh feature-name
```
This automatically:
1. Creates a new session file
2. Generates AI context pack
3. Launches GitHub Copilot with full context pre-loaded

### Resume last session
```bash
./tools/ai-resume-copilot.sh
```

## Alternative: Manual Workflow

### Generate context for manual copy/paste
```bash
# Start new feature
./tools/ai-start.sh feature-name

# Resume last session
./tools/ai-resume.sh

# Copy the output and paste into: copilot --allow-all-tools
```

## Available Scripts

### Automated Copilot Launch
- `tools/ai-start-copilot.sh <feature>` - Start new feature (auto-launches Copilot)
- `tools/ai-resume-copilot.sh` - Resume last session (auto-launches Copilot)

### Manual Context Generation
- `tools/ai-context.sh` - Generate AI context pack only
- `tools/ai-start.sh <feature>` - Start new feature (output for manual copy)
- `tools/ai-resume.sh` - Resume last session (output for manual copy)

### Validation
- `tools/check-fast.sh` - Quick checks (spotless, detekt, lint, unit tests)
- `tools/check.sh` - Full checks (fast + build)
- `tools/ai-allowlist-check.sh` - Verify changes match approved scope

## Shell Aliases (Optional)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias ai-start="./tools/ai-start-copilot.sh"
alias ai-resume="./tools/ai-resume-copilot.sh"
alias ai-check="./tools/check-fast.sh"
```

Then use:
```bash
ai-start login-feature
ai-resume
ai-check
```

## Workflow

1. **Start feature**: `./tools/ai-start-copilot.sh login-feature`
2. **AI summarizes rules and creates Change Contract**
3. **You reply**: `APPROVE_CONTRACT`
4. **AI implements in slices, running checks after each**
5. **Update session file** with progress
6. **Resume anytime**: `./tools/ai-resume-copilot.sh`

## How It Works

The `-i` flag launches Copilot in interactive mode with your prompt automatically executed:
```bash
copilot --allow-all-tools -i "your context here..."
```

No manual copy/paste needed!
