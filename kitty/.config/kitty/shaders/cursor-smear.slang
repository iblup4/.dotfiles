#language slang 2026
// cursor-smear: kitty port of cursor_smear.glsl
// Source: https://github.com/KroneCorylus/ghostty-shader-playground (public/shaders/cursor_smear.glsl)
//
// Ported from Ghostty's Shadertoy-style GLSL to kitty's Slang custom shader API.
// The trail geometry, easing and colouring are unchanged. Input mapping:
//   iTime                   -> d.timestamp
//   iTimeCursorChange       -> d.cursor_trail_change_time
//   iCurrentCursor          -> d.cursor_trail_edge      (converted to pixels)
//   iPreviousCursor         -> d.cursor_trail_prev_edge (converted to pixels)
//   iCurrentCursorColor     -> d.cursor_color
//   texture(iChannel0, uv)  -> color
//
// MIT License
//
// Copyright (c) 2025 Krone Corylus
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import kitty_custom_shader_types;

// Trail animation duration in seconds.
// Override from the pipeline file with: var float DURATION 0.2
static const float DURATION = 0.3;
// Colour saturation boost applied to the cursor colour for the trail.
static const float SATURATION_BOOST = 1.8;

// Process each edge: compute distance and determine if point is inside
void processEdge(float2 p, float2 a, float2 b, inout float minDist, inout float inside) {
    float2 edge = b - a;
    float2 pa = p - a;
    // Guard against zero-length edges (cursor did not move on an axis)
    float lenSq = max(dot(edge, edge), 1e-12);
    float invLenSq = 1.0 / lenSq;

    float t = clamp(dot(pa, edge) * invLenSq, 0.0, 1.0);
    float2 diff = pa - edge * t;
    minDist = min(minDist, dot(diff, diff));

    float crossVal = edge.x * pa.y - edge.y * pa.x;
    inside = min(inside, step(0.0, crossVal));
}

// Signed distance field for hexagon (negative inside, positive outside)
// Vertices must be in counter-clockwise order
float sdHexagon(float2 p, float2 v0, float2 v1, float2 v2, float2 v3, float2 v4, float2 v5) {
    float minDist = 1e20;
    float inside = 1.0;

    processEdge(p, v0, v1, minDist, inside);
    processEdge(p, v1, v2, minDist, inside);
    processEdge(p, v2, v3, minDist, inside);
    processEdge(p, v3, v4, minDist, inside);
    processEdge(p, v4, v5, minDist, inside);
    processEdge(p, v5, v0, minDist, inside);

    float dist = sqrt(max(minDist, 0.0));
    return lerp(dist, -dist, inside);
}

// Signed distance field for rectangle (negative inside, positive outside)
float sdRectangle(float2 p, float2 center, float2 halfSize) {
    float2 d = abs(p - center) - halfSize;
    return length(max(d, float2(0.0))) + min(max(d.x, d.y), 0.0);
}

// Represents cursor as a quad with four corners
struct Quad {
    float2 topLeft;
    float2 topRight;
    float2 bottomLeft;
    float2 bottomRight;
};

// Construct quad from top-left position and size (y-up)
Quad getQuad(float2 pos, float2 size) {
    Quad q;
    q.topLeft = pos;
    q.topRight = pos + float2(size.x, 0.0);
    q.bottomLeft = pos - float2(0.0, size.y);
    q.bottomRight = pos + float2(size.x, -size.y);
    return q;
}

// Select 3 corners from quad based on movement direction
// sel.x: 0=left, 1=right | sel.y: 0=top, 1=bottom
void selectTrailCorners(Quad q, float2 sel, out float2 p1, out float2 p2, out float2 p3) {
    p1 = lerp(lerp(q.topRight, q.topLeft, sel.x),
              lerp(q.bottomRight, q.bottomLeft, sel.x),
              sel.y);
    p2 = lerp(lerp(q.topLeft, q.bottomLeft, sel.x),
              lerp(q.topRight, q.bottomRight, sel.x),
              sel.y);
    p3 = lerp(lerp(q.bottomRight, q.topRight, sel.x),
              lerp(q.bottomLeft, q.topLeft, sel.x),
              sel.y);
}

