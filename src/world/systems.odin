package World

import SparseSet "../sparseSet"
import SpriteManager "../spriteManager"

getPosition :: proc(w: ^World, id: EntityId) -> (Position, bool) {
  return SparseSet.get(&w.positions, int(id.index))
}

move :: proc(w: ^World, id: EntityId, dx, dy: int) {
  pos := SparseSet.getPtr(&w.positions, int(id.index))
  if pos == nil {
    return
  }

  if movement := SparseSet.getPtr(&w.movements, int(id.index)); movement != nil {
    movement.prevX = pos.x
    movement.prevY = pos.y
    movement.moveElapsed = 0
  }

  pos.x += dx
  pos.y += dy
}

updateMovement :: proc(w: ^World, dt: f32) {
  for &movement in w.movements.dense {
    if movement.moveElapsed < MOVE_DURATION {
      movement.moveElapsed += dt
      if movement.moveElapsed > MOVE_DURATION {
        movement.moveElapsed = MOVE_DURATION
      }
    }
  }
}

draw :: proc(w: ^World, spriteManager: ^SpriteManager.SpriteManager, tileSize: int, animTick: int) {
  for sprite, i in w.sprites.dense {
    index := w.sprites.keys[i]

    pos, hasPos := SparseSet.get(&w.positions, index)
    if !hasPos {
      continue
    }

    renderX := f32(pos.x)
    renderY := f32(pos.y)

    if movement, ok := SparseSet.get(&w.movements, index); ok {
      t := movement.moveElapsed / MOVE_DURATION
      if t > 1 {
        t = 1
      }

      renderX = f32(movement.prevX) + (f32(pos.x) - f32(movement.prevX)) * t
      renderY = f32(movement.prevY) + (f32(pos.y) - f32(movement.prevY)) * t
    }

    frameCount := len(sprite.textureId.frames)
    frameIndex := 0
    if frameCount > 0 {
      frameIndex = animTick % frameCount
    }

    SpriteManager.drawSprite(spriteManager, sprite.textureId, renderX*f32(tileSize), renderY*f32(tileSize), frameIndex)
  }
}

isBlockedAt :: proc(w: ^World, x, y: int) -> bool {
  for index in w.blocking.keys {
    pos, ok := SparseSet.get(&w.positions, index)
    if ok && pos.x == x && pos.y == y {
      return true
    }
  }
  return false
}
