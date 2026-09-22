# OxRacing MVP

Script-generated Unity 6 mobile racing-game foundation.

## Included
- Android build pipeline for GitHub Actions
- One playable arcade car
- Rigidbody-based arcade physics
- Nitro boost
- Drift assist
- Touch controls
- Tilt steering
- Gamepad support through Unity Input System
- Chase camera
- Lap/checkpoint race manager
- Simple waypoint AI
- Local JSON save system
- Garage/upgrades foundation
- Offline-first architecture
- Mobile quality settings

## Build
The GitHub Actions workflow uses GameCI and Unity 6 LTS (`6000.0.43f1`).

Required GitHub repository secret:
`UNITY_LICENSE`

For an Android build, push the repository and open:
Actions → OxRacing Android Build

The workflow uploads an APK artifact.

## Important
This MVP intentionally uses primitive/procedural geometry and placeholder UI so the project can be built before importing commercial 3D assets. Replace the placeholder car/track art later without changing the gameplay architecture.
