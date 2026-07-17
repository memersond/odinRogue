package World

import SpriteManager "../spriteManager"

Position :: struct {
  x: int,
  y: int,
}

Sprite :: struct {
  textureId: SpriteManager.SpriteHandle,
}

Movement :: struct {
  prevX: int,
  prevY: int,
  moveElapsed: f32,
}

Blocking :: struct {}
