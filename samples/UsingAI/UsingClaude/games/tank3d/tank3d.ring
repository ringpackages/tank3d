/*
**  3D Tank Battle - Ultimate Edition - Using RingRayLib
**  =====================================================
**  Classic Battle City in full 3D - Remastered!
**
**  Controls:
**    Arrow Keys / WASD  -  Move tank
**    Space / Enter      -  Fire cannon
**    C                  -  Cycle camera
**    P                  -  Pause
**    R                  -  Restart level
**    N / B              -  Next / Previous level
**    ESC                -  Exit
**
**  Ultimate Edition Features:
**    - 12 levels with unique themes & increasing difficulty
**    - Boss battles every 4th level (Stages 4, 8, 12)
**    - 6 enemy types: Basic, Normal, Fast, Heavy, Stealth, Boss
**    - 5 power-ups: Star, Shield, Bomb, Freeze, Extra Life
**    - Lava hazard terrain (damages tanks!)
**    - Combo scoring (chain kills for score multipliers)
**    - Screen shake on explosions
**    - Difficulty scaling (more/faster enemies per level)
**    - High score tracking
**    - Level names and boss approach warnings
**
**  Sound files required (in sounds/ folder):
**    fire.wav, hit_wall.wav, explosion.wav,
**    powerup.wav, player_death.wav, steel_hit.wav,
**    brick_break.wav, level_clear.wav, game_over.wav,
**    enemy_hit.wav, bomb.wav, engine.wav, victory.wav,
**    menu_music.wav, battle_music.wav
*/

// =============================================================
// Load Source Files
// =============================================================

load "raylib.ring"
load "constants.ring"
load "levels.ring"
load "input.ring"
load "update.ring"
load "explosions.ring"
load "powerups.ring"
load "camera.ring"
load "draw3d.ring"
load "hud.ring"
load "music.ring"
load "globals.ring"

// =============================================================
// Initialize Window & Fullscreen
// =============================================================

monIdx = GetCurrentMonitor()
monW = GetMonitorWidth(monIdx)
monH = GetMonitorHeight(monIdx)

InitWindow(monW, monH, "Prince of Vibe Code (Tank3D)")
SetTargetFPS(60)
SetExitKey(0)   // disable ESC as a quit key; handled manually
togglefullscreen()
BeginDrawing()
ClearBackground(RAYLIBColor(0, 0, 0, 255))
EndDrawing()
 
SCREEN_W = GetScreenWidth()
SCREEN_H = GetScreenHeight()

// Menu background (must load after window init - OpenGL context required)
tank_menuBackTex = LoadTexture("image/menuback.png")

// Ground/wall tiles are viewed at a steep, ever-changing angle (see
// camera.ring), which aliases badly under plain nearest-neighbor sampling -
// worst when moving toward/away from something (depth-direction minification)
// rather than side to side, since that's when the texel-to-pixel ratio swings
// most. Real mipmaps + trilinear (mode 2; not exposed as a named constant in
// this raylib binding) fixes that. Anisotropic (mode 4) was tried for the
// remaining grazing-angle flicker on wall side faces under the near-top-down
// camera, but made flickering worse everywhere on this GPU/driver - reverted.
// Note: this binding caches texture fields on the Ring side, so
// GenTextureMipmaps alone doesn't stick - .refresh() is required afterward or
// SetTextureFilter silently falls back to bilinear (confirmed by testing).

// Destructible-wall texture: one reusable textured cube model, drawn at
// each brick tile's position (learned from linedrawing3d's cubicmap model:
// GenMesh + LoadModelFromMesh + SetModelMaterialTexture, since DrawCubeTexture
// isn't available in this raylib binding).
tank_wallTex   = LoadTexture("image/wall.png")
GenTextureMipmaps(tank_wallTex)
tank_wallTex.refresh()
SetTextureFilter(tank_wallTex, 2)
// Slightly wider than CELL_SZ so adjacent wall tiles overlap by a hair
// instead of touching exactly, which removes the ambiguous zero-width
// boundary that flickers (a rasterization seam, not a texture issue) -
// invisible since the wall is opaque and the overlap is tiny.
tank_wallMesh  = GenMeshCube(CELL_SZ * 1.02, 0.58, CELL_SZ * 1.02)
tank_wallModel = LoadModelFromMesh(tank_wallMesh)
SetModelMaterialTexture(tank_wallModel, 0, MAP_DIFFUSE, tank_wallTex)

