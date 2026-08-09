/*
**  tank3d_input.ring
**  Input handling and movement collision checking
*/

// =============================================================
// Input Handling
// =============================================================

func tank_handleInput dt
    if IsKeyPressed(KEY_C)
        camMode = (camMode + 1) % CAM_COUNT
    ok

    if IsKeyPressed(KEY_R)
        tank_loadLevel(level)
        gameState = ST_PLAYING
        return
    ok

    // Level skip keys: N = next level, B = previous level
    if gameState = ST_PLAYING or gameState = ST_PAUSED
        if IsKeyPressed(KEY_N)
            if level < maxLevel
                level += 1
                tank_loadLevel(level)
                gameState = ST_PLAYING
                PlaySound(sndLevelClear)
            ok
            return
        ok
        if IsKeyPressed(KEY_B)
            if level > 1
                level -= 1
                tank_loadLevel(level)
                gameState = ST_PLAYING
                PlaySound(sndLevelClear)
            ok
            return
        ok
    ok

    if gameState = ST_MENU
        tank_handleMenuInput()
        return
    ok

    if gameState = ST_GAMEOVER or gameState = ST_WON
        if IsKeyPressed(KEY_ENTER) or IsKeyPressed(KEY_SPACE)
            gameState = ST_MENU
            ShowCursor()
        ok
        return
    ok

    if gameState = ST_PLAYING
        if IsKeyPressed(KEY_P)
            gameState = ST_PAUSED
            return
        ok
        if IsKeyPressed(KEY_ESCAPE)
            menuSelectedLevel = level
            gameState = ST_MENU
            ShowCursor()
            return
        ok
    ok

    if gameState = ST_PAUSED
        if IsKeyPressed(KEY_P) or IsKeyPressed(KEY_SPACE)
            gameState = ST_PLAYING
            ResumeMusicStream(musBattle)
            musicPlaying = 2
        ok
        return
    ok

    if gameState != ST_PLAYING return ok
    if !palive return ok

    // Tank movement
    moving = false
    spd = PLAYER_SPEED
    if pspeedBoost > 0 spd = spd * 1.5 ok

    if IsKeyDown(KEY_UP) or IsKeyDown(KEY_W)
        pdir = DIR_UP
        moving = true
    ok
    if IsKeyDown(KEY_DOWN) or IsKeyDown(KEY_S)
        pdir = DIR_DOWN
        moving = true
    ok
    if IsKeyDown(KEY_LEFT) or IsKeyDown(KEY_A)
        pdir = DIR_LEFT
        moving = true
    ok
    if IsKeyDown(KEY_RIGHT) or IsKeyDown(KEY_D)
        pdir = DIR_RIGHT
        moving = true
    ok

    if moving
        dx = 0 dy = 0
        if pdir = DIR_UP dy = -1 ok
        if pdir = DIR_DOWN dy = 1 ok
        if pdir = DIR_LEFT dx = -1 ok
        if pdir = DIR_RIGHT dx = 1 ok

        newX = px + dx * spd * dt
        newY = py + dy * spd * dt

        // Collision check (tank occupies ~1.0 unit)
        if tank_canMove(newX, newY, true)
            px = newX
            py = newY
        but tank_canMove(newX, py, true)
            px = newX
        but tank_canMove(px, newY, true)
            py = newY
        ok

        pMoveAnim += dt * 10.0
        // Engine sound when moving
        if !IsSoundPlaying(sndEngine)
            PlaySound(sndEngine)
        ok
    ok

    // Clamp to grid
    if px < 1.5 px = 1.5 ok
    if px > GRID_W - 0.5 px = GRID_W - 0.5 ok
    if py < 1.5 py = 1.5 ok
    if py > GRID_H - 0.5 py = GRID_H - 0.5 ok

    // Fire (with cooldown)
    pFireCooldown -= dt
    if pFireCooldown < 0 pFireCooldown = 0 ok
    if IsKeyPressed(KEY_SPACE) or IsKeyPressed(KEY_ENTER) or IsKeyPressed(KEY_F)
        if pFireCooldown <= 0
            bspd = BULLET_SPEED
            if pspeedBoost > 0 bspd = bspd * 1.3 ok
            add(pbullets, [true, px, py, pdir, bspd])
            tank_muzzleFlash(px, py, pdir)
            PlaySound(sndFire)
            pFireCooldown = 0.25
            totalShotsFired += 1
        ok
    ok

// =============================================================
// Movement Collision Check
// =============================================================

