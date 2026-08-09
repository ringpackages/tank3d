/*
**  tank3d_hud.ring
**  HUD, minimap, and game state overlays (title, pause, game over, victory, level up)
*/

// =============================================================
// HUD
// =============================================================

func tank_drawHUD
    // Top bar background
    DrawRectangle(0, 0, SCREEN_W, 55, RAYLIBColor(0, 0, 0, 210))
    DrawRectangle(0, 55, SCREEN_W, 2, RAYLIBColor(200, 160, 40, 255))

    // Left section: Score & High Score
    DrawText("SCORE", 15, 4, 12, RAYLIBColor(160, 160, 160, 200))
    DrawText(string(score), 15, 18, 22, RAYLIBColor(255, 255, 255, 255))
    if highScore > 0
        DrawText("HI:" + string(highScore), 15, 40, 12, RAYLIBColor(200, 180, 80, 180))
    ok

    // Center: Stage + Enemies remaining
    stgTxt = "STAGE " + string(level)
    stgW = MeasureText(stgTxt, 22)
    isBoss = (level = 4 or level = 8 or level = 12)
    stgClr = RAYLIBColor(255, 220, 50, 255)
    if isBoss stgClr = RAYLIBColor(255, 60, 60, 255) ok
    DrawText(stgTxt, floor(SCREEN_W/2 - stgW/2), 6, 22, stgClr)

    total = enemiesLeft
    nEnemies = len(enemies)
    for e = 1 to nEnemies
        if enemies[e][5] total += 1 ok
    next
    enTxt = "Enemies: " + string(total)
    enW = MeasureText(enTxt, 12)
    DrawText(enTxt, floor(SCREEN_W/2 - enW/2), 28, 12,
             RAYLIBColor(255, 100, 80, 220))

    // Right section: Lives
    DrawText("LIVES", SCREEN_W - 170, 6, 14, RAYLIBColor(160, 160, 160, 200))
    for i = 1 to lives
        lx = SCREEN_W - 170 + (i - 1) * 30
        DrawRectangle(lx, 28, 20, 12, RAYLIBColor(180, 160, 40, 255))
        DrawRectangle(lx + 6, 22, 8, 8, RAYLIBColor(160, 140, 30, 255))
        DrawRectangle(lx + 8, 18, 4, 6, RAYLIBColor(140, 120, 25, 255))
    next

    // Power-up indicators
    indY = SCREEN_H - 80
    if pshield > 0
        DrawText("[SHIELD " + string(floor(pshield)) + "s]", 15, indY, 18,
                 RAYLIBColor(100, 180, 255, 255))
        indY -= 22
    ok
    if pspeedBoost > 0
        DrawText("[SPEED " + string(floor(pspeedBoost)) + "s]", 15, indY, 18,
                 RAYLIBColor(255, 220, 50, 255))
        indY -= 22
    ok
    if globalFreezeTimer > 0
        DrawText("[FREEZE " + string(floor(globalFreezeTimer)) + "s]", 15, indY, 18,
                 RAYLIBColor(50, 220, 255, 255))
    ok

    // Combo display
    if comboDisplayTimer > 0
        cAlpha = floor((comboDisplayTimer / 2.0) * 255)
        if cAlpha > 255 cAlpha = 255 ok
        cW = MeasureText(lastComboText, 30)
        DrawText(lastComboText, floor(SCREEN_W/2 - cW/2), 90, 30,
                 RAYLIBColor(255, 200, 50, cAlpha))
    ok

    // State overlays
    if gameState = ST_MENU
        tank_drawMenu()
        return
    ok

    if gameState = ST_PAUSED
        DrawRectangle(0, 0, SCREEN_W, SCREEN_H, RAYLIBColor(0, 0, 0, 160))
        pTxt = "PAUSED"
        DrawText(pTxt, floor(SCREEN_W/2 - MeasureText(pTxt, 48) / 2),
                 floor(SCREEN_H/2 - 24), 48, RAYLIBColor(255, 255, 255, 255))
    ok

    if gameState = ST_GAMEOVER
        DrawRectangle(0, 0, SCREEN_W, SCREEN_H, RAYLIBColor(0, 0, 0, 200))
        goTxt = "GAME OVER"
        DrawText(goTxt, floor(SCREEN_W/2 - MeasureText(goTxt, 52) / 2),
                 floor(SCREEN_H/2 - 70), 52, RAYLIBColor(255, 40, 40, 255))
        sTxt = "Final Score: " + string(score)
        DrawText(sTxt, floor(SCREEN_W/2 - MeasureText(sTxt, 26) / 2),
                 floor(SCREEN_H/2 - 10), 26, RAYLIBColor(255, 200, 100, 255))
        // Stats
        statTxt = "Kills: " + string(totalKills) + "  |  Shots: " + string(totalShotsFired)
        DrawText(statTxt, floor(SCREEN_W/2 - MeasureText(statTxt, 16) / 2),
                 floor(SCREEN_H/2 + 25), 16, RAYLIBColor(180, 180, 180, 200))
        if totalShotsFired > 0
            acc = floor((accuracyHits * 100) / totalShotsFired)
            accTxt = "Accuracy: " + string(acc) + "%"
            DrawText(accTxt, floor(SCREEN_W/2 - MeasureText(accTxt, 16) / 2),
                     floor(SCREEN_H/2 + 45), 16, RAYLIBColor(180, 180, 180, 200))
        ok
        DrawText("Press ENTER to Return",
                 floor(SCREEN_W/2 - 110), floor(SCREEN_H/2 + 75), 20,
                 RAYLIBColor(200, 200, 200, 200))
    ok

    if gameState = ST_WON
        DrawRectangle(0, 0, SCREEN_W, SCREEN_H, RAYLIBColor(0, 0, 0, 200))
        wTxt = "VICTORY!"
        DrawText(wTxt, floor(SCREEN_W/2 - MeasureText(wTxt, 56) / 2),
                 floor(SCREEN_H/2 - 80), 56, RAYLIBColor(255, 220, 50, 255))
        sTxt2 = "Final Score: " + string(score)
        DrawText(sTxt2, floor(SCREEN_W/2 - MeasureText(sTxt2, 28) / 2),
                 floor(SCREEN_H/2 - 15), 28, RAYLIBColor(255, 255, 200, 255))
        DrawText("All 12 stages cleared!",
                 floor(SCREEN_W/2 - 100), floor(SCREEN_H/2 + 20), 22,
                 RAYLIBColor(200, 200, 200, 220))
        // Stats
        statTxt = "Total Kills: " + string(totalKills) + "  |  Shots Fired: " + string(totalShotsFired)
        DrawText(statTxt, floor(SCREEN_W/2 - MeasureText(statTxt, 16) / 2),
                 floor(SCREEN_H/2 + 55), 16, RAYLIBColor(180, 180, 180, 200))
        if totalShotsFired > 0
            acc = floor((accuracyHits * 100) / totalShotsFired)
            accTxt = "Accuracy: " + string(acc) + "%"
            DrawText(accTxt, floor(SCREEN_W/2 - MeasureText(accTxt, 16) / 2),
                     floor(SCREEN_H/2 + 75), 16, RAYLIBColor(180, 180, 180, 200))
        ok
        if score > highScore highScore = score ok
        DrawText("Press ENTER to Return",
                 floor(SCREEN_W/2 - 110), floor(SCREEN_H/2 + 105), 20,
                 RAYLIBColor(180, 180, 180, 180))
    ok

    if gameState = ST_LEVELUP
        prog = 1.0 - (levelUpTimer / 2.5)
        alpha = floor(prog * 255)
        if alpha > 255 alpha = 255 ok
        DrawRectangle(0, 0, SCREEN_W, SCREEN_H, RAYLIBColor(0, 0, 0, floor(alpha * 0.6)))
        lTxt = "STAGE " + string(level) + " CLEAR!"
        DrawText(lTxt, floor(SCREEN_W/2 - MeasureText(lTxt, 44) / 2),
                 floor(SCREEN_H/2 - 35), 44, RAYLIBColor(255, 220, 50, alpha))
        bonusTxt = "Bonus: +" + string(500 + (level - 1) * 100)
        DrawText(bonusTxt, floor(SCREEN_W/2 - MeasureText(bonusTxt, 20) / 2),
                 floor(SCREEN_H/2 + 15), 20, RAYLIBColor(200, 200, 200, alpha))
        if level < maxLevel
            nextIsBoss = (level + 1 = 4 or level + 1 = 8 or level + 1 = 12)
            if nextIsBoss
                warnTxt = "!! BOSS BATTLE APPROACHING !!"
                wPulse = floor(sin(animTime * 5.0) * 80 + 175)
                DrawText(warnTxt, floor(SCREEN_W/2 - MeasureText(warnTxt, 22) / 2),
                         floor(SCREEN_H/2 + 45), 22, RAYLIBColor(255, 50, 50, wPulse))
            ok
        ok
    ok

    // FPS
    // DrawFPS(SCREEN_W - 80, 50)

