package Entity

import SpriteManager "../spriteManager"

MOVE_DURATION :: 0.03

Entity :: struct {
  x: int,
  y: int,
  prevX: int,
  prevY: int,
  moveElapsed: f32,
  textureId: SpriteManager.SpriteHandle
}

spawn :: proc(x, y: int, textureId: SpriteManager.SpriteHandle) -> Entity {
  return Entity{
    x = x,
    y = y,
    prevX = x,
    prevY = y,
    moveElapsed = MOVE_DURATION,
    textureId = textureId
  }
}

move :: proc(entity: ^Entity, dx, dy: int) {
  entity.prevX = entity.x
  entity.prevY = entity.y
  entity.x += dx
  entity.y += dy
  entity.moveElapsed = 0
}

update :: proc(entity: ^Entity, dt: f32) {
  if entity.moveElapsed < MOVE_DURATION {
    entity.moveElapsed += dt
    if entity.moveElapsed > MOVE_DURATION {
      entity.moveElapsed = MOVE_DURATION
    }
  }
}

draw :: proc(spriteManager: ^SpriteManager.SpriteManager, entity: ^Entity, tileSize: int, animTick: int) {
  frameCount := len(entity.textureId.frames)
  frameIndex := 0
  if frameCount > 0 {
    frameIndex = animTick % frameCount
  }

  t := entity.moveElapsed / MOVE_DURATION
  if t > 1 {
    t = 1
  }

  renderX := f32(entity.prevX) + (f32(entity.x) - f32(entity.prevX)) * t
  renderY := f32(entity.prevY) + (f32(entity.y) - f32(entity.prevY)) * t

  SpriteManager.drawSprite(spriteManager, entity.textureId, renderX*f32(tileSize), renderY*f32(tileSize), frameIndex)
}