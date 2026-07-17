package SparseSet

// O(1) add/remove/lookup by a plain int index (array arithmetic, no
// hashing), with `dense` kept tightly packed for cache-friendly iteration.
Set :: struct($T: typeid) {
  sparse: [dynamic]int, // index -> dense position, or -1 if absent
  keys: [dynamic]int,   // dense position -> owning index
  dense: [dynamic]T,    // dense position -> value
}

set :: proc(s: ^Set($T), index: int, value: T) {
  for len(s.sparse) <= index {
    append(&s.sparse, -1)
  }

  if s.sparse[index] >= 0 {
    s.dense[s.sparse[index]] = value
    return
  }

  s.sparse[index] = len(s.dense)
  append(&s.dense, value)
  append(&s.keys, index)
}

get :: proc(s: ^Set($T), index: int) -> (T, bool) {
  if index >= len(s.sparse) || s.sparse[index] < 0 {
    return T{}, false
  }
  return s.dense[s.sparse[index]], true
}

getPtr :: proc(s: ^Set($T), index: int) -> ^T {
  if index >= len(s.sparse) || s.sparse[index] < 0 {
    return nil
  }
  return &s.dense[s.sparse[index]]
}

contains :: proc(s: ^Set($T), index: int) -> bool {
  return index < len(s.sparse) && s.sparse[index] >= 0
}

remove :: proc(s: ^Set($T), index: int) {
  if index >= len(s.sparse) || s.sparse[index] < 0 {
    return
  }

  denseIndex := s.sparse[index]
  lastIndex := len(s.dense) - 1

  if denseIndex != lastIndex {
    s.dense[denseIndex] = s.dense[lastIndex]
    movedKey := s.keys[lastIndex]
    s.keys[denseIndex] = movedKey
    s.sparse[movedKey] = denseIndex
  }

  pop(&s.dense)
  pop(&s.keys)
  s.sparse[index] = -1
}

destroy :: proc(s: ^Set($T)) {
  delete(s.sparse)
  delete(s.keys)
  delete(s.dense)
}
