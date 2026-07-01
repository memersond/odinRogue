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

  for (!Ray.WindowShouldClose()){

    InputManager.update(&inputManager)

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

    Ray.DrawText("Hello", 25, 25, 20, Ray.WHITE)

    SpriteManager.drawSprite(&spriteManager, player.textureId, f32(player.x), f32(player.y))

    Ray.EndDrawing()
  }

}