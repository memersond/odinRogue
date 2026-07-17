package World

import SparseSet "../sparseSet"
import SpriteManager "../spriteManager"

spawnPlayer :: proc(w: ^World, x, y: int, textureId: SpriteManager.SpriteHandle) -> EntityId {
  id := createEntity(w)
  SparseSet.set(&w.positions, int(id.index), Position{x = x, y = y})
  SparseSet.set(&w.sprites, int(id.index), Sprite{textureId = textureId})
  SparseSet.set(&w.movements, int(id.index), Movement{prevX = x, prevY = y, moveElapsed = MOVE_DURATION})
  SparseSet.set(&w.kinds, int(id.index), EntityKind.PLAYER)
  return id
}

spawnEnemy :: proc(w: ^World, x, y: int, textureId: SpriteManager.SpriteHandle) -> EntityId {
  id := createEntity(w)
  SparseSet.set(&w.positions, int(id.index), Position{x = x, y = y})
  SparseSet.set(&w.sprites, int(id.index), Sprite{textureId = textureId})
  SparseSet.set(&w.movements, int(id.index), Movement{prevX = x, prevY = y, moveElapsed = MOVE_DURATION})
  SparseSet.set(&w.blocking, int(id.index), Blocking{})
  SparseSet.set(&w.kinds, int(id.index), EntityKind.ENEMY)
  return id
}

spawnTree :: proc(w: ^World, x, y: int, textureId: SpriteManager.SpriteHandle) -> EntityId {
  id := createEntity(w)
  SparseSet.set(&w.positions, int(id.index), Position{x = x, y = y})
  SparseSet.set(&w.sprites, int(id.index), Sprite{textureId = textureId})
  SparseSet.set(&w.blocking, int(id.index), Blocking{})
  SparseSet.set(&w.kinds, int(id.index), EntityKind.TREE)
  return id
}

spawnTallGrass :: proc(w: ^World, x, y: int, textureId: SpriteManager.SpriteHandle) -> EntityId {
  id := createEntity(w)
  SparseSet.set(&w.positions, int(id.index), Position{x = x, y = y})
  SparseSet.set(&w.sprites, int(id.index), Sprite{textureId = textureId})
  SparseSet.set(&w.kinds, int(id.index), EntityKind.TALL_GRASS)
  return id
}
