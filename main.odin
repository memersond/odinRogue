package Game

import Log "core:log"
import Ray "vendor:raylib"
import Entity "src/entity"
import SpriteManager "src/spriteManager"
import InputManager "src/inputManager"
import Action "src/action"
import Map "src/map"

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
  
  player := Entity.spawn(0, 0, SpriteManager.getHandle(&spriteManager, .PLAYER))

  MAP_WIDTH :: 50
  MAP_HEIGHT :: 50

  gameMap := Map.init(&spriteManager, MAP_WIDTH, MAP_HEIGHT, .GRASS, &player)
  defer Map.cleanup(&gameMap)

  centerX := MAP_WIDTH / 2
  centerY := MAP_HEIGHT / 2
  for x in centerX - 2 ..< centerX + 2 {
    Map.setTile(&gameMap, &spriteManager, x, centerY, .WALL)
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

  ANIM_FRAME_DURATION :: 0.15
  ANIM_TICK_WRAP :: 232792560 // LCM(1..20) - exactly divisible by any realistic frame count
  animAccumulator : f32 = 0
  animTick := 0

  for (!Ray.WindowShouldClose()){

    dt := Ray.GetFrameTime()

    animAccumulator += dt
    for animAccumulator >= ANIM_FRAME_DURATION {
      animAccumulator -= ANIM_FRAME_DURATION
      animTick = (animTick + 1) % ANIM_TICK_WRAP
    }

    InputManager.update(&inputManager)
    Map.update(&gameMap, dt)

    camera.zoom += inputManager.mouse_scroll * ZOOM_STEP
    camera.zoom = clamp(camera.zoom, ZOOM_MIN, ZOOM_MAX)

    if InputManager.isTriggered(&inputManager, .MoveUp) {
      Action.execute(Action.Movement{base = Action.ActionBase{entity = &player}, dx = 0, dy = -1, gameMap = &gameMap})
    }
    if InputManager.isTriggered(&inputManager, .MoveDown) {
      Action.execute(Action.Movement{base = Action.ActionBase{entity = &player}, dx = 0, dy = 1, gameMap = &gameMap})
    }
    if InputManager.isTriggered(&inputManager, .MoveLeft) {
      Action.execute(Action.Movement{base = Action.ActionBase{entity = &player}, dx = -1, dy = 0, gameMap = &gameMap})
    }
    if InputManager.isTriggered(&inputManager, .MoveRight) {
      Action.execute(Action.Movement{base = Action.ActionBase{entity = &player}, dx = 1, dy = 0, gameMap = &gameMap})
    }

    Ray.BeginDrawing()

    Ray.ClearBackground(Ray.BLACK)

    Ray.BeginMode2D(camera)
    Map.draw(&gameMap, &spriteManager, animTick)
    Ray.EndMode2D()

    Ray.EndDrawing()
  }

}