package Map

import SpriteManager "../spriteManager"
import Entity "../entity"

TILE_SIZE :: 16

TileType :: enum {
  GRASS,
  WALL
}

TileSolidMap := [TileType]bool{
  .GRASS = false,
  .WALL = true
}

Tile :: struct {
  seen: bool,
  type: TileType,
  textureId: SpriteManager.SpriteHandle
}

Map :: struct {
  width, height: int,
  tiles: [dynamic][dynamic]Tile,
  entities: [dynamic]Entity.Entity,
  player: ^Entity.Entity
}

_spriteForType :: proc(tileType: TileType) -> SpriteManager.Sprite {
  switch tileType {
    case .GRASS: return .GRASS
    case .WALL: return .WALL
  }
  return .UNKNOWN
}

init :: proc(spriteManager: ^SpriteManager.SpriteManager, width, height: int, fillType: TileType, player: ^Entity.Entity) -> Map {
  m: Map

  m.width = width
  m.height = height

  m.tiles = make([dynamic][dynamic]Tile, width)
  for x in 0..<width {
    m.tiles[x] = make([dynamic]Tile, height)
    for y in 0..<height {
      m.tiles[x][y] = Tile{
        type = fillType,
        textureId = SpriteManager.getHandle(spriteManager, _spriteForType(fillType)),
      }
    }
  }

  m.entities = make([dynamic]Entity.Entity)

  m.player = player
  return m
}

setTile :: proc(m: ^Map, spriteManager: ^SpriteManager.SpriteManager, x, y: int, tileType: TileType) {
  m.tiles[x][y].type = tileType
  m.tiles[x][y].textureId = SpriteManager.getHandle(spriteManager, _spriteForType(tileType))
}

getTile ::proc(gameMap: ^Map, x: int, y: int) -> (tile: Tile, ok: bool) {
  if(x < 0 || x >= gameMap.width || y < 0 || y >=gameMap.height){
    return Tile{}, false
  }

  return gameMap.tiles[x][y], true
}

draw :: proc(m: ^Map, spriteManager: ^SpriteManager.SpriteManager) {
  for column, x in m.tiles {
    for tile, y in column {
      SpriteManager.drawSprite(spriteManager, tile.textureId, f32(x * TILE_SIZE), f32(y * TILE_SIZE))
    }
  }

  for &entity in m.entities {
    Entity.draw(spriteManager, &entity, TILE_SIZE)
  }

  Entity.draw(spriteManager, m.player, TILE_SIZE)
}

cleanup :: proc(m: ^Map) {
  for column in m.tiles {
    delete(column)
  }
  delete(m.tiles)
}

isTileSoild :: proc(gameMap: ^Map, x: int, y: int) -> (walkable: bool, ok: bool) {
  tile, foundTile := getTile(gameMap, x, y)

  if(!foundTile){
    return false, false
  }

  return TileSolidMap[tile.type], true
}