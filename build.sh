#!/usr/bin/env bash
# build.sh
set -euo pipefail

readonly ROM_SIZE=$((0x1000))
readonly SOURCE_NAME="Gorf_Disassembly.asm"
readonly ENGLISH_ZIP_NAME="gorf.zip"
readonly GERMAN_ZIP_NAME="gorfpgm1g.zip"
readonly FRENCH_ZIP_NAME="gorfpgm1f.zip"
readonly KLINGON_ZIP_NAME="gorfpgm1g.zip"
readonly LEGACY_KLINGON_ZIP_NAME="gorfk.zip"
readonly REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_DIR="$REPO_ROOT/src"
readonly BUILD_DIR="$SOURCE_DIR/zout"
readonly ROMS_DIR="$REPO_ROOT/roms"
readonly SOURCE_FILE="$SOURCE_DIR/$SOURCE_NAME"
readonly SOURCE_STEM="${SOURCE_NAME%.asm}"
readonly CIM_FILE="$BUILD_DIR/$SOURCE_STEM.cim"
readonly LST_FILE="$BUILD_DIR/$SOURCE_STEM.lst"
readonly SC01_FILE="$ROMS_DIR/sc01.bin"

# German specific paths
readonly GERMAN_SOURCE="$SOURCE_DIR/german/GERMAN_X11.asm"
readonly GERMAN_OUT_FILE="$ROMS_DIR/german.x11"

# French specific paths
readonly FRENCH_SOURCE="$SOURCE_DIR/french/FRENCH_X11.asm"
readonly FRENCH_OUT_FILE="$ROMS_DIR/french.x11"
readonly FRENCH_ZIP_ALIAS="$BUILD_DIR/french_gorf.x11"
readonly LEGACY_FRENCH_OUT_FILE="$ROMS_DIR/french_gorf.x11"

# Klingon specific paths
readonly KLINGON_SOURCE="$SOURCE_DIR/klingon/KLINGON_X11.asm"
readonly KLINGON_OUT_FILE="$ROMS_DIR/klingon.x11"
readonly KLINGON_ZIP_ALIAS="$BUILD_DIR/german.x11"

# Standard English ROM array names
readonly -a ENGLISH_ROM_NAMES=(
    "gorf-a.bin" "gorf-b.bin" "gorf-c.bin" "gorf-d.bin"
    "gorf-e.bin" "gorf-f.bin" "gorf-g.bin" "gorf-h.bin"
)

readonly -a PROGRAM2_ROM_SHA1=(
    "76e2e3ad1a66755f1a369167fdb157690fd44a52"
    "2601faf12d0ab4972c5535ffd722b03ecd8c097c"
    "0b363a71d7585a4828e08668ebb2999c55e02721"
    "392214cc6ed4155bfe022d36f0f86c2594a5ab57"
    "720fb8b48e20c1fc281d8804259016c3c5364a07"
    "9c9d6d3bfee6556dc7a01de81d6148dd02f04fc9"
    "9edccceea5af015275582553ed238c40c73d8f4f"
    "5aa8d824814ee1c30eaf0044da78d3aa8220dcaa"
)

# Program-2 German/Klingon MAME member names
readonly -a GERMAN_ROM_NAMES=(
    "873a.x1" "873b.x2" "873c.x3" "873d.x4"
    "873e.x5" "873f.x6" "873g.x7" "873h.x8"
)

# MAME's French Program-1 clone uses a different CPU member naming convention.
# The bytes still come from the Program-2 CPU image; only the ZIP member names
# are selected to satisfy the gorfpgm1f driver.
readonly -a FRENCH_ROM_NAMES=(
    "gorf_a.x1" "gorf_b.x2" "gorf_c.x3" "gorf_d.x4"
    "gorf_e.x5" "gorf_f.x6" "gorf_g.x7" "gorf_h.x8"
)

readonly -a ROM_ADDRESSES=(
    0x0000 0x1000 0x2000 0x3000
    0x8000 0x9000 0xA000 0xB000
)

# Global configuration variable controlled by arguments
BUILD_GERMAN=false
BUILD_FRENCH=false
BUILD_KLINGON=false
ZIP_NAME=""
ZIP_FILE=""

