package Game

import "core:log"
import "vendor:raylib"
import "src/entity"
import "src/resourceManager"

main :: proc() {
  //setup logging

  context.logger = log.create_console_logger() 


  // Window management
  windowWidth :: 1920
  windowHeight :: 1080
  raylib.InitWindow(windowWidth, windowHeight, "Game Window")

  player := entity.Entity {
    x = 0,
    y = 0
  }

  defer raylib.CloseWindow()

  for (!raylib.WindowShouldClose()){


    raylib.BeginDrawing()

    raylib.ClearBackground(raylib.BLACK)

    raylib.DrawText("Hello", 25, 25, 20, raylib.WHITE)

    raylib.EndDrawing()
  }

}