package Map

import SpriteManager "../spriteManager"

TILE_SIZE :: 16

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

_spriteForType :: proc(tileType: TileType) -> SpriteManager.Sprite {
  switch tileType {
  case .GRASS: return .GRASS
  case .WALL: return .WALL
  }
  return .UNKNOWN
}

init :: proc(spriteManager: ^SpriteManager.SpriteManager, width, height: int, fillType: TileType) -> Map {
  m: Map
  m.tiles = make([dynamic][dynamic]Tile, width)
  for x in 0..<width {
    m.tiles[x] = make([dynamic]Tile, height)
    for y in 0..<height {
      m.tiles[x][y] = Tile{
        x = x,
        y = y,
        type = fillType,
        textureId = SpriteManager.getHandle(spriteManager, _spriteForType(fillType)),
      }
    }
  }
  return m
}

setTile :: proc(m: ^Map, spriteManager: ^SpriteManager.SpriteManager, x, y: int, tileType: TileType) {
  m.tiles[x][y].type = tileType
  m.tiles[x][y].textureId = SpriteManager.getHandle(spriteManager, _spriteForType(tileType))
}

draw :: proc(m: ^Map, spriteManager: ^SpriteManager.SpriteManager) {
  for column in m.tiles {
    for tile in column {
      SpriteManager.drawSprite(spriteManager, tile.textureId, f32(tile.x * TILE_SIZE), f32(tile.y * TILE_SIZE))
    }
  }
}

cleanup :: proc(m: ^Map) {
  for column in m.tiles {
    delete(column)
  }
  delete(m.tiles)
}

