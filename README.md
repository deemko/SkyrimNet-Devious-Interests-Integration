# SkyrimNet Devious Interests Integration
Simple SkyrimNet - Devious Interests bridge

### 📖 What it does
This mod acts as a "bridge" between **SkyrimNet** and **Devious Interests**, allowing the SkyrimNet ecosystem to fully recognize and utilize Devious Interests mechanics. 

If you use both mods, this integration will make your experience smoother, more logical, and highly interactive.

### ✨ Key Features
The mod registers a variety of new actions in SkyrimNet related to devices and roleplay interactions:
* **Device Removal & Unlocking:** Supports over 15 types of gear, including collars, belts, bras, cuffs, yokes, binders, mittens, hoods, gags, blindfolds, boots, corsets, plugs, harnesses, and more.
* **Bondage Offer:** Adds support for actions related to bondage proposals.
* **Prostitution Actions:** Integrates actions related to prostitution mechanics from DI.

### 🛡️ Why It’s Safe & Convenient
We paid special attention to stability and logical flow to ensure the mod doesn't interfere with your gameplay:
* **Smart Logic:** The mod won't try to remove a device if you aren't wearing one, and it won't execute actions if they are invalid in the current situation.
* **Combat Safety:** Actions are automatically blocked during combat to prevent bugs and crashes.
* **Error Prevention:** Before executing any action, the mod thoroughly checks if the main Devious Interests script (`din_Main`) is properly loaded.
* **Responsiveness:** Successful and unsuccessful scenarios are handled separately, preventing the SkyrimNet interface from "hanging" or desyncing.

### Requirements:
- [SkyrimNet](https://github.com/MinLL/SkyrimNet-GamePlugin)
- [Devious Interests](https://www.loverslab.com/files/file/41305-devious-interests-se/) or [Devious Interests RUS](https://aml.name/files/file/2263-devious-interests-rus/)
- [Devious Devices NG](https://www.loverslab.com/files/file/29779-devious-devices-ng/)
- [Kris's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/115164)
- [SexLab](https://github.com/eeveelo/SexLab)
- [SLO Aroused NG](https://www.nexusmods.com/skyrimspecialedition/mods/151502)

### Optional:
- [Devious Mimic Clothing](https://www.loverslab.com/files/file/14694-devious-mimic-clothing-se/)
- [Devious Wicked Devices](https://www.loverslab.com/files/file/42152-devious-wicked-devices/)
- [Laura's Bondage Shop](https://www.loverslab.com/files/file/6949-devious-devices-lauras-bondage-shop-16-aug-2025-v355-le-se/)
- [Licenses - Player Oppression](https://www.loverslab.com/files/file/29357-licenses-player-oppression/)
- [Love Sickness](https://www.loverslab.com/files/file/20724-love-sickness-lese/)
- [SexLab Inflation Framework](https://www.loverslab.com/files/file/6938-sexlab-inflation-framework-se/)
- [Simple Slavery Plus Plus](https://www.loverslab.com/files/file/13531-simple-slavery-plus-plus/)
- [Alternate Start - Live A Deviant Life](https://www.loverslab.com/files/file/20286-alternate-start-live-a-deviant-life-lich-edition/)

- ## ⚠️ Important Compatibility Note
To function correctly, this mod uses internal identifiers (FormIDs) of items from *Devious Interests*. While this is a standard modding practice, please note: if future major updates to DI change these internal item IDs, a minor update to this integration mod may be required. It is highly recommended to keep both mods up to date.