func tank_canMove x, y, isPlayer
    // Tank is about 0.8 wide, check corners
    hw = 0.38   // Half-width
    corners = [
        [x - hw, y - hw],
        [x + hw, y - hw],
        [x - hw, y + hw],
        [x + hw, y + hw]
    ]

    for i = 1 to 4
        cx = corners[i][1]
        cy = corners[i][2]
        gc = floor(cx + 0.5)
        gr = floor(cy + 0.5)
        if gr < 1 or gr > GRID_H or gc < 1 or gc > GRID_W return false ok
        t = tiles[gr][gc]
        if t = T_BRICK or t = T_STEEL or t = T_WATER or t = T_BASE or t = T_BASEDEAD
            return false
        ok
    next

    // Check collision with other tanks
    if isPlayer
        nEnemies = len(enemies)
        for e = 1 to nEnemies
            if enemies[e][5]  // alive
                dx = x - enemies[e][1]
                dy = y - enemies[e][2]
                if dx > -0.85 and dx < 0.85 and dy > -0.85 and dy < 0.85
                    return false
                ok
            ok
        next
    ok

    return true

// =============================================================
// Level-Select Menu Input
// =============================================================

func tank_handleMenuInput
    prevSel = menuSelectedLevel
    cols = 4   // 4 columns × 3 rows = 12 levels

    if IsKeyPressed(KEY_RIGHT) or IsKeyPressed(KEY_D)
        if menuSelectedLevel < maxLevel
            menuSelectedLevel += 1
        ok
    ok
    if IsKeyPressed(KEY_LEFT) or IsKeyPressed(KEY_A)
        if menuSelectedLevel > 1 and menuSelectedLevel != CLOSE_BTN
            menuSelectedLevel -= 1
        ok
    ok
    if IsKeyPressed(KEY_DOWN) or IsKeyPressed(KEY_S)
        if menuSelectedLevel <= maxLevel - cols
            menuSelectedLevel += cols
        but menuSelectedLevel <= maxLevel
            menuSelectedLevel = CLOSE_BTN
        ok
    ok
    if IsKeyPressed(KEY_UP) or IsKeyPressed(KEY_W)
        if menuSelectedLevel = CLOSE_BTN
            menuSelectedLevel = maxLevel - 1   // centre of last row
        but menuSelectedLevel > cols
            menuSelectedLevel -= cols
        ok
    ok

    if IsKeyPressed(KEY_ENTER) or IsKeyPressed(KEY_SPACE)
        if menuSelectedLevel = CLOSE_BTN
            quitGame = true
            return
        ok
        level = menuSelectedLevel
        score = 0
        lives = 3
        totalKills = 0
        totalShotsFired = 0
        accuracyHits = 0
        tank_loadLevel(level)
        gameState = ST_PLAYING
        HideCursor()
        return
    ok

    if IsKeyPressed(KEY_ESCAPE)
        quitGame = true
        return
    ok

    // Mouse hover & click
    tank_computeMenuLayout()
    mx = GetMouseX()
    my = GetMouseY()

    cardW  = tank_cardW
    cardH  = tank_cardH
    gapX   = tank_gapX
    gapY   = tank_gapY
    gridH2 = tank_gridH
    startX = tank_startX
    startY = tank_startY

    // Detect which item the mouse is over this frame
    newHover = -1
    for i = 1 to maxLevel
        row = floor((i - 1) / cols)
        col = (i - 1) % cols
        cx  = startX + col * (cardW + gapX)
        cy  = startY + row * (cardH + gapY)
        if mx >= cx and mx < cx + cardW and my >= cy and my < cy + cardH
            newHover = i
        ok
    next

    // Close button hover
    btnW  = tank_btnW
    btnH  = tank_btnH
    btnX  = tank_btnX
    btnY  = tank_btnY
    if mx >= btnX and mx < btnX + btnW and my >= btnY and my < btnY + btnH
        newHover = CLOSE_BTN
    ok

    // Track press position and which button was under the cursor at press time
    if IsMouseButtonPressed(0)
        menuPressX     = mx
        menuPressY     = my
        menuPressHover = newHover
    ok

    // Sync selection when mouse enters a new item OR moves within the current item
    mouseMoved = (mx != menuLastMouseX or my != menuLastMouseY)
    if newHover >= 0 and (newHover != menuLastHover or mouseMoved)
        menuSelectedLevel = newHover
    ok
    menuLastHover  = newHover
    menuLastMouseX = mx
    menuLastMouseY = my

    // Click fires only when released over the same button that was pressed
    if IsMouseButtonReleased(0) and newHover >= 0 and newHover = menuPressHover
        if menuSelectedLevel = CLOSE_BTN
            quitGame = true
            return
        ok
        level = menuSelectedLevel
        score = 0
        lives = 3
        totalKills = 0
        totalShotsFired = 0
        accuracyHits = 0
        tank_loadLevel(level)
        gameState = ST_PLAYING
        HideCursor()
        return
    ok

    // Play steel_hit sound whenever selection changes
    if menuSelectedLevel != prevSel
        PlaySound(sndSteelHit)
    ok