// =============================================================
// Combined Welcome + Stage-Select Screen
// =============================================================

# Decorative gradient border frame around the welcome screen, in the style of
# povc.ring's notification borders (drawFancyBorder) but drawn with plain
# raylib primitives instead of the border PNG: a thin gradient band runs
# around the whole perimeter, with a soft outer glow line and inner highlight
# line on either side of it.
func drawScreenBorder gradCol1, gradCol2, outerCol, innerCol
    inset = 14   thick = 5
    DrawRectangleGradientH(inset, inset, SCREEN_W-inset*2, thick, gradCol1, gradCol2)
    DrawRectangleGradientH(inset, SCREEN_H-inset-thick, SCREEN_W-inset*2, thick, gradCol2, gradCol1)
    DrawRectangleGradientV(inset, inset, thick, SCREEN_H-inset*2, gradCol1, gradCol2)
    DrawRectangleGradientV(SCREEN_W-inset-thick, inset, thick, SCREEN_H-inset*2, gradCol1, gradCol2)
    DrawRectangleLines(inset-3, inset-3, SCREEN_W-(inset-3)*2, SCREEN_H-(inset-3)*2, outerCol)
    DrawRectangleLines(inset+thick+4, inset+thick+4, SCREEN_W-(inset+thick+4)*2, SCREEN_H-(inset+thick+4)*2, innerCol)

