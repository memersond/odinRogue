package World

import SparseSet "../sparseSet"

MOVE_DURATION :: 0.03

EntityId :: struct {
  index: u32,
  generation: u32,
}

EntityKind :: enum {
  PLAYER,
  ENEMY,
  TREE,
  TALL_GRASS,
}

World :: struct {
  nextIndex: u32,
  freeIndices: [dynamic]u32,
  generations: [dynamic]u32,

  positions: SparseSet.Set(Position),
  sprites: SparseSet.Set(Sprite),
  movements: SparseSet.Set(Movement),
  blocking: SparseSet.Set(Blocking),
  kinds: SparseSet.Set(EntityKind),
}

createEntity :: proc(w: ^World) -> EntityId {
  if len(w.freeIndices) > 0 {
    index := pop(&w.freeIndices)
    return EntityId{index = index, generation = w.generations[index]}
  }

  index := w.nextIndex
  w.nextIndex += 1
  append(&w.generations, u32(0))
  return EntityId{index = index, generation = 0}
}

destroyEntity :: proc(w: ^World, id: EntityId) {
  SparseSet.remove(&w.positions, int(id.index))
  SparseSet.remove(&w.sprites, int(id.index))
  SparseSet.remove(&w.movements, int(id.index))
  SparseSet.remove(&w.blocking, int(id.index))
  SparseSet.remove(&w.kinds, int(id.index))

  w.generations[id.index] += 1
  append(&w.freeIndices, id.index)
}

isAlive :: proc(w: ^World, id: EntityId) -> bool {
  return int(id.index) < len(w.generations) && w.generations[id.index] == id.generation
}

cleanup :: proc(w: ^World) {
  delete(w.freeIndices)
  delete(w.generations)
  SparseSet.destroy(&w.positions)
  SparseSet.destroy(&w.sprites)
  SparseSet.destroy(&w.movements)
  SparseSet.destroy(&w.blocking)
  SparseSet.destroy(&w.kinds)
}