// Select 4 corners from quad based on movement direction
void selectCorners(Quad q, float2 sel, out float2 p1, out float2 p2, out float2 p3, out float2 p4) {
    selectTrailCorners(q, sel, p1, p2, p3);
    p4 = lerp(lerp(q.bottomLeft, q.bottomRight, sel.x),
              lerp(q.topLeft, q.topRight, sel.x),
              sel.y);
}

// Cubic ease-out function for smooth animation (expects clamped input)
float easeClamped(float x) {
    float t = 1.0 - x;
    return 1.0 - t * t * t;
}

// kitty edge (.x=left, .y=right, .z=top, .w=bottom, UV y-up) -> Ghostty-style
// cursor (.xy = top-left corner, .zw = width/height), in pixels.
float4 edgeToCursor(float4 e, float2 res) {
    return float4(e.x * res.x, e.z * res.y, (e.y - e.x) * res.x, (e.z - e.w) * res.y);
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    // Both are zero until the cursor has moved at least twice
    if (d.cursor_trail_change_time <= 0.0) return color;

    // Calculate animation progress
    float baseProgress = clamp((d.timestamp - d.cursor_trail_change_time) / DURATION, 0.0, 1.0);
    // Skip further work when animation is complete
    if (baseProgress >= 1.0) return color;

    float2 res = float2(d.viewport_size_pixels);
    float2 fragCoord = t.pos * res;

    // Precompute reused values
    float invResY = 1.0 / res.y;
    float scale = 2.0 * invResY;
    float aaWidth = scale;
    float2 normOffset = res * invResY;

    float4 cur = edgeToCursor(d.cursor_trail_edge, res);
    float4 prev = edgeToCursor(d.cursor_trail_prev_edge, res);

    // Normalize cursor positions and sizes to screen-independent coordinates
    float2 currentPos = cur.xy * scale - normOffset;
    float2 previousPos = prev.xy * scale - normOffset;
    float2 currentSize = cur.zw * scale;
    float2 previousSize = prev.zw * scale;

    // Determine movement direction and construct cursor quads
    float2 deltaPos = currentPos - previousPos;
    Quad currentCursor = getQuad(currentPos, currentSize);
    Quad previousCursor = getQuad(previousPos, previousSize);
    float2 selector = step(float2(0.0), deltaPos);

    // Select corners based on movement direction
    float2 currP1, currP2, currP3, currP4;
    float2 prevP1, prevP2, prevP3;
    selectCorners(currentCursor, selector, currP1, currP2, currP3, currP4);
    selectTrailCorners(previousCursor, selector, prevP1, prevP2, prevP3);

    float easedProgress = easeClamped(baseProgress);
    float stretchedProgress = min(baseProgress * 2.0, 1.0);
    float easedProgressDouble = easeClamped(stretchedProgress);

    // Create trailing effect by moving diagonal point slower
    float2 trailP1 = lerp(prevP1, currP1, easedProgress);
    float2 trailP2 = lerp(prevP2, currP2, easedProgressDouble);
    float2 trailP3 = lerp(prevP3, currP3, easedProgressDouble);

    // Compute hexagon SDF and convert to alpha with antialiasing
    float2 normCoord = fragCoord * scale - normOffset;
    float sdfHex = sdHexagon(normCoord, trailP1, trailP2, currP2, currP4, currP3, trailP3);
    float alpha = 1.0 - smoothstep(-aaWidth, aaWidth, sdfHex);

    // Compute current cursor SDF
    float2 halfCurrentSize = currentSize * 0.5;
    float2 currentCenter = currentPos + float2(halfCurrentSize.x, -halfCurrentSize.y);
    float sdfCurrentCursor = sdRectangle(normCoord, currentCenter, halfCurrentSize);

    // Enhance color saturation for more vibrant trail effect
    float4 cursorColor = d.cursor_color;
    float gray = dot(cursorColor.rgb, float3(0.299, 0.587, 0.114));
    float4 enhancedColor = clamp(
        lerp(float4(float3(gray), cursorColor.a), cursorColor, SATURATION_BOOST),
        float4(0.0), float4(1.0));

    // Blend trail color with background
    float3 rgb = lerp(color.rgb, enhancedColor.rgb, alpha);

    // Remove trail where it overlaps with current cursor
    rgb = lerp(rgb, color.rgb, step(sdfCurrentCursor, 0.0));

    return float4(rgb, color.a);
}
