# HX Gamebanana

> Haxe wrappers for Gamebanana APIs

[![License](https://img.shields.io/github/license/immalloy/HX-Gamebanana)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/immalloy/HX-Gamebanana?style=social)](https://github.com/immalloy/HX-Gamebanana/stargazers)

Haxe wrappers for accessing Gamebanana modding platform APIs. Supports both the Web API (apiv11) and Official API with full endpoint coverage.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Web API Usage](#web-api-usage)
- [Official API Usage](#official-api-usage)
- [API Reference](#api-reference)
- [Supported Platforms](#supported-platforms)
- [Contributing](#contributing)
- [License](#license)
- [Links](#links)

## Features

### Web API (GamebananaWebAPI.hx)

- Search with filters and pagination
- Browse by categories
- Get mod/game/creator details
- Download files (by ID or URL)
- Download images (BitmapData/VpTexture)
- Download mod previews/thumbnails
- Download all previews at once
- Get ZIP file tree structure
- Save files to disk (desktop)
- Save images as PNG (desktop)
- Auto-pagination (get ALL results)
- Type-safe typedefs
- Like, subscribe, thank submissions
- Get files, updates, comments
- Manage collections, todos, issues
- Authentication support
- **104+ endpoints**

### Official API (GamebananaOfficialAPI.hx)

- Get item data
- List new submissions
- List by section with filters
- Search members
- RSS feeds (featured, new)
- App authentication
- **22 endpoints**

## Installation

### Prerequisites

- Haxe 4.0+
- OpenFL (for Flash/HTML5 targets)
- HX_NX (for Nintendo Switch target)

### Install via clone

```bash
git clone https://github.com/immalloy/HX-Gamebanana.git
```

Copy the `.hx` files to your project:

```
your-project/
├── src/
│   └── GamebananaWebAPI.hx       # Web API (apiv11)
│   └── GamebananaOfficialAPI.hx   # Official API
```

## Quick Start

### Web API (Recommended)

```haxe
import GamebananaAPI;

var api:GamebananaAPI = new GamebananaAPI();

// Search for mods
api.search('sonic', 'Mod', 'newest', 1, 25, function(results) {
    for (mod in results) {
        trace(mod._sName);
    }
});
```

### Official API

```haxe
import GamebananaOfficialAPI;

var api:GamebananaOfficialAPI = new GamebananaOfficialAPI();

// Get item data
api.getItemData('Mod', 650004, null, function(data) {
    trace(data._sName);
});
```

## Web API Usage

> Base URL: `https://gamebanana.com/apiv11`

### Flixel Example

```haxe
import GamebananaAPI;

var api:GamebananaAPI = new GamebananaAPI();

// Search for mods
api.search('sonic', 'Mod', 'newest', 1, 25, function(results) {
    for (mod in results) {
        trace(mod._sName);
    }
});

// Get mod details
api.getSubmissionProfilePage('Mod', 650004, function(mod) {
    trace('Name: ' + mod._sName);
    trace('Creator: ' + mod._aOwner._sName);
    trace('Downloads: ' + mod._nDownloadCount);
    trace('Likes: ' + mod._nLikeCount);
});

// Get mod files
api.getSubmissionFiles('Mod', 650004, function(files) {
    for (file in files) {
        trace('Download: ' + file._sFileUrl);
    }
});

// Download file
api.downloadFile(fileId, function(bytes) {
    // Save or process bytes
});

// Download file from URL
api.downloadFromUrl('https://gamebanana.com/files/12345/file.zip', function(bytes) {
    // bytes contains the raw file data
});

// Download image
api.downloadImage(imageUrl, function(bmp:BitmapData) {
    var spr:FlxSprite = new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(bmp));
    add(spr);

    var factor:Float = Math.min(FlxG.width / spr.width, FlxG.height / spr.height);
    spr.scale.set(factor, factor);
    spr.updateHitbox();
    spr.screenCenter();
});

// Download mod preview image (thumbnail)
api.downloadSubmissionPreview('Mod', 650004, function(bmp:BitmapData) {
    var thumb:FlxSprite = new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(bmp));
    add(thumb);
});

// Download all preview images from a mod
api.downloadAllPreviews('Mod', 650004, function(images:Array<BitmapData>) {
    for (img in images) {
        trace('Got image: ' + img.width + 'x' + img.height);
    }
});

// Download first file from a mod (main download)
api.downloadFirstFile('Mod', 650004, function(bytes) {
    // Save bytes to file or process
});

// Get ZIP file tree (see what's inside without downloading)
api.getZipTree(fileId, function(tree) {
    // tree contains the archive structure
});

// Download ZIP file
api.downloadZipFile(fileId, function(bytes) {
    // Save as .zip file
});

// ============================================
// FILE SAVING (Desktop targets)
// ============================================

// Save downloaded bytes to file
api.downloadFile(fileId, function(bytes) {
    api.saveBytes(bytes, 'myfile.zip');
});

// Download and save in one step
api.downloadAndSaveFile(fileId, 'mod.zip', function() {
    trace('File saved!');
});

// Download image from URL and save
api.downloadAndSaveUrl('https://example.com/image.png', 'preview.png', function() {
    trace('Image saved!');
});

// Save BitmapData as PNG
api.downloadImage(imageUrl, function(bmp:BitmapData) {
    api.saveImage(bmp, 'preview.png');
});

// Download and save image directly
api.downloadAndSaveImage(imageUrl, 'preview.png', function() {
    trace('Image saved to disk!');
});

// ============================================
// AUTO-PAGINATION (Get ALL results)
// ============================================

// Search and get ALL results (not just first page)
api.searchAll('sonic', 'Mod', function(allMods:Array<Dynamic>) {
    trace('Found ' + allMods.length + ' mods total!');
    for (mod in allMods) {
        trace(mod._sName);
    }
});

// Get ALL mods for a game (all pages)
api.getAllModsForGame(8694, function(allMods:Array<Dynamic>) {
    trace('Game has ' + allMods.length + ' mods!');
});

// ============================================
// TYPE-SAFE TYPEDEFS
// ============================================

// Use typedefs for cleaner code (optional)
// Instead of: data._sName, data._nDownloadCount
// You can use: data.name, data.downloadCount

import GamebananaSubmission;
import GamebananaFile;
import GamebananaMember;

api.getSubmissionProfilePage('Mod', 650004, function(data:Dynamic) {
    // Type-safe access (with IDE autocomplete)
    var submission:GamebananaSubmission = cast data;
    trace(submission._sName);
    trace(submission._nDownloadCount);
});

// Browse categories
api.getCategories('Mod', 'a_to_z', function(categories) {
    for (cat in categories) {
        trace(cat._sName);
    }
});

// Like a mod (requires auth)
api.likeSubmission('Mod', 650004, function(response) {
    trace('Liked!');
});

api.onError = function(e) {
    trace('Error: ' + e);
}
```

### Vupx Engine Example

```haxe
import GamebananaAPI;

var api:GamebananaAPI = new GamebananaAPI();

// Search for mods
api.search('sonic', 'Mod', 'newest', 1, 25, function(results) {
    for (mod in results) {
        VupxDebug.log(mod._sName, INFO);
    }
});

// Get mod profile
api.getSubmissionProfilePage('Mod', 650004, function(mod) {
    VupxDebug.log('Name: ' + mod._sName, INFO);
    VupxDebug.log('Downloads: ' + mod._nDownloadCount, INFO);
});

// Download and set texture
api.downloadImage(imageUrl, function(texture:VpTexture) {
    var spr:VpSprite = new VpSprite();
    spr.setTexture(texture);
    add(spr);

    var factor:Float = Math.min(Vupx.screenWidth / spr.width, Vupx.screenHeight / spr.height);
    spr.scale.set(factor, factor);
    spr.center();
});

api.onError = function(e) {
    VupxDebug.log('Error: ' + e, ERROR);
}
```

## Official API Usage

> Base URL: `https://api.gamebanana.com`

### Flixel Example

```haxe
import GamebananaOfficialAPI;

var api:GamebananaOfficialAPI = new GamebananaOfficialAPI();

// Get item data
api.getItemData('Mod', 650004, null, function(data) {
    trace(data._sName);
});

// List new mods
api.listNew('Mod', 8694, 1, function(mods) {
    for (mod in mods) {
        trace(mod._sName);
    }
});

// Search members
api.matchMember('username', function(members) {
    for (member in members) {
        trace(member._sName);
    }
});

// Get member ID by username
api.identifyMember('username', function(result) {
    trace(result._idRow);
});

api.onError = function(e) {
    trace('Error: ' + e);
}
```

## API Reference

### Response Field Prefixes

GameBanana APIs use consistent prefixes:

| Prefix | Type |
|--------|------|
| `_a` | Array |
| `_b` | Boolean |
| `_idRow` | Database ID |
| `_n` | Number |
| `_s` | String |
| `_ts` | Timestamp |
| `_h` | Height (pixels) |
| `_w` | Width (pixels) |

### Common Parameters

| Parameter | Description |
|-----------|-------------|
| `_nPage` | Page number (default: 1) |
| `_nPerpage` | Results per page (default: 20, max: 50) |
| `_sModelName` | Section type (Mod, Game, Tool, etc.) |
| `_sOrder` | Sort order (best_match, popularity, date, udate) |

### Section Names (Model Names)

```
App, Article, Bug, Blog, Club, Contest, Concept, Event, Game, 
Idea, Initiative, Jam, Mod, Model, Member, News, Poll, Project, 
Question, Review, Request, Script, Sound, Spray, Studio, 
Thread, Tool, Tutorial, Wiki, Wip
```

## Supported Platforms

Both wrappers support:

- OpenFL/Flash
  - Flash
  - HTML5
  - Windows
  - Mac
  - Linux
  - iOS
  - Android
- HX_NX (Nintendo Switch) - with VpTexture support

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Built With

- [Haxe](https://haxe.org/) - Programming language
- [OpenFL](https://openfl.org/) - Framework for multi-platform development
- [HX_NX](https://github.com/ImMalloy/HX-NX) - Nintendo Switch support

## Authors

- **ImMalloy** - *Initial work* - [GitHub](https://github.com/immalloy)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [GameBanana](https://gamebanana.com) - For the amazing modding platform
- Web API Documentation - Postman Collection (gb-api-v11)
- [pybanana](https://github.com/BobbyWucao/pybanana) - Python library that helped discover the Web API

## Links

- [GameBanana](https://gamebanana.com)
- [Web API Base](https://gamebanana.com/apiv11)
- [Official API Docs](https://api.gamebanana.com/)
- [GitHub Repository](https://github.com/immalloy/HX-Gamebanana)