// Steel (indestructible) wall texture - same reusable-model approach
tank_steelTex   = LoadTexture("image/stell.png")
GenTextureMipmaps(tank_steelTex)
tank_steelTex.refresh()
SetTextureFilter(tank_steelTex, 2)
tank_steelMesh  = GenMeshCube(CELL_SZ * 1.02, 0.68, CELL_SZ * 1.02)
tank_steelModel = LoadModelFromMesh(tank_steelMesh)
SetModelMaterialTexture(tank_steelModel, 0, MAP_DIFFUSE, tank_steelTex)

// Ground floor texture - reusable per-cell model, drawn once per grid cell
// so the texture repeats across the floor instead of being stretched over it.
// It's tiled across all 676 cells and seen at a shallow angle most of the
// game, so this is likely the biggest contributor to the reported flicker.
tank_groundTex   = LoadTexture("image/ground.png")
GenTextureMipmaps(tank_groundTex)
tank_groundTex.refresh()
SetTextureFilter(tank_groundTex, 2)
tank_groundMesh  = GenMeshCube(CELL_SZ, 0.15, CELL_SZ)
tank_groundModel = LoadModelFromMesh(tank_groundMesh)
SetModelMaterialTexture(tank_groundModel, 0, MAP_DIFFUSE, tank_groundTex)

// Water tile texture - reusable per-cell model
tank_waterTex   = LoadTexture("image/water.png")
GenTextureMipmaps(tank_waterTex)
tank_waterTex.refresh()
SetTextureFilter(tank_waterTex, 2)
tank_waterMesh  = GenMeshCube(CELL_SZ, 0.10, CELL_SZ)
tank_waterModel = LoadModelFromMesh(tank_waterMesh)
SetModelMaterialTexture(tank_waterModel, 0, MAP_DIFFUSE, tank_waterTex)

// Initialize audio
tank_initAudio()

cam = Camera3D(
    GRID_W/2, 30, GRID_H/2 + 5,
    GRID_W/2, 0, GRID_H/2,
    0, 1, 0,
    45,
    0
)

tank_loadLevel(level)

while !WindowShouldClose() and !quitGame
    dt = GetFrameTime()
    if dt > 0.05 dt = 0.05 ok

    animTime += dt

    // Update music stream
    tank_updateMusic()

    tank_handleInput(dt)
    tank_update(dt)

    // Update screen shake
    if shakeTimer > 0
        shakeTimer -= dt
        if shakeTimer < 0 shakeTimer = 0 ok
    ok

    BeginDrawing()
        // ClearBackground also resets the depth buffer each frame (required
        // for correct 3D occlusion) - the color it clears to doesn't matter
        // for gameplay since the gradient below repaints every pixel anyway.
        ClearBackground(RAYLIBColor(10, 10, 10, 255))
        if gameState != ST_MENU
            // Sky gradient (same colors as platform2d's parallax background)
            DrawRectangleGradientV(0, 0, SCREEN_W, SCREEN_H / 2,
                RAYLIBColor(20, 20, 50, 255), RAYLIBColor(40, 35, 70, 255))
            DrawRectangleGradientV(0, SCREEN_H / 2, SCREEN_W, SCREEN_H / 2,
                RAYLIBColor(40, 35, 70, 255), RAYLIBColor(16, 16, 32, 255))
        ok
        if gameState != ST_MENU
            tank_updateCamera()
            BeginMode3D(cam)
                tank_drawFloor()
                tank_drawWalls3D()
                tank_drawBase3D()
                tank_drawTrees3D()
                tank_drawLava3D()
                tank_drawPlayer3D()
                tank_drawEnemies3D()
                tank_drawBullets3D()
                tank_drawExplosions3D()
                tank_drawPowerups3D()
                tank_drawParticles3D()
            EndMode3D()
        ok
        tank_drawHUD()
        if gameState != ST_MENU
            tank_drawMinimap()
        ok
    EndDrawing()
end

// Cleanup audio
tank_cleanupAudio()

UnloadTexture(tank_menuBackTex)
UnloadModel(tank_wallModel)
UnloadTexture(tank_wallTex)
UnloadModel(tank_steelModel)
UnloadTexture(tank_steelTex)
UnloadModel(tank_groundModel)
UnloadTexture(tank_groundTex)
UnloadModel(tank_waterModel)
UnloadTexture(tank_waterTex)

CloseWindow()
