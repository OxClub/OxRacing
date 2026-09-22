# OxRacing

OxRacing is a 3D mobile racing game built with Godot 4.

## Build system

Android builds are handled by GitHub Actions.

Push to `main` and GitHub Actions will build a debug APK.

You can also manually start the workflow from:

Actions → Build OxRacing Android → Run workflow

## Structure

- `scenes/` - Godot scenes
- `scripts/` - GDScript
- `assets/` - game assets
- `data/` - game data
- `.github/workflows/` - GitHub Actions

## Development roadmap

1. Godot project
2. Android CI
3. Racing track
4. Player car
5. Camera
6. Touch controls
7. AI opponents
8. Checkpoints and laps
9. Race HUD
10. Garage
11. Car upgrades
12. Coins/rewards
13. Ads
14. Google Play release
