package Action

import World "../world"
import Map "../map"
import Log "core:log"

ActionBase :: struct {
	entity: World.EntityId,
}

Movement :: struct #all_or_none {
	using base: ActionBase,
	dx, dy: int,
	gameMap: ^Map.Map
}

Action :: union {
	Movement,
}

execute :: proc(action: Action) {
	switch a in action {
	case Movement:
		_executeMovement(a)
	}
}

_executeMovement :: proc(m: Movement) {
	pos, _ := World.getPosition(&m.gameMap.world, m.entity)
	targetX := pos.x + m.dx
	targetY := pos.y + m.dy

	tileIsSolid, foundTile := Map.isTileSoild(m.gameMap, targetX, targetY)

	if(!foundTile){
		Log.debug("Could not find if tile was solid")
	}

	if(tileIsSolid){
		return
	}

	if(Map.isEntityBlocking(m.gameMap, targetX, targetY)){
		return
	}

	World.move(&m.gameMap.world, m.entity, m.dx, m.dy)
}
