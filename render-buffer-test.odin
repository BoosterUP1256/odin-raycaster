package main

import rl "vendor:raylib"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Render Buffer Test")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        framebuffer := rl.LoadRenderTexture(SCREEN_HEIGHT, SCREEN_HEIGHT)

        rl.BeginDrawing()
        rl.EndDrawing()
    }
}