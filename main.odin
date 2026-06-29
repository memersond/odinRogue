package Game

import Log "core:log"
import Ray "vendor:raylib"
import Entity "src/entity"
import SpriteManager "src/spriteManager"

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
  
  for (!Ray.WindowShouldClose()){

    Ray.BeginDrawing()

    Ray.ClearBackground(Ray.BLACK)

    Ray.DrawText("Hello", 25, 25, 20, Ray.WHITE)

    SpriteManager.drawSprite(&spriteManager, player.textureId, 100, 100)

    Ray.EndDrawing()
  }

}