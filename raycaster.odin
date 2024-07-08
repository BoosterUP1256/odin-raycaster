package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

MAP_WIDTH :: 24
MAP_HEIGHT :: 24
SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

worldMap := [MAP_WIDTH][MAP_HEIGHT]int{ 
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}

main :: proc() {
    // declare variables
    posX, posY: f64 = 22.0, 12.0
    dirX, dirY: f64 = -1.0, 0.0
    planeX, planeY: f64 = 0.0, 0.66

    // rest of main funciton
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Raycaster")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        for x := 0; x < SCREEN_WIDTH; x += 1 {
            // calculate ray position and direction
            cameraX: f64 = 2 * f64(x) / f64(SCREEN_WIDTH) - 1
            rayDirX: f64 = dirX + planeX * cameraX
            rayDirY: f64 = dirY + planeY * cameraX

            // which box of the map we're in
            mapX := int(posX)
            mapY := int(posY)

            // length of ray from current position to next x or y-side
            sideDistX: f64
            sideDistY: f64

            // length of ray from one x or y-side to next x or y-side
            deltaDistX: f64 = (rayDirX == 0) ? 1e30 : abs(1 / rayDirX)
            deltaDistY: f64 = (rayDirY == 0) ? 1e30 : abs(1 / rayDirY)
            perpWallDist: f64

            // what direction to step in x or y-direction (either +1 or -1)
            stepX: int
            stepY: int

            hit: int = 0    // was there a wall hit?
            side: int   // was a NS or a EW wall hit?

            // calculate step and initial sideDist
            if rayDirX < 0 {
                stepX = -1
                sideDistX = (posX - f64(mapX)) * deltaDistX
            } else {
                stepX = 1
                sideDistX = (f64(mapX) + 1.0 - posX) * deltaDistX
            }

            if rayDirY < 0 {
                stepY = -1
                sideDistY = (posY - f64(mapY)) * deltaDistY
            } else {
                stepY = 1
                sideDistY = (f64(mapY) + 1.0 - posY) * deltaDistY
            }

            // perform DDA
            for hit == 0 {
                // jump to next map square, either in x-direction, or in y-direction
                if sideDistX < sideDistY {
                    sideDistX += deltaDistX
                    mapX += stepX
                    side = 0
                } else {
                    sideDistY += deltaDistY
                    mapY += stepY
                    side = 1
                }

                // check if ray has hit a wall
                if worldMap[mapX][mapY] > 0 { hit = 1 }
            }

            // calculate distance projected on camera direction (Euclidean distance would give fisheye effect!)
            if side == 0 { perpWallDist = sideDistX - deltaDistX }
            else         { perpWallDist = sideDistY - deltaDistY }

            // calculate height of line to draw on screen
            lineHeight: int = int(SCREEN_HEIGHT / perpWallDist)

            // calculate lowest and highest pixel to fill in current stripe
            drawStart: int = -lineHeight / 2 + SCREEN_HEIGHT / 2
            if drawStart < 0 { drawStart = 0 }
            drawEnd: int = lineHeight / 2 + SCREEN_HEIGHT / 2
            if drawEnd >= SCREEN_HEIGHT { drawEnd = SCREEN_HEIGHT - 1 }

            // choose wall color
            color: rl.Color
            switch worldMap[mapX][mapY] {
                case 1: color = rl.RED
                case 2: color = rl.GREEN
                case 3: color = rl.BLUE
                case 4: color = rl.WHITE
                case: color = rl.YELLOW
            }

            // give x and y sides different brightness
            if side == 1 { color = color / 2; }

            // draw the pixels of the stripe as a vertical line
            rl.DrawLine(i32(x), i32(drawStart), i32(x), i32(drawEnd), color)
        }
        rl.EndDrawing()

        // timing for input and FPS counter
        frameTime: f64 = f64(rl.GetFrameTime())
        fmt.println(rl.GetFPS())

        // speed modifiers
        moveSpeed: f64 = frameTime * 5.0    // the constant value is in squares/second
        rotSpeed: f64 = frameTime * 3.0     // the constant value is in radians/second

        // move forward if no wall in front of you
        if rl.IsKeyDown(rl.KeyboardKey.UP) {
            if worldMap[int(posX + dirX * moveSpeed)][int(posY)] == 0 { posX += dirX * moveSpeed }
            if worldMap[int(posX)][int(posY + dirY * moveSpeed)] == 0 { posY += dirY * moveSpeed }
        }

        // move backwards if no wall behind you
        if rl.IsKeyDown(rl.KeyboardKey.DOWN)
        {
            if worldMap[int(posX - dirX * moveSpeed)][int(posY)] == 0 { posX -= dirX * moveSpeed }
            if worldMap[int(posX)][int(posY - dirY * moveSpeed)] == 0 { posY -= dirY * moveSpeed }
        }

        // rotate to the right
        if rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
            // both camera direction and camera plane must be rotated
            oldDirX := dirX
            dirX = dirX * math.cos(-rotSpeed) - dirY * math.sin(-rotSpeed)
            dirY = oldDirX * math.sin(-rotSpeed) + dirY * math.cos(-rotSpeed)
            oldPlaneX := planeX
            planeX = planeX * math.cos(-rotSpeed) - planeY * math.sin(-rotSpeed)
            planeY = oldPlaneX * math.sin(-rotSpeed) + planeY * math.cos(-rotSpeed)
        }

        // rotate to the left
        if rl.IsKeyDown(rl.KeyboardKey.LEFT) {
            // both camera direction and camera plane must be rotated
            oldDirX := dirX
            dirX = dirX * math.cos(rotSpeed) - dirY * math.sin(rotSpeed);
            dirY = oldDirX * math.sin(rotSpeed) + dirY * math.cos(rotSpeed);
            oldPlaneX := planeX;
            planeX = planeX * math.cos(rotSpeed) - planeY * math.sin(rotSpeed);
            planeY = oldPlaneX * math.sin(rotSpeed) + planeY * math.cos(rotSpeed);
        }
    }
}