# Shared layout math for the combined welcome/stage-select screen, used by
# both tank_drawMenu (drawing) and tank_handleMenuInput (mouse hit-testing)
# so they can never drift apart. Fonts scale with the monitor's actual
# resolution (baseline = 700px tall), and the whole block -- title, subtitle,
# guidelines, stage grid, close button -- is vertically centered based on its
# real computed content height.
func tank_computeMenuLayout
    mY = SCREEN_H / 700.0

    tank_titleSz = max(34, floor(74*mY))
    tank_ctrlSz  = max(16, floor(22*mY))
    tank_hsSz    = max(13, floor(18*mY))
    tank_selLblSz= max(15, floor(22*mY))

    tank_btnLblSz = max(15, floor(22*mY))
    tank_btnW = max(floor(100*mY), MeasureText("CLOSE GAME", tank_btnLblSz) + 30)
    tank_btnH = floor(50*mY)

    tank_stgSz  = max(18, floor(28*mY))
    tank_cardW = max(floor(90*mY), MeasureText("12", tank_stgSz) + 30)
    tank_cardH = tank_btnH        // same height as the Close button
    tank_gapX  = floor(20*mY)
    tank_gapY  = floor(18*mY)

    gap1 = floor(20*mY)   // title -> controls
    ctrlPitch = floor(34*mY)
    gap5 = floor(14*mY)   // controls block -> high score (if any)
    gap6 = floor(16*mY)   // -> "SELECT STAGE" label
    gap7 = floor(10*mY)   // label -> grid
    gap8 = floor(14*mY)   // grid -> close button

    titleBlockH = tank_titleSz + floor(10*mY)
    ctrlBlockH  = ctrlPitch + tank_ctrlSz   // 2 lines: controls + power-up legend
    hsBlockH    = tank_hsSz
    selLblBlockH = tank_selLblSz
    tank_gridH = 3 * tank_cardH + 2 * tank_gapY
    btnBlockH  = tank_btnH

    contentH = titleBlockH+gap1+ctrlBlockH
    if highScore > 0
        contentH += gap5 + hsBlockH
    ok
    contentH += gap6+selLblBlockH+gap7+tank_gridH+gap8+btnBlockH

    topY = floor((SCREEN_H - contentH) / 2)
    if topY < floor(14*mY)  topY = floor(14*mY)  ok

    tank_titleY = topY
    tank_ctrlY1 = tank_titleY + titleBlockH + gap1
    tank_ctrlY2 = tank_ctrlY1 + ctrlPitch

    y = tank_ctrlY1 + ctrlBlockH
    if highScore > 0
        y += gap5
        tank_hsY = y
        y += hsBlockH
    ok
    y += gap6
    tank_selLblY = y
    y += selLblBlockH + gap7

    tank_startY = y
    y += tank_gridH + gap8
    tank_btnY = y

    totalGridW = 4 * tank_cardW + 3 * tank_gapX
    tank_startX = floor((SCREEN_W - totalGridW) / 2)
    tank_btnX   = floor((SCREEN_W - tank_btnW) / 2)

