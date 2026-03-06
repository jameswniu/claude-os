#!/bin/bash
# build-demo.sh — Orchestrate ClaudeOS demo video production
# Usage: cd ~/claude-os/demo && bash build-demo.sh [step]
# Steps: tts, record, combine, all

set -euo pipefail

DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
SCENES_DIR="$DEMO_DIR/scenes"
NARRATION_DIR="$DEMO_DIR/narration"
OUTPUT_DIR="$DEMO_DIR/output"
FINAL_OUTPUT="$HOME/Downloads/claudeos-demo.mp4"

# macOS TTS settings
TTS_VOICE="Daniel"
TTS_RATE=170  # words per minute

mkdir -p "$SCENES_DIR" "$OUTPUT_DIR"

# ─── Step 1: Generate TTS audio ───────────────────────────────────
generate_tts() {
    echo "=== Generating TTS narration (macOS $TTS_VOICE) ==="
    for txt in "$NARRATION_DIR"/scene-*.txt; do
        scene=$(basename "$txt" .txt)
        wav="$NARRATION_DIR/${scene}.aiff"
        mp3="$NARRATION_DIR/${scene}.mp3"

        if [ -f "$mp3" ] && [ "$mp3" -nt "$txt" ]; then
            echo "  Skipping $scene (up to date)"
            continue
        fi

        echo "  Generating $scene..."
        say -v "$TTS_VOICE" -r "$TTS_RATE" -o "$wav" < "$txt"
        # Convert AIFF to MP3 for easier handling
        ffmpeg -y -i "$wav" -codec:a libmp3lame -qscale:a 2 "$mp3" 2>/dev/null
        rm -f "$wav"

        # Report duration
        dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp3")
        echo "    Duration: ${dur}s"
    done
    echo "=== TTS complete ==="
}

# ─── Step 2: Record terminal scenes with VHS ──────────────────────
record_scenes() {
    echo "=== Recording terminal scenes with VHS ==="
    for tape in "$DEMO_DIR"/scene-*.tape; do
        scene=$(basename "$tape" .tape)
        mp4="$SCENES_DIR/${scene}.mp4"

        # VHS output is set inside the tape file, but we run from demo dir
        echo "  Recording $scene..."
        (cd "$DEMO_DIR" && vhs "$tape")

        if [ -f "$mp4" ]; then
            dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp4")
            echo "    Duration: ${dur}s"
        else
            echo "    WARNING: $mp4 not created"
        fi
    done
    echo "=== Recording complete ==="
}

# ─── Step 3: Merge narration audio onto scene videos ──────────────
merge_audio() {
    echo "=== Merging narration audio onto scene videos ==="

    for mp4 in "$SCENES_DIR"/scene-*.mp4; do
        scene=$(basename "$mp4" .mp4)
        # Map scene filenames: scene-5-terminal -> scene-5
        audio_key=$(echo "$scene" | sed 's/-[a-z]*$//' | sed 's/scene-\([0-9]\)-.*$/scene-\1/')
        mp3="$NARRATION_DIR/${audio_key}.mp3"
        merged="$OUTPUT_DIR/${scene}-narrated.mp4"

        if [ ! -f "$mp3" ]; then
            echo "  No audio for $scene, copying video as-is"
            cp "$mp4" "$merged"
            continue
        fi

        echo "  Merging $scene + ${audio_key}.mp3..."

        # Get durations
        vid_dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp4")
        aud_dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp3")

        # Calculate speed factor to fit video into audio duration (+ 1s buffer)
        # Cap at 1.8x so terminal text stays readable
        target_dur=$(python3 -c "print(${aud_dur} + 1.0)")
        speed=$(python3 -c "print(min(1.8, ${vid_dur} / ${target_dur}))")

        echo "    Speed: ${speed}x (${vid_dur}s -> ${target_dur}s)"

        # Speed up video to match audio, then merge
        ffmpeg -y \
            -i "$mp4" \
            -i "$mp3" \
            -filter_complex "[0:v]setpts=PTS/${speed}[v]" \
            -map "[v]" -map 1:a:0 \
            -c:v libx264 -preset fast -crf 23 \
            -c:a aac -b:a 192k \
            -shortest \
            "$merged" 2>/dev/null

        dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$merged")
        echo "    Output: ${dur}s (video: ${vid_dur}s @ ${speed}x, audio: ${aud_dur}s)"
    done
    echo "=== Merge complete ==="
}

# ─── Step 4: Concatenate all scenes into final video ──────────────
combine_scenes() {
    echo "=== Combining all scenes into final video ==="

    # Build concat file in order
    concat_file="$OUTPUT_DIR/concat.txt"
    > "$concat_file"

    # Define scene order
    scenes_order=(
        "scene-1-title"
        "scene-2-static-context"
        "scene-3-learning-loop"
        "scene-4-automation"
        "scene-5-terminal"
        "scene-6-bootstrap"
        "scene-7-cost"
    )

    for scene in "${scenes_order[@]}"; do
        narrated="$OUTPUT_DIR/${scene}-narrated.mp4"
        if [ -f "$narrated" ]; then
            echo "file '$narrated'" >> "$concat_file"
            echo "  Including: $scene"
        else
            echo "  MISSING: $scene (skipping)"
        fi
    done

    # First pass: re-encode all to consistent format for concat
    echo "  Re-encoding scenes for consistent format..."
    re_concat_file="$OUTPUT_DIR/concat-reencoded.txt"
    > "$re_concat_file"

    i=0
    while IFS= read -r line; do
        # Extract file path from concat line
        filepath=$(echo "$line" | sed "s/^file '//;s/'$//")
        reencoded="$OUTPUT_DIR/re-$(basename "$filepath")"

        ffmpeg -y -i "$filepath" \
            -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=30" \
            -c:v libx264 -preset fast -crf 23 \
            -c:a aac -b:a 192k -ar 44100 -ac 2 \
            -pix_fmt yuv420p \
            "$reencoded" 2>/dev/null

        echo "file '$reencoded'" >> "$re_concat_file"
        i=$((i + 1))
    done < "$concat_file"

    # Concatenate
    ffmpeg -y -f concat -safe 0 -i "$re_concat_file" \
        -c copy \
        "$FINAL_OUTPUT" 2>/dev/null

    # Clean up re-encoded files
    rm -f "$OUTPUT_DIR"/re-*.mp4

    total_dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL_OUTPUT")
    echo "=== Final video: $FINAL_OUTPUT (${total_dur}s) ==="
}

# ─── Main ─────────────────────────────────────────────────────────
case "${1:-all}" in
    tts)
        generate_tts
        ;;
    record)
        record_scenes
        ;;
    merge)
        merge_audio
        ;;
    combine)
        combine_scenes
        ;;
    all)
        generate_tts
        record_scenes
        merge_audio
        combine_scenes
        echo ""
        echo "Done! Final video: $FINAL_OUTPUT"
        echo "Run: open '$FINAL_OUTPUT'"
        ;;
    *)
        echo "Usage: $0 [tts|record|merge|combine|all]"
        exit 1
        ;;
esac