# Dynamically assigned pointer array to track active file list
ROM_NAMES=() 

log() {
    printf '%s\n' "$*"
}

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

resolve_zmac() {
    local candidate
    if [[ -n "${ZMAC:-}" ]]; then
        if [[ "$ZMAC" == */* ]]; then
            [[ -x "$ZMAC" ]] || fail "ZMAC is not executable: $ZMAC"
            printf '%s\n' "$ZMAC"
        else
            candidate="$(command -v "$ZMAC" 2>/dev/null)" || fail "ZMAC command not found: $ZMAC"
            printf '%s\n' "$candidate"
        fi
        return
    fi

    candidate="$REPO_ROOT/tools/zmac"
    if [[ -x "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return
    fi

    candidate="$(command -v zmac 2>/dev/null)" || fail "zmac was not found. Install it in PATH, place it at tools/zmac, or set ZMAC=/path/to/zmac."
    printf '%s\n' "$candidate"
}

prepare_output_directories() {
    local name
    rm -rf -- "$BUILD_DIR"
    mkdir -p -- "$BUILD_DIR" "$ROMS_DIR"
    
    # Clean up files matching both potential naming schemas
    for name in "${ENGLISH_ROM_NAMES[@]}" "${GERMAN_ROM_NAMES[@]}" "${FRENCH_ROM_NAMES[@]}"; do
        rm -f -- "$ROMS_DIR/$name"
    done
    rm -f -- "$GERMAN_OUT_FILE"
    rm -f -- "$FRENCH_OUT_FILE" "$LEGACY_FRENCH_OUT_FILE"
    rm -f -- "$KLINGON_OUT_FILE"
    rm -f -- "$ROMS_DIR/$ENGLISH_ZIP_NAME" "$ROMS_DIR/$GERMAN_ZIP_NAME" "$ROMS_DIR/$FRENCH_ZIP_NAME" "$ROMS_DIR/$LEGACY_KLINGON_ZIP_NAME"
}

assemble_source() {
    log "[2/5] Assembling $SOURCE_NAME"
    log "      zmac: $ZMAC_BIN"

    if "$ZMAC_BIN" --version 2>&1 | grep -q '1\.3'; then
        log "      Detected zmac v1.3 compatibility mode"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -o "$CIM_FILE" -x "$LST_FILE" "$SOURCE_FILE"
        ) || fail "zmac v1.3 failed. Review the assembler output above."
    else
        log "      Detected modern zmac mode"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -I "$REPO_ROOT" -I "$SOURCE_DIR" --od "$BUILD_DIR" --oo cim,lst "$SOURCE_FILE"
        ) || fail "zmac failed. Review the assembler output above."
    fi

    [[ -s "$CIM_FILE" ]] || fail "zmac did not create $CIM_FILE"
    [[ -s "$LST_FILE" ]] || fail "zmac did not create $LST_FILE"
    log "      image:   $CIM_FILE ($(stat -c '%s bytes' "$CIM_FILE"))"
    log "      listing: $LST_FILE"
}

assemble_german() {
    [[ -f "$GERMAN_SOURCE" ]] || fail "German source file not found: $GERMAN_SOURCE"
    log "[2.5/5] Assembling Optional German ROM: GERMAN_X11.asm"
    local german_tmp_cim="$BUILD_DIR/GERMAN_X11.cim"

    if "$ZMAC_BIN" --version 2>&1 | grep -q '1\.3'; then
        log "      Detected zmac v1.3 compatibility mode for German ROM"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -o "$german_tmp_cim" -x "$BUILD_DIR/GERMAN_X11.lst" "$GERMAN_SOURCE"
        ) || fail "zmac v1.3 failed on German ROM."
    else
        log "      Detected modern zmac mode for German ROM"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -I "$REPO_ROOT" -I "$SOURCE_DIR" -I "$SOURCE_DIR/german" --od "$BUILD_DIR" --oo cim,lst "$GERMAN_SOURCE"
        ) || fail "zmac failed on German ROM."
    fi

    [[ -s "$german_tmp_cim" ]] || fail "zmac did not create $german_tmp_cim"
    local german_size
    german_size="$(stat -c '%s' "$german_tmp_cim")"
    (( german_size == ROM_SIZE )) || fail "German ROM is $german_size bytes; expected $ROM_SIZE"
    cp -- "$german_tmp_cim" "$GERMAN_OUT_FILE"
    log "      german: $GERMAN_OUT_FILE ($(stat -c '%s bytes' "$GERMAN_OUT_FILE"))"
}

assemble_french() {
    [[ -f "$FRENCH_SOURCE" ]] || fail "French source file not found: $FRENCH_SOURCE"
    log "[2.5/5] Assembling Optional French ROM: FRENCH_X11.asm"
    local french_tmp_cim="$BUILD_DIR/FRENCH_X11.cim"

    if "$ZMAC_BIN" --version 2>&1 | grep -q '1\.3'; then
        log "      Detected zmac v1.3 compatibility mode for French ROM"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -o "$french_tmp_cim" -x "$BUILD_DIR/FRENCH_X11.lst" "$FRENCH_SOURCE"
        ) || fail "zmac v1.3 failed on French ROM."
    else
        log "      Detected modern zmac mode for French ROM"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -I "$REPO_ROOT" -I "$SOURCE_DIR" -I "$SOURCE_DIR/french" --od "$BUILD_DIR" --oo cim,lst "$FRENCH_SOURCE"
        ) || fail "zmac failed on French ROM."
    fi

    [[ -s "$french_tmp_cim" ]] || fail "zmac did not create $french_tmp_cim"
    local french_size
    french_size="$(stat -c '%s' "$french_tmp_cim")"
    (( french_size == ROM_SIZE )) || fail "French ROM is $french_size bytes; expected $ROM_SIZE"
    cp -- "$french_tmp_cim" "$FRENCH_OUT_FILE"
    log "      french: $FRENCH_OUT_FILE ($(stat -c '%s bytes' "$FRENCH_OUT_FILE"))"
}

assemble_klingon() {
    [[ -f "$KLINGON_SOURCE" ]] || fail "Klingon source file not found: $KLINGON_SOURCE"
    log "[2.5/5] Assembling Optional Klingon ROM: KLINGON_X11.asm"
    local klingon_tmp_cim="$BUILD_DIR/KLINGON_X11.cim"

    if "$ZMAC_BIN" --version 2>&1 | grep -q '1\.3'; then
        log "      Detected zmac v1.3 compatibility mode for Klingon ROM"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -o "$klingon_tmp_cim" -x "$BUILD_DIR/KLINGON_X11.lst" "$KLINGON_SOURCE"
        ) || fail "zmac v1.3 failed on Klingon ROM."
    else
        log "      Detected modern zmac mode for Klingon ROM"
        (
            cd -- "$REPO_ROOT"
            "$ZMAC_BIN" -I "$REPO_ROOT" -I "$SOURCE_DIR" -I "$SOURCE_DIR/klingon" --od "$BUILD_DIR" --oo cim,lst "$KLINGON_SOURCE"
        ) || fail "zmac failed on Klingon ROM."
    fi

    [[ -s "$klingon_tmp_cim" ]] || fail "zmac did not create $klingon_tmp_cim"
    local klingon_size
    klingon_size="$(stat -c '%s' "$klingon_tmp_cim")"
    (( klingon_size == ROM_SIZE )) || fail "Klingon ROM is $klingon_size bytes; expected $ROM_SIZE"
    cp -- "$klingon_tmp_cim" "$KLINGON_OUT_FILE"
    log "      klingon: $KLINGON_OUT_FILE ($(stat -c '%s bytes' "$KLINGON_OUT_FILE"))"
}

slice_roms() {
    local cim_size
    local index
    local rom_name
    local start_address
    local end_address
    local output_file
    local output_size

    cim_size="$(stat -c '%s' "$CIM_FILE")"
    (( cim_size > ROM_ADDRESSES[${#ROM_ADDRESSES[@]} - 1] )) || fail "Assembled image is too short for the Gorf ROM map: $cim_size bytes"

    log "[3/5] Splitting the CPU image into 4 KB Gorf ROMs"
    log "      The video-memory gap at \$4000-\$7FFF is not packaged."

    for index in "${!ROM_NAMES[@]}"; do
        rom_name="${ROM_NAMES[$index]}"
        start_address="${ROM_ADDRESSES[$index]}"
        end_address=$((start_address + ROM_SIZE - 1))
        output_file="$ROMS_DIR/$rom_name"

        dd if=/dev/zero bs="$ROM_SIZE" count=1 status=none | tr '\000' '\377' > "$output_file"
        dd if="$CIM_FILE" of="$output_file" bs="$ROM_SIZE" skip="$((start_address / ROM_SIZE))" count=1 conv=notrunc status=none

        output_size="$(stat -c '%s' "$output_file")"
        (( output_size == ROM_SIZE )) || fail "$rom_name is $output_size bytes; expected $ROM_SIZE"

        printf '  %-12s CPU $%04X-$%04X %5d bytes\n' "$rom_name" "$start_address" "$end_address" "$output_size"
    done
}

verify_roms() {
    local index
    local rom_name
    local rom_file
    local expected_sha1
    local actual_sha1

    log "[4/5] Verifying Program-2 ROM SHA1 values"

    for index in "${!ROM_NAMES[@]}"; do
        rom_name="${ROM_NAMES[$index]}"
        rom_file="$ROMS_DIR/$rom_name"
        expected_sha1="${PROGRAM2_ROM_SHA1[$index]}"
        actual_sha1="$(sha1sum -- "$rom_file")"
        actual_sha1="${actual_sha1%% *}"

        [[ "$actual_sha1" == "$expected_sha1" ]] ||
            fail "$rom_name SHA1 mismatch: expected $expected_sha1, got $actual_sha1"

        printf '  verified  %-12s %s\n' "$rom_name" "$actual_sha1"
    done
}

create_zip() {
    local rom_name
    local -a zip_inputs=()
    local french_zip_alias=""
    local klingon_zip_alias=""

    for rom_name in "${ROM_NAMES[@]}"; do
        zip_inputs+=("$ROMS_DIR/$rom_name")
    done

    [[ -f "$SC01_FILE" ]] || fail "Required speech ROM not found: $SC01_FILE"
    zip_inputs+=("$SC01_FILE")
    log "      Including required speech ROM: $SC01_FILE"

    if [[ "$BUILD_GERMAN" == true ]]; then
        if [[ -f "$GERMAN_OUT_FILE" ]]; then
            zip_inputs+=("$GERMAN_OUT_FILE")
            log "      Including optional German language ROM: $GERMAN_OUT_FILE"
        else
            fail "German ROM build was requested but file is missing: $GERMAN_OUT_FILE"
        fi
    fi

    if [[ "$BUILD_FRENCH" == true ]]; then
        if [[ -f "$FRENCH_OUT_FILE" ]]; then
            french_zip_alias="$FRENCH_ZIP_ALIAS"
            cp -- "$FRENCH_OUT_FILE" "$french_zip_alias"
            zip_inputs+=("$french_zip_alias")
            log "      Including French language ROM as french_gorf.x11 for MAME: $FRENCH_OUT_FILE"
        else
            fail "French ROM build was requested but file is missing: $FRENCH_OUT_FILE"
        fi
    fi

    if [[ "$BUILD_KLINGON" == true ]]; then
        if [[ -f "$KLINGON_OUT_FILE" ]]; then
            klingon_zip_alias="$KLINGON_ZIP_ALIAS"
            cp -- "$KLINGON_OUT_FILE" "$klingon_zip_alias"
            zip_inputs+=("$klingon_zip_alias")
            log "      Including Klingon language ROM as german.x11 for MAME: $KLINGON_OUT_FILE"
        else
            fail "Klingon ROM build was requested but file is missing: $KLINGON_OUT_FILE"
        fi
    fi

    if ! (
        cd -- "$ROMS_DIR"
        zip -q -j -X "$ZIP_FILE" "${zip_inputs[@]}"
    ); then
        [[ -n "$french_zip_alias" ]] && rm -f -- "$french_zip_alias"
        [[ -n "$klingon_zip_alias" ]] && rm -f -- "$klingon_zip_alias"
        fail "Could not create $ZIP_FILE"
    fi

    [[ -n "$french_zip_alias" ]] && rm -f -- "$french_zip_alias"
    [[ -n "$klingon_zip_alias" ]] && rm -f -- "$klingon_zip_alias"

    [[ -s "$ZIP_FILE" ]] || fail "ZIP archive was not created: $ZIP_FILE"
    log "      archive: $ZIP_FILE ($(stat -c '%s bytes' "$ZIP_FILE"))"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -g|--german)
                BUILD_GERMAN=true
                shift
                ;;
            -f|--french)
                BUILD_FRENCH=true
                shift
                ;;
            -k|--klingon)
                BUILD_KLINGON=true
                shift
                ;;
            -h|--help)
                log "Usage: $0 [options]"
                log "Options:"
                log "  -g, --german   Assemble German Program-2 X11 and package gorfpgm1g.zip"
                log "  -f, --french   Assemble French Program-2 X11 and package gorfpgm1f.zip"
                log "  -k, --klingon  Assemble Klingon Program-2 X11 and package through gorfpgm1g.zip"
                log "  -h, --help     Display this help message"
                exit 0
                ;;
            *)
                fail "Unknown argument: $1. Use --help for usage details."
                ;;
        esac
    done

    local selected=0
    [[ "$BUILD_GERMAN" == true ]] && ((selected += 1))
    [[ "$BUILD_FRENCH" == true ]] && ((selected += 1))
    [[ "$BUILD_KLINGON" == true ]] && ((selected += 1))
    (( selected <= 1 )) || fail "The German, French, and Klingon targets are mutually exclusive."
}

main() {
    local ZMAC_BIN
    parse_arguments "$@"

    # Configure names array depending on the argument flag evaluation
    if [[ "$BUILD_GERMAN" == true ]]; then
        ROM_NAMES=("${GERMAN_ROM_NAMES[@]}")
        ZIP_NAME="$GERMAN_ZIP_NAME"
    elif [[ "$BUILD_FRENCH" == true ]]; then
        ROM_NAMES=("${FRENCH_ROM_NAMES[@]}")
        ZIP_NAME="$FRENCH_ZIP_NAME"
    elif [[ "$BUILD_KLINGON" == true ]]; then
        ROM_NAMES=("${GERMAN_ROM_NAMES[@]}")
        ZIP_NAME="$KLINGON_ZIP_NAME"
    else
        ROM_NAMES=("${ENGLISH_ROM_NAMES[@]}")
        ZIP_NAME="$ENGLISH_ZIP_NAME"
    fi
    ZIP_FILE="$ROMS_DIR/$ZIP_NAME"

    [[ -f "$SOURCE_FILE" ]] || fail "Source file not found: $SOURCE_FILE"

    require_command dd
    require_command stat
    require_command tr
    require_command zip
    require_command sha1sum

    ZMAC_BIN="$(resolve_zmac)"

    log "Gorf ROM build"
    log "  source: $SOURCE_FILE"
    log "  output: $ROMS_DIR"
    log
    log "[1/5] Preparing clean build and ROM output"
    prepare_output_directories

    assemble_source

    if [[ "$BUILD_GERMAN" == true ]]; then
        assemble_german
    elif [[ "$BUILD_FRENCH" == true ]]; then
        assemble_french
    elif [[ "$BUILD_KLINGON" == true ]]; then
        assemble_klingon
    fi

    slice_roms

    verify_roms

    log "[5/5] Creating $ZIP_NAME"
    create_zip

    log
    log "Build complete."
    if [[ "$BUILD_GERMAN" == true ]]; then
        log "  ROM files: $ROMS_DIR/873{a..h}.x{1..8}"
        log "  German ROM: $GERMAN_OUT_FILE"
    elif [[ "$BUILD_FRENCH" == true ]]; then
        log "  ROM files: $ROMS_DIR/gorf_{a..h}.x{1..8}"
        log "  French ROM: $FRENCH_OUT_FILE"
        log "  ZIP X11:    french_gorf.x11"
    elif [[ "$BUILD_KLINGON" == true ]]; then
        log "  ROM files: $ROMS_DIR/873{a..h}.x{1..8}"
        log "  Klingon ROM: $KLINGON_OUT_FILE"
        log "  ZIP X11:    german.x11 (Klingon ROM alias for MAME)"
    else
        log "  ROM files: $ROMS_DIR/gorf-{a..h}.bin"
    fi
    log "  MAME ZIP:  $ZIP_FILE"
}

main "$@"
