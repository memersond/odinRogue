package Action

import Entity "../entity"

ActionBase :: struct {
	entity: ^Entity.Entity,
}

Movement :: struct {
	using base: ActionBase,
	dx, dy: int,
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
	m.entity.x += m.dx
	m.entity.y += m.dy
}
