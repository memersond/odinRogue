package Entity

import SpriteManager "../spriteManager"

Entity :: struct {
  x: int,
  y: int,
  textureId: SpriteManager.SpriteHandle
}

draw :: proc(spriteManager: ^SpriteManager.SpriteManager, entity: ^Entity, tileSize: int, animTick: int) {
  frameCount := len(entity.textureId.frames)
  frameIndex := 0
  if frameCount > 0 {
    frameIndex = animTick % frameCount
  }

  SpriteManager.drawSprite(spriteManager, entity.textureId, f32(entity.x*tileSize), f32(entity.y*tileSize), frameIndex)
}