func tank_drawMenu
    tank_computeMenuLayout()
    DrawTexturePro(tank_menuBackTex,
        Rectangle(0.0, 0.0, tank_menuBackTex.width*1.0, tank_menuBackTex.height*1.0),
        Rectangle(0.0, 0.0, SCREEN_W*1.0, SCREEN_H*1.0),
        Vector2(0.0, 0.0), 0.0, WHITE)

    cols = 4

    // Title (with a gentle wobble/bounce, drop-shadow copy underneath)
    wob = floor(sin(animTime * 2.0) * 8)
    title = "Tank 3D"
    tW = MeasureText(title, tank_titleSz)
    tX = floor((SCREEN_W - tW) / 2)
    DrawText(title, tX + 4, tank_titleY + 4 + wob, tank_titleSz, RAYLIBColor(0, 20, 10, 200))
    DrawText(title, tX, tank_titleY + wob, tank_titleSz, WHITE)

    ctrl1 = "Move: WASD/Arrows   Fire: Space/Enter   Pause: P   Camera: C"
    DrawText(ctrl1, floor((SCREEN_W - MeasureText(ctrl1, tank_ctrlSz)) / 2), tank_ctrlY1,
             tank_ctrlSz, RAYLIBColor(180, 220, 180, 200))

    ctrl2 = "Power-ups: Star=Speed  Shield=Guard  Bomb=Nuke  Freeze=Stop  Life=+1"
    DrawText(ctrl2, floor((SCREEN_W - MeasureText(ctrl2, tank_ctrlSz)) / 2), tank_ctrlY2,
             tank_ctrlSz, RAYLIBColor(180, 220, 180, 200))

    if highScore > 0
        hsTxt = "High Score: " + string(highScore)
        DrawText(hsTxt, floor((SCREEN_W - MeasureText(hsTxt, tank_hsSz)) / 2), tank_hsY,
                 tank_hsSz, RAYLIBColor(180, 220, 180, 200))
    ok

    selLbl = "SELECT STAGE"
    DrawText(selLbl, floor((SCREEN_W - MeasureText(selLbl, tank_selLblSz)) / 2), tank_selLblY,
             tank_selLblSz, RAYLIBColor(180, 220, 180, 200))

    cardW = tank_cardW  cardH = tank_cardH
    gapX  = tank_gapX   gapY  = tank_gapY
    startX = tank_startX  startY = tank_startY

    for i = 1 to maxLevel
        row = floor((i - 1) / cols)
        col = (i - 1) % cols
        cx  = startX + col * (cardW + gapX)
        cy  = startY + row * (cardH + gapY)

        isActive   = (i = menuSelectedLevel)

        if isActive
            DrawRectangleGradientV(cx, cy, cardW, cardH, RAYLIBColor(210, 235, 248, 255), RAYLIBColor(140, 190, 218, 255))
            DrawRectangleLines(cx, cy, cardW, cardH, RAYLIBColor(0, 0, 80, 255))
            cardTextCol = RAYLIBColor(0, 0, 80, 255)
        else
            DrawRectangleGradientV(cx, cy, cardW, cardH, RAYLIBColor(25, 35, 45, 255), RAYLIBColor(12, 18, 25, 255))
            DrawRectangleLines(cx, cy, cardW, cardH, RAYLIBColor(173, 216, 230, 255))
            cardTextCol = RAYLIBColor(173, 216, 230, 255)
        ok

        // Stage number -- the only label on the card
        stgStr = string(i)
        sW     = MeasureText(stgStr, tank_stgSz)
        stgY   = cy + floor((cardH - tank_stgSz) / 2)
        DrawText(stgStr, cx + floor((cardW - sW) / 2), stgY, tank_stgSz, cardTextCol)
    next

    // Close button
    btnW = tank_btnW  btnH = tank_btnH
    btnX = tank_btnX  btnY = tank_btnY

    btnActive = (menuSelectedLevel = CLOSE_BTN)
    if btnActive
        DrawRectangleGradientV(btnX, btnY, btnW, btnH, RAYLIBColor(210, 235, 248, 255), RAYLIBColor(140, 190, 218, 255))
        DrawRectangleLines(btnX, btnY, btnW, btnH, RAYLIBColor(0, 0, 80, 255))
        btnTextCol = RAYLIBColor(0, 0, 80, 255)
    else
        DrawRectangleGradientV(btnX, btnY, btnW, btnH, RAYLIBColor(25, 35, 45, 255), RAYLIBColor(12, 18, 25, 255))
        DrawRectangleLines(btnX, btnY, btnW, btnH, RAYLIBColor(173, 216, 230, 255))
        btnTextCol = RAYLIBColor(173, 216, 230, 255)
    ok
    closeStr = "CLOSE GAME"
    DrawText(closeStr, btnX + floor((btnW - MeasureText(closeStr, tank_btnLblSz)) / 2),
             btnY + floor((btnH - tank_btnLblSz) / 2), tank_btnLblSz, btnTextCol)

    drawScreenBorder(RAYLIBColor(8,60,30,235), RAYLIBColor(3,25,12,235), RAYLIBColor(173,216,230,255), RAYLIBColor(173,216,230,70))

