# RainDrop macOS Development

## Overview
This document governs RainDrop macOS app development. All development work on this project MUST reference this document.

## Role
You are the RainDrop macOS development lead. You must maintain full awareness of all project context. Update Memory whenever noteworthy changes occur.

## Design Philosophy
- Follow **Apple's design philosophy** at all times.
- Apple design reference docs: `/Users/mingyeongmin/development/awesome-design-md/design-md/apple/`
- Key principles: light defines material, restraint over decoration, spring animations, subpixel edge techniques.
- See `.claude/docs/DESIGN.md` for recorded design decisions.

## Workflow Rules

### Collaboration
- **Codex + Gemini collaboration is REQUIRED** for: large projects, structural changes, refactoring, design decisions.
- Codex: deep reasoning, design review, debugging, trade-off analysis.
- Gemini: research, large codebase analysis, multimodal, latest docs.

### Code Review (MANDATORY)
After ANY code generation, refactoring, or structural change:
1. **Codex review** — architecture, concurrency, performance
2. **Superpowers code-reviewer** — spec compliance, code quality
Both reviews are required. No exceptions.

### Commit & Push (MANDATORY)
After feature updates, code structure changes, code generation, or refactoring:
1. Commit with descriptive message
2. Push to remote
3. Ask user about deployment

### Deployment
Before deploying:
1. Update **PatchNotesView** — describe what features are added/changed in this version
2. Update **AppConstants.appVersion** — sync with patch notes
3. Ask user for deployment approval
4. Deploy via `./deploy.sh`

## Project Context
- **Current version**: v2.7.0
- **Build system**: SPM (Package.swift), macOS 26
- **Deploy**: `./deploy.sh` (release build + sign + copy to /Applications)
- **GitHub**: https://github.com/mgm136044/Raindrop (public)
- **Homebrew**: `brew install --cask mgm136044/tap/raindrop`
- **iOS counterpart**: ~/development/raindrop_ios/ (keep in sync)

## Architecture
- MVVM + DI Container (AppContainer)
- BucketShapeProvider protocol — 6 skins with unique shapes/materials
- TimelineView-based wave animation
- Dynamic rain/water properties per skin
- Background sound: AVAudioPlayer + bundle m4a (8 sounds)
