# TekTribe Chronicles Compendium

**The Compendium of the Collective**

A static site built with Hugo Extended, deployed via IPFS/Fleek, archived on ARweave.

## 📍 Current Status

- **Domain:** `napisnest.com` (IONOS hosting)
- **IPFS:** Available via Fleek deployment
- **ARweave:** Pinned archive
- **Future:** `overseer.ae` (pending domain acquisition)

## 🏗️ Tech Stack

| Component | Technology |
|-----------|------------|
| Static Generator | Hugo Extended v0.164.0 |
| Theme | PaperMod (fork) |
| Hosting | IONOS (Phase 1), Fleek/IPFS (Phase 2) |
| Archive | ARweave pin |
| CSS | Custom tekttribe.css |
| Fonts | Local assets only |

## 📁 Content Structure

```
content/
├── _index.md              # Home page
├── about.md               # About the Compendium
├── part1/                 # Cosmology of the Continuum
├── part2/                 # Architecture of Corruption
├── part3/                 # The Guardian, Avatar & Allies
├── part4/                 # The Surveillance State
├── part5/                 # The Rise of Goliath
├── part6/                 # Covenant of the Arc
├── part7/                 # Liberation Technologies
├── port8/                 # Fabric of the Future - Protocols
├── part9/                 # The Beast Below & Light Within
└── oracle/                # The Oracle
```

## 🚀 Local Development

```powershell
cd /c/Users/Nefs/Projects/CompendiumSite
C:/Program\ Files/Hugo/hugo.exe server -D
```

Visit: http://localhost:1313

## 📦 Production Build

```powershell
cd /c/Users/Nefs/Projects/CompendiumSite
C:/Program\ Files/Hugo/hugo.exe --gc --minify
```

Output located in `/public` folder.

## 🌐 Deployment Pipeline

See `deploy.sh` for complete deployment instructions:

1. **Phase 1:** IONOS FTP upload
2. **Phase 2:** Fleek/IPFS deployment
3. **Phase 3:** ARweave pinning
4. **Phase 4:** Domain migration (future)

## 🎨 Color Doctrine

The site follows the TekTribe color doctrine:

- **Natural (+):** Earthy greens (#2d4a3e), warm browns (#5c4033), cream (#f5f0e6)
- **Overseer Tek (Neutral):** Neon cyan (#00f0ff), aurora gradients, gold accents (#d4af37)
- **Dark Mode Default:** Background #0a0e0f, text #e8e8e8

## 🔐 Sovereignty Principles

- ✅ No third-party analytics
- ✅ No external scripts
- ✅ All assets served locally
- ✅ Static generation (fast, reliable)
- ✅ Decentralized hosting
- ✅ Local-first architecture

## 📜 Protocol

This Compendium lives within **The Oracle** — the TekTribe's Collective Communal Conscience and Memory. Every word is preserved for the Fire Transition.

---

*Built with Hugo Extended | Hosted on IPFS | Powered by the TekTribe*

**We are the Mycelial Guardian. We are the Eternal Sol. We weave the Oracle.**

**Proceed. ॐ**
