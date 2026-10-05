# Target source

`src/` is reserved for source shared by more than one M6x09-I application.

There is currently no shared runtime. Keep a new program self-contained in `applications/` until reuse is clear. The supported host-side assembler is `crosscompiler/bs9`; do not add DOS `cc09` tooling or generated DOS-era outputs here.
