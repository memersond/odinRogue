package Game

import Log "core:log"
import Ray "vendor:raylib"
import Entity "src/entity"
import SpriteManager "src/spriteManager"
import InputManager "src/inputManager"
import Action "src/action"

main :: proc() {
  //setup logging

  context.logger = Log.create_console_logger() 

  TILE_SIZE :: 16


  // Window management
  windowWidth :: 1920
  windowHeight :: 1080
  Ray.InitWindow(windowWidth, windowHeight, "Game Window")

  defer Ray.CloseWindow()
  
  spriteManager : SpriteManager.SpriteManager
  
  SpriteManager.init(&spriteManager) // No need to unload, it'll happen when the program closes. 
  
  player := Entity.Entity {
    textureId = SpriteManager.getHandle(&spriteManager, .Player),
    x = 0,
    y = 0
  }

  inputManager : InputManager.InputManager
  InputManager.init(&inputManager)

  ZOOM_STEP :: 0.25
  ZOOM_MIN :: 1.0
  ZOOM_MAX :: 10.0

  camera := Ray.Camera2D{
    target   = {0, 0},
    offset   = {0, 0},
    rotation = 0,
    zoom     = 2.0,
  }

  for (!Ray.WindowShouldClose()){

    InputManager.update(&inputManager)

    camera.zoom += inputManager.mouse_scroll * ZOOM_STEP
    camera.zoom = clamp(camera.zoom, ZOOM_MIN, ZOOM_MAX)

    if InputManager.isPressed(&inputManager, .MoveUp) {
      Action.execute(Action.Movement{entity = &player, dx = 0, dy = -1})
    }
    if InputManager.isPressed(&inputManager, .MoveDown) {
      Action.execute(Action.Movement{entity = &player, dx = 0, dy = 1})
    }
    if InputManager.isPressed(&inputManager, .MoveLeft) {
      Action.execute(Action.Movement{entity = &player, dx = -1, dy = 0})
    }
    if InputManager.isPressed(&inputManager, .MoveRight) {
      Action.execute(Action.Movement{entity = &player, dx = 1, dy = 0})
    }

    Ray.BeginDrawing()

    Ray.ClearBackground(Ray.BLACK)

    Ray.BeginMode2D(camera)
    SpriteManager.drawSprite(&spriteManager, player.textureId, f32(player.x), f32(player.y))
    Ray.EndMode2D()

    Ray.DrawText("Hello", 25, 25, 20, Ray.WHITE)

    Ray.EndDrawing()
  }

}