// =============================================================
// Minimap
// =============================================================

func tank_drawMinimap
    // Minimap size and position (bottom-right corner)
    mmSize = 5      // Pixels per cell
    mmW = GRID_W * mmSize
    mmH = GRID_H * mmSize
    mmX = SCREEN_W - mmW - 12
    mmY = SCREEN_H - mmH - 35

    // Background with border
    DrawRectangle(mmX - 2, mmY - 2, mmW + 4, mmH + 4,
                  RAYLIBColor(200, 160, 40, 200))
    DrawRectangle(mmX, mmY, mmW, mmH,
                  RAYLIBColor(0, 0, 0, 220))

    // Draw tiles
    for r = 1 to GRID_H
        for c = 1 to GRID_W
            t = tiles[r][c]
            tx = mmX + (c - 1) * mmSize
            ty = mmY + (r - 1) * mmSize

            if t = T_BRICK
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(180, 100, 30, 255))
            ok
            if t = T_STEEL
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(170, 170, 180, 255))
            ok
            if t = T_WATER
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(30, 70, 160, 255))
            ok
            if t = T_TREES
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(20, 100, 30, 255))
            ok
            if t = T_ICE
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(150, 200, 240, 255))
            ok
            if t = T_BASE
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(255, 220, 50, 255))
            ok
            if t = T_BASEDEAD
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(80, 40, 20, 255))
            ok
            if t = T_LAVA
                DrawRectangle(tx, ty, mmSize, mmSize,
                              RAYLIBColor(220, 80, 10, 255))
            ok
        next
    next

    // Draw player on minimap
    if palive
        // Convert py to grid row directly
        pGridR = floor(py + 0.5)
        pGridC = floor(px + 0.5)
        pmx = mmX + (pGridC - 1) * mmSize
        pmy = mmY + (pGridR - 1) * mmSize
        // Player dot - yellow with flashing
        flash = floor(sin(animTime * 6.0) * 40 + 215)
        DrawRectangle(pmx - 1, pmy - 1, mmSize + 2, mmSize + 2,
                      RAYLIBColor(255, 255, 50, flash))
    ok

    // Draw enemies on minimap
    nEnemies = len(enemies)
    for e = 1 to nEnemies
        if enemies[e][5]
            eGridR = floor(enemies[e][2] + 0.5)
            eGridC = floor(enemies[e][1] + 0.5)
            if eGridR >= 1 and eGridR <= GRID_H and eGridC >= 1 and eGridC <= GRID_W
                emx = mmX + (eGridC - 1) * mmSize
                emy = mmY + (eGridR - 1) * mmSize
                DrawRectangle(emx, emy, mmSize, mmSize,
                              RAYLIBColor(255, 50, 50, 230))
            ok
        ok
    next

    // Draw player bullets
    nPB = len(pbullets)
    for i = 1 to nPB
        if pbullets[i][1]
            bGridR = floor(pbullets[i][3] + 0.5)
            bGridC = floor(pbullets[i][2] + 0.5)
            if bGridR >= 1 and bGridR <= GRID_H and bGridC >= 1 and bGridC <= GRID_W
                bbx = mmX + (bGridC - 1) * mmSize + floor(mmSize / 2)
                bby = mmY + (bGridR - 1) * mmSize + floor(mmSize / 2)
                DrawCircle(bbx, bby, 2, RAYLIBColor(255, 255, 150, 255))
            ok
        ok
    next

    // Draw powerups
    nPU = len(powerups)
    for i = 1 to nPU
        if powerups[i][5]
            puGridR = floor(powerups[i][2] + 0.5)
            puGridC = floor(powerups[i][1] + 0.5)
            if puGridR >= 1 and puGridR <= GRID_H and puGridC >= 1 and puGridC <= GRID_W
                pux = mmX + (puGridC - 1) * mmSize
                puy = mmY + (puGridR - 1) * mmSize
                flash2 = floor(sin(animTime * 5.0) * 80 + 175)
                DrawRectangle(pux, puy, mmSize, mmSize,
                              RAYLIBColor(50, 255, 50, flash2))
            ok
        ok
    next

    // Minimap label
    DrawText("MAP", mmX + mmW / 2 - 12, mmY - 14, 12,
             RAYLIBColor(200, 200, 200, 200))
