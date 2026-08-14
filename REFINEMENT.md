# M6x09-I-SBC Refinement Notes

This document is the working brief for refining this repository into a clearer companion repo for the GTEK-7228 and related 6809/6309 ROM-burning and SBC work.

It is meant to be edited as we learn more.

## Purpose

This repository currently serves several roles at once:

1. A hardware project record for the Motorola 6809 SBC kit.
2. A software archive for monitor, assembler, and `cc09` toolchain material.
3. A documentation bundle for bring-up, teaching, preservation, and experimentation.
4. A bridge repo for adjacent work on portable development hardware such as the GTEK-7228.

That mix is valuable, but it also makes the repo harder to navigate than it needs to be.

## Current Read

The repo has a strong historical and practical core:

- `README.md` is the main narrative entry point.
- `src/monitor/` appears to hold the most direct monitor source of interest.
- `crosscompiler/` contains the Linux-hosted `bs9` assembler path.
- `src/cc09/` and `src/tools/` contain older toolchain material and board-support code.
- `doc/`, `images/`, `kit/`, `code/`, `cocodev/`, `6309/`, and `z-archives/` act as reference, release, or preservation stores.

The repository feels more like a preservation-and-development workspace than a conventional source-only software repo.

## Top-Level Working Map

This is the current top-level classification to work from without removing anything:

### Active development

- `README.md`
- `REFINEMENT.md`
- `src/monitor/`
- `crosscompiler/`
- `src/`

### Historical source

- `src/cc09/`
- `src/tools/`

### Reference and documentation

- `doc/`
- `images/`
- `6309/`

### Packaged and archive artifacts

- `code/`
- `kit/`
- `cocodev/`
- `emulator/`
- `z-archives/`

## Keep-For-Now Policy

The standing policy for this refinement should be:

1. Keep anything that may still help with ROM generation, monitor rebuilding, hardware bring-up, provenance, or reproduction.
2. Prefer labeling over deleting.
3. Treat duplicate-looking trees as intentional until we prove otherwise.
4. Preserve packaged artifacts when they may be the only surviving release form of a tool, image, or workflow.

## Working Goals

The refinement effort should aim to:

1. Preserve provenance and historical artifacts.
2. Make active development paths obvious.
3. Separate source-of-truth material from mirrored or packaged archives.
4. Clarify how this repo supports ROM creation, monitor iteration, and hardware bring-up.
5. Create cleaner links to sibling repositories in the wider `x09` ecosystem.

## Likely Active Areas

These are the areas most likely to matter for day-to-day work:

- `README.md`
- `src/monitor/m6809v3.c`
- `src/README.md`
- `crosscompiler/README.md`
- `crosscompiler/bs9.c`
- `src/cc09/`
- `src/tools/`

## Likely Archive Or Reference Areas

These look important to keep, but probably should be framed as archive/reference material:

- `doc/`
- `images/`
- `kit/`
- `code/`
- `emulator/`
- `cocodev/`
- `6309/`
- `z-archives/`

## Observations

### 1. The repo tells a good story, but the story is spread out

The top-level README contains hardware description, parts list, software notes, test examples, and project updates. That is useful, but it makes the main entry point long and slightly overloaded.

### 2. There appears to be duplication in tool-related source trees

`src/cc09/` and `src/tools/` appear closely related and may contain duplicated or forked copies of assemblers, support code, and sample programs. We should verify whether one is canonical, whether both matter, or whether they represent different historical stages.

### 3. The repo mixes source, binaries, and packaged deliverables

That is reasonable for retrocomputing and hardware work, but the project would benefit from clearer labeling:

- editable source
- generated output
- vendor or upstream artifacts
- local mirrors
- release bundles

### 4. The GTEK-7228 connection is not yet explicit in this repo

You mentioned this repo is a companion to the GTEK-7228 work because it is a real platform for burning ROM on a portable computer. That relationship should be written down directly so future readers understand why this repo matters beyond the SBC itself.

## Recommended Refinement Plan

### Phase 1: Clarify structure without moving anything

1. Add a short repo map near the top of `README.md`.
2. Add a dedicated section explaining the relationship to the GTEK-7228 workflow.
3. Mark folders as one of:
   - active source
   - archive
   - reference
   - generated/release material
4. Identify the canonical build path for monitor and ROM-related outputs.

### Phase 2: Establish source-of-truth areas

1. Decide whether `src/cc09/` or `src/tools/` is canonical.
2. Document which binaries or ZIP/RAR files are derived from in-repo sources.
3. Note which artifacts are preserved imports and should remain untouched.
4. Add per-folder README files where intent is unclear.

### Phase 3: Improve development workflow

1. Document how to rebuild:
   - `bs9`
   - monitor artifacts
   - any ROM or S19 outputs
2. Capture expected host environment for current work.
3. Note which toolchain pieces are historical-only versus still usable now.

### Phase 4: Optional archival cleanup

1. Group historical bundles more explicitly under archive-oriented paths.
2. Keep filenames and preserved artifacts intact where provenance matters.
3. Avoid deleting duplicates until provenance is understood.

## Questions To Answer As We Refine

1. Which files are the present source of truth for the monitor ROM?
2. Is `m6809v3.c` the current monitor target, or only one preserved version?
3. Are `src/tools/` and `src/cc09/` intentionally separate?
4. Which packaged files in `code/` and `kit/code/` are generated from local source?
5. What exact role does the GTEK-7228 play in EPROM/ROM preparation for this project?
6. Are there manufacturing notes from 2023 that should live in this repo directly?

## Proposed Deliverables

As we work, this refinement can produce:

1. A tightened `README.md`.
2. A top-level repo map.
3. Folder-level READMEs for ambiguous areas.
4. A documented ROM/monitor build path.
5. A clearer archival boundary between editable sources and preserved artifacts.

## Suggested Next Step

The best immediate next step is to map every top-level folder into one of four buckets:

- active development
- historical source
- reference/documentation
- packaged/archive artifacts

That will give us a stable base before we touch structure or wording elsewhere.
