package SpriteManager

import "vendor:raylib"
import stbrp "vendor:stb/rect_pack"
import "core:os"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:encoding/json"

ATLAS_SIZE :: 1024

Sprite :: enum {
	Unknown,
	Grass,
	Wall,
	Player,
}

// Resolved sprite location — store this on entities instead of the enum.
SpriteHandle :: struct {
	atlas_index: int,
	source_rect:  raylib.Rectangle,
}

SpriteManager :: struct {
	atlases:        [dynamic]raylib.Texture2D,
	sprite_handles: [Sprite]SpriteHandle,
}

_AsepriteFrameRect :: struct {
	x, y, w, h: int,
}

_AsepriteFrame :: struct {
	filename: string,
	frame:    _AsepriteFrameRect,
}

_AsepriteMeta :: struct {
	image: string,
}

_AsepriteJson :: struct {
	frames: []_AsepriteFrame,
	meta:   _AsepriteMeta,
}

_SpriteEntry :: struct {
	name:     string,
	png_path: string,
	w, h:     int,
}

init :: proc(manager: ^SpriteManager) -> bool {
	exe_dir, err := os.get_executable_directory(context.temp_allocator)
	if err != nil {
		log.error("Failed to get executable directory")
		return false
	}

	for sprite in Sprite {
		manager.sprite_handles[sprite].atlas_index = -1
	}

	_load_directory(manager, fmt.tprintf("%s/assets", exe_dir))
	return true
}

_load_directory :: proc(manager: ^SpriteManager, dir_path: string) {
	files, err := os.read_directory_by_path(dir_path, 0, context.temp_allocator)
	if err != nil {
		log.error("Failed to read directory:", dir_path)
		return
	}

	entries: [dynamic]_SpriteEntry
	defer delete(entries)

	for file in files {
		if file.type == .Regular && strings.has_suffix(file.name, ".json") {
			_parse_json(file.fullpath, dir_path, &entries)
		}
	}

	if len(entries) > 0 {
		_build_atlas(manager, entries[:])
	}

	for file in files {
		if file.type == .Directory {
			_load_directory(manager, file.fullpath)
		}
	}
}

_parse_json :: proc(json_path: string, dir_path: string, entries: ^[dynamic]_SpriteEntry) {
	data, ok := os.read_entire_file(json_path, context.temp_allocator)
	if !ok {
		log.error("Failed to read:", json_path)
		return
	}

	parsed: _AsepriteJson
	if parse_err := json.unmarshal(data, &parsed, allocator = context.temp_allocator); parse_err != nil {
		log.error("Failed to parse JSON:", json_path)
		return
	}

	if len(parsed.frames) == 0 || parsed.meta.image == "" {
		return
	}

	frame := parsed.frames[0]
	append(entries, _SpriteEntry{
		name     = strings.trim_suffix(parsed.meta.image, ".png"),
		png_path = fmt.tprintf("%s/%s", dir_path, parsed.meta.image),
		w        = frame.frame.w,
		h        = frame.frame.h,
	})
}

_build_atlas :: proc(manager: ^SpriteManager, entries: []_SpriteEntry) {
	// stb rect_pack needs at least ATLAS_SIZE nodes for optimal results
	nodes := make([]stbrp.Node, ATLAS_SIZE, context.temp_allocator)
	rects := make([]stbrp.Rect, len(entries), context.temp_allocator)

	ctx: stbrp.Context
	stbrp.init_target(&ctx, ATLAS_SIZE, ATLAS_SIZE, raw_data(nodes), i32(len(nodes)))

	for e, i in entries {
		rects[i] = stbrp.Rect{
			id = i32(i),
			w  = stbrp.Coord(e.w),
			h  = stbrp.Coord(e.h),
		}
	}

	stbrp.pack_rects(&ctx, raw_data(rects), i32(len(rects)))

	atlas_img := raylib.GenImageColor(ATLAS_SIZE, ATLAS_SIZE, raylib.BLANK)
	defer raylib.UnloadImage(atlas_img)

	atlas_index := len(manager.atlases)

	for rect in rects {
		if !rect.was_packed {
			log.warn("Sprite did not fit in atlas:", entries[rect.id].name)
			continue
		}
		e := entries[rect.id]
		sprite_img := raylib.LoadImage(strings.clone_to_cstring(e.png_path, context.temp_allocator))
		src_rect := raylib.Rectangle{0, 0, f32(e.w), f32(e.h)}
		dst_rect := raylib.Rectangle{f32(rect.x), f32(rect.y), f32(e.w), f32(e.h)}
		raylib.ImageDraw(&atlas_img, sprite_img, src_rect, dst_rect, raylib.WHITE)
		raylib.UnloadImage(sprite_img)
		_map_sprite(manager, e.name, atlas_index, dst_rect)
	}

	append(&manager.atlases, raylib.LoadTextureFromImage(atlas_img))
}

_map_sprite :: proc(manager: ^SpriteManager, name: string, atlas_index: int, rect: raylib.Rectangle) {
	for sprite in Sprite {
		if strings.equal_fold(fmt.tprintf("%v", sprite), name) {
			manager.sprite_handles[sprite] = SpriteHandle{
				atlas_index = atlas_index,
				source_rect = rect,
			}
			return
		}
	}
	log.warn("No Sprite enum value for:", name)
}

get_handle :: proc(manager: ^SpriteManager, sprite: Sprite) -> SpriteHandle {
	return manager.sprite_handles[sprite]
}

draw_sprite :: proc(manager: ^SpriteManager, handle: SpriteHandle, x, y: f32) {
	if handle.atlas_index < 0 || handle.atlas_index >= len(manager.atlases) {
		return
	}
	texture := manager.atlases[handle.atlas_index]
	dest := raylib.Rectangle{x, y, handle.source_rect.width, handle.source_rect.height}
	raylib.DrawTexturePro(texture, handle.source_rect, dest, {0, 0}, 0, raylib.WHITE)
}

unload :: proc(manager: ^SpriteManager) {
	for texture in manager.atlases {
		raylib.UnloadTexture(texture)
	}
	delete(manager.atlases)
}
