package Entity

import SpriteManager "../spriteManager"

Entity :: struct {
  x: int,
  y: int,
  textureId: SpriteManager.SpriteHandle
}

draw :: proc(spriteManager: ^SpriteManager.SpriteManager, entity: ^Entity, tileSize: int) {
  SpriteManager.drawSprite(spriteManager, entity.textureId, f32(entity.x*tileSize), f32(entity.y*tileSize))
}