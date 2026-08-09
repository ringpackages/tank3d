/*
**  globals.ring
**  All global variables for 3D Tank Battle - Ultimate Edition
*/

// =============================================================
// Sound & Music Resources
// =============================================================

sndFire         = NULL
sndHitWall      = NULL
sndExplosion    = NULL
sndPowerup      = NULL
sndPlayerDeath  = NULL
sndSteelHit     = NULL
sndBrickBreak   = NULL
sndLevelClear   = NULL
sndGameOver     = NULL
sndEnemyHit     = NULL
sndBomb         = NULL
sndEngine       = NULL
sndVictory      = NULL
musMenu         = NULL
musBattle       = NULL
musicPlaying    = 0     // 0=none, 1=menu, 2=battle

// =============================================================
// Global Variables
// =============================================================

gameState       = ST_MENU
level           = 1
maxLevel        = 12
menuSelectedLevel = 1
menuLastHover     = -1   // tracks last hovered menu item; -1 = none
menuLastMouseX    = -1   // tracks last mouse X to detect movement
menuLastMouseY    = -1   // tracks last mouse Y to detect movement
menuPressX        = -1   // mouse X when left button was first pressed
menuPressY        = -1   // mouse Y when left button was first pressed
menuPressHover    = -1   // hovered item index at press time
quitGame        = false

// Combined welcome + stage-select screen layout (computed by
// tank_computeMenuLayout; shared between tank_drawMenu and
// tank_handleMenuInput so the drawn geometry and the hit-testing
// geometry can never drift apart).
tank_titleSz=0 tank_titleY=0
tank_ctrlSz=0  tank_ctrlY1=0  tank_ctrlY2=0
tank_hsSz=0    tank_hsY=0
tank_selLblSz=0 tank_selLblY=0
tank_cardW=0 tank_cardH=0 tank_gapX=0 tank_gapY=0
tank_stgSz=0
tank_startX=0 tank_startY=0 tank_gridH=0
tank_btnLblSz=0 tank_btnW=0 tank_btnH=0 tank_btnX=0 tank_btnY=0
score           = 0
lives           = 3
highScore       = 0

// Grid
tiles           = []

// Player tank
px = 13.5
py = 1.0
pdir = DIR_UP
palive = true
pshield = 0.0
pspeedBoost = 0.0
pAnimTime = 0.0
pMoveAnim = 0.0
pFireCooldown = 0.0

// Player bullets
pbullets = []

// Enemy tanks: [x, y, dir, speed, alive, hp, type, animT, fireTimer, moveTimer, frozen, stealthTimer, visible]
enemies = []
enemySpawnTimer = 0.0
enemiesLeft = 0
enemiesKilled = 0

// Enemy bullets
ebullets = []

// Explosions: [x, y, timer, maxTime, size]
explosions = []

// Power-ups: [x, y, type, timer, active]
powerups = []

// Particles: [x, y, z, vx, vy, vz, life, maxLife, r, g, b, size]
particles = []

// Spawn points for enemies (top of map)
espawnX = [4.0, 13.0, 22.0]
espawnIdx = 1

// Base position
baseR = 25
baseC = 13

// Camera
camMode = CAM_CLOSE
cam = NULL

// Animation
animTime = 0.0
levelUpTimer = 0.0
gameOverTimer = 0.0

// Combo system
comboCount = 0
comboTimer = 0.0
comboDuration = 3.0
lastComboText = ""
comboDisplayTimer = 0.0

// Screen shake
shakeIntensity = 0.0
shakeDuration = 0.0
shakeTimer = 0.0

// Global freeze & lava damage
globalFreezeTimer = 0.0
lavaDamageTimer = 0.0

// Difficulty scaling
levelEnemyCount = 0
levelMaxOnScreen = 0

// Stats
totalKills = 0
totalShotsFired = 0
accuracyHits = 0
