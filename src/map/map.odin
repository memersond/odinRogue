package Map 

import SpriteManager "../spriteManager"

Tile :: struct {
  x, y: int,
  seen: bool,
  textureId: SpriteManager.SpriteHandle
}