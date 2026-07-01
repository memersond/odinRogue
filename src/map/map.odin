package Map 

import SpriteManager "../spriteManager"

TileType :: enum {
  GRASS,
  WALL
}

Tile :: struct {
  x, y: int,
  seen: bool,
  type: TileType,
  textureId: SpriteManager.SpriteHandle
}

Map :: struct {
  tiles: [dynamic][dynamic]Tile
}

init :: proc(width, height: int, fillType: TileType) -> Map {
  m: Map
  m.tiles = make([dynamic][dynamic]Tile, width)
  for x in 0..<width {
    m.tiles[x] = make([dynamic]Tile, height)
    for y in 0..<height {
      m.tiles[x][y] = Tile{
        x = x,
        y = y,
        type = fillType,
      }
    }
  }
  return m
}

cleanup :: proc(m: ^Map) {
  for column in m.tiles {
    delete(column)
  }
  delete(m.tiles)
}

