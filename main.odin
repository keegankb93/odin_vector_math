package main

import "core:fmt"
import math "core:math"
import "core:math/cmplx"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

Triangle :: struct {
	vectors: [3]rl.Vector2,
	angle:   f32,
	turning: bool,
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Asteroid")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	triangle := Triangle {
		vectors = {rl.Vector2{300, 300}, rl.Vector2{400, 300}, rl.Vector2{350, 200}},
		angle   = 0,
	}

	for !rl.WindowShouldClose() {

		inputs(&triangle)
		update(&triangle)
		draw(&triangle)

	}
}

inputs :: proc(triangle: ^Triangle) {
	dt := rl.GetFrameTime()

	triangle.angle = 0

	if rl.IsKeyDown(.D) {
		triangle.angle -= 45 * dt
	} else if rl.IsKeyDown(.A) {
		triangle.angle += 45 * dt
	}
}

update :: proc(triangle: ^Triangle) {

	if triangle.angle != 0 do rotate_triangle(triangle)
}

draw :: proc(triangle: ^Triangle) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	draw_triangle(triangle)

	rl.EndDrawing()
}

rotate_triangle :: proc(triangle: ^Triangle) {
	centroid := get_centroid(triangle.vectors[0], triangle.vectors[1], triangle.vectors[2])

	for i in 0 ..< len(triangle.vectors) {
		translated_vector := triangle.vectors[i] - centroid
		rotated_vector := rotate_clockwise(translated_vector, triangle.angle)
		retranslated_vector := rotated_vector + centroid
		triangle.vectors[i] = retranslated_vector
	}


}

get_centroid :: proc(v1: rl.Vector2, v2: rl.Vector2, v3: rl.Vector2) -> rl.Vector2 {
	return (v1 + v2 + v3) / 3
}

rotate_clockwise :: proc(point: rl.Vector2, deg: f32) -> rl.Vector2 {
	radians := math.to_radians_f32(deg)

	rotated_x := point[0] * math.cos_f32(radians) + point[1] * math.sin_f32(radians)
	rotated_y := -point[0] * math.sin_f32(radians) + point[1] * math.cos_f32(radians)

	return rl.Vector2{rotated_x, rotated_y}
}

distance_to :: proc(point: rl.Vector2, origin: rl.Vector2 = rl.Vector2{0, 0}) -> f32 {
	return math.sqrt_f32(
		math.pow_f32(point[0] - origin[0], 2.0) + math.pow_f32(point[1] - origin[1], 2.0),
	)
}

draw_triangle :: proc(triangle: ^Triangle) {
	rl.DrawTriangleLines(triangle.vectors[0], triangle.vectors[1], triangle.vectors[2], rl.WHITE)